# frozen_string_literal: true

class Insight
  class InfranodusNote
    Result = Data.define(:status, :graph_name, :graph_url, :message) do
      def saved? = %i[created updated].include?(status)
      def stubbed? = status == :stub
      def error? = status == :error
    end

    MAX_STATEMENT_LENGTH = 1000
    IDENTITY_PREFIX = "jargon:"

    def initialize(insight, client: InfranodusClient.new, graph_name: InfranodusClient.graph_name)
      @insight = insight
      @client = client
      @graph_name = graph_name
    end

    def save
      return stub_result unless @client.configured?

      existing = matching_statement
      payload = if existing
                  @client.update_statements(name: @graph_name, edits: [{ statementId: statement_id(existing), content: statement_text }])
                  :updated
                else
                  @client.graph_and_statements(**create_payload)
                  :created
                end

      Result.new(
        status: payload,
        graph_name: @graph_name,
        graph_url: nil,
        message: infranodus_message(payload)
      )
    rescue InfranodusClient::Error
      Result.new(status: :error, graph_name: @graph_name, graph_url: nil, message: "InfraNodus save failed.")
    end

    def statement_text
      parts = [plain_text(@insight.title), plain_text(@insight.body)].compact_blank
      text = parts.join(". ")
      text = "#{text} (from: #{source_title})" if source_title.present?
      text = "#{text} [#{identity_token}]"
      text.truncate(MAX_STATEMENT_LENGTH)
    end

    private

    def stub_result
      Rails.logger.info("Insight::InfranodusNote stub: INFRANODUS_API_KEY not set; skipped #{@insight.nanoid}")
      Result.new(
        status: :stub,
        graph_name: @graph_name,
        graph_url: nil,
        message: "InfraNodus skipped (INFRANODUS_API_KEY not set)."
      )
    end

    def matching_statement
      @client.statements_for(name: @graph_name).find do |statement|
        content = statement_content(statement)
        categories = Array(statement["categories"] || statement[:categories])
        content.include?(identity_token) || categories.include?(identity_token)
      end
    end

    def create_payload
      {
        name: @graph_name,
        statements: [statement_text],
        categories: [[identity_token]],
        timestamps: [@insight.created_at&.utc&.iso8601].compact,
        context_type: "MD",
        save: true,
        include_statements: false,
        include_graph: false
      }
    end

    def identity_token
      "#{IDENTITY_PREFIX}#{@insight.nanoid}"
    end

    def statement_id(statement)
      statement["id"] || statement["statementId"] || statement[:id]
    end

    def statement_content(statement)
      (statement["content"] || statement["text"] || statement[:content] || statement[:text]).to_s
    end

    def plain_text(text)
      text.to_s
          .gsub(%r{<strong>(.*?)</strong>}m, '\1')
          .gsub(/<[^>]+>/, " ")
          .gsub(/\s+/, " ")
          .strip
          .presence
    end

    def source_title
      @insight.article&.title.presence
    end

    def infranodus_message(status)
      verb = status == :updated ? "Updated" : "Created"
      "#{verb} InfraNodus note on graph #{@graph_name}."
    end
  end
end
