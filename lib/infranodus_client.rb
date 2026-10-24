# frozen_string_literal: true

# Low-level client for the InfraNodus REST API.
# Mirrors ExaClient: HTTPX, bearer auth, raise_for_status.
# Get an API token at https://infranodus.com/api-access and set INFRANODUS_API_KEY.
class InfranodusClient
  BASE_URL = "https://infranodus.com/api/v1"

  def initialize(api_key: ENV.fetch("INFRANODUS_API_KEY", nil))
    @api_key = api_key
  end

  def configured?
    @api_key.present?
  end

  # POST /graphAndStatements -> graph + extendedGraphSummary
  # (contentGaps, mainTopicNames, topInfluentialNodes, diversityStatistics).
  def graph_and_statements(text:, name: "sense-collective-dkr", ai_topics: true)
    uri = URI.join("#{BASE_URL}/", "graphAndStatements")
    json = { name:, text:, aiTopics: ai_topics }

    HTTPX.post(uri, json:, headers:).raise_for_status.json
  end

  private

  def headers
    {
      "Authorization" => "Bearer #{@api_key}",
      "Content-Type" => "application/json"
    }
  end
end
