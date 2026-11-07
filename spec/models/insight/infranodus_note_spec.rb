# frozen_string_literal: true

require "rails_helper"

RSpec.describe Insight::InfranodusNote do
  describe "#save" do
    it "returns a stub result when InfraNodus is not configured" do
      insight = create(:insight)
      client = instance_double(InfranodusClient, configured?: false)

      result = described_class.new(insight, client:).save

      expect(result).to be_stubbed
      expect(result.message).to include("INFRANODUS_API_KEY")
    end

    it "creates a graph statement when none exists for the insight" do
      insight = create(:insight, title: "Key Insight", body: "The main takeaway.")
      client = instance_double(InfranodusClient, configured?: true)

      allow(client).to receive(:statements_for).with(name: "jargon-insights").and_return([])
      allow(client).to receive(:graph_and_statements)

      result = described_class.new(insight, client:, graph_name: "jargon-insights").save

      expect(result.status).to eq(:created)
      expect(client).to have_received(:graph_and_statements) do |**kwargs|
        expect(kwargs[:name]).to eq("jargon-insights")
        expect(kwargs[:save]).to be true
        expect(kwargs[:context_type]).to eq("MD")
        expect(kwargs[:statements].first).to include("Key Insight", "jargon:#{insight.nanoid}")
      end
    end

    it "updates the existing statement when the insight was already saved" do
      insight = create(:insight, title: "Key Insight", body: "Revised takeaway.")
      client = instance_double(InfranodusClient, configured?: true)
      existing = { "id" => 42, "content" => "Old text [jargon:#{insight.nanoid}]" }

      allow(client).to receive(:statements_for).and_return([existing])
      allow(client).to receive(:update_statements)

      result = described_class.new(insight, client:, graph_name: "jargon-insights").save

      expect(result.status).to eq(:updated)
      expect(client).to have_received(:update_statements).with(
        name: "jargon-insights",
        edits: [{ statementId: 42, content: a_string_including("Revised takeaway", "jargon:#{insight.nanoid}") }]
      )
    end

    it "returns an error result when the client raises" do
      insight = create(:insight)
      client = instance_double(InfranodusClient, configured?: true)
      allow(client).to receive(:statements_for).and_raise(InfranodusClient::Error, "InfraNodus request failed")

      result = described_class.new(insight, client:).save

      expect(result).to be_error
      expect(result.message).not_to match(/Bearer|api[_-]?key/i)
    end
  end

  describe "#statement_text" do
    it "includes title, body, source, and stable insight id" do
      insight = create(:insight, title: "Key Insight", body: "The <strong>main</strong> takeaway.")

      text = described_class.new(insight).statement_text

      expect(text).to include("Key Insight")
      expect(text).to include("The main takeaway")
      expect(text).to include("(from: #{insight.article.title})")
      expect(text).to include("[jargon:#{insight.nanoid}]")
      expect(text).not_to include("<strong>")
    end
  end
end
