# frozen_string_literal: true

# Low-level client for the InfraNodus REST API.
# Mirrors ExaClient: HTTPX, bearer auth.
# Get an API token at https://infranodus.com/api-access and set INFRANODUS_API_KEY.
#
# Ported from the spec-graph-import branch's InfranodusClient and extended with
# save/update helpers for insight notes. When the API key is missing, callers
# should check #configured? and dry-run instead of posting.
class InfranodusClient
  class Error < StandardError; end

  BASE_URL = "https://infranodus.com/api/v1"
  DEFAULT_GRAPH_NAME = "jargon-insights"

  def initialize(api_key: ENV.fetch("INFRANODUS_API_KEY", nil), base_url: ENV.fetch("INFRANODUS_BASE_URL", BASE_URL))
    @api_key = api_key.presence
    @base_url = base_url.to_s.chomp("/")
  end

  def configured?
    @api_key.present?
  end

  def self.graph_name
    ENV["INFRANODUS_GRAPH_NAME"].presence || DEFAULT_GRAPH_NAME
  end

  # POST /graphAndStatements
  # Pass save: true (doNotSave=false) to persist the graph in the user account.
  def graph_and_statements(name: self.class.graph_name, text: nil, statements: nil, categories: nil, timestamps: nil,
                           context_type: nil, ai_topics: false, save: false, include_statements: false, include_graph: false)
    json = { name:, aiTopics: ai_topics }
    json[:text] = text if text.present?
    json[:statements] = statements if statements
    json[:categories] = categories if categories
    json[:timestamps] = timestamps if timestamps
    json[:contextType] = context_type if context_type.present?

    post("graphAndStatements", json:, params: {
           doNotSave: (!save).to_s,
           addStats: "false",
           includeStatements: include_statements.to_s,
           includeGraph: include_graph.to_s,
           includeGraphSummary: "false"
         })
  end

  def statements_for(name:)
    extract_statements(graph_and_statements(name:, include_statements: true))
  rescue Error
    []
  end

  def update_statements(name:, edits:)
    post("updateStatements", json: { name:, edits:, dryRun: false })
  end

  private

  def post(path, json:, params: nil)
    raise Error, "InfraNodus is not configured" unless configured?

    uri = URI.join("#{@base_url}/", path)
    request = { json:, headers: }
    request[:params] = params if params
    response = HTTPX.post(uri, **request).raise_for_status
    payload = response.json

    raise Error, "InfraNodus request failed" if payload.is_a?(Hash) && payload["error"].present?

    payload
  rescue HTTPX::Error
    Rails.logger.error("InfranodusClient request failed: #{path}")
    raise Error, "InfraNodus request failed"
  end

  def extract_statements(raw)
    Array(raw&.dig("entriesAndGraphOfContext", "statements") || raw&.[]("statements"))
  end

  def headers
    {
      "Authorization" => "Bearer #{@api_key}",
      "Content-Type" => "application/json"
    }
  end
end
