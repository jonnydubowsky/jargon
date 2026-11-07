# frozen_string_literal: true

require "rails_helper"

RSpec.describe InfranodusClient do
  def stub_httpx_json(payload)
    response = instance_double(HTTPX::Response)
    allow(response).to receive(:raise_for_status).and_return(response)
    allow(response).to receive(:json).and_return(payload)
    allow(HTTPX).to receive(:post).and_return(response)
  end

  describe "#configured?" do
    it "is false when no API key is present" do
      expect(described_class.new(api_key: nil)).not_to be_configured
    end

    it "is true when an API key is present" do
      expect(described_class.new(api_key: "test-token")).to be_configured
    end
  end

  describe "#graph_and_statements" do
    it "posts to InfraNodus without logging or returning the token" do
      client = described_class.new(api_key: "test-token")
      stub_httpx_json({ "entriesAndGraphOfContext" => { "statements" => [] } })

      payload = client.graph_and_statements(name: "jargon-insights", statements: ["A note"], save: true)

      expect(payload.dig("entriesAndGraphOfContext", "statements")).to eq([])
      expect(HTTPX).to have_received(:post) do |_uri, **request|
        expect(request[:headers]["Authorization"]).to eq("Bearer test-token")
        expect(request[:json][:name]).to eq("jargon-insights")
        expect(request[:json][:statements]).to eq(["A note"])
        expect(request[:params][:doNotSave]).to eq("false")
      end
    end

    it "raises a generic error that does not include the API key" do
      client = described_class.new(api_key: "super-secret-token")
      allow(HTTPX).to receive(:post).and_raise(HTTPX::Error.new("unauthorized Bearer super-secret-token"))

      expect { client.graph_and_statements(name: "jargon-insights", text: "note", save: true) }
        .to raise_error(InfranodusClient::Error, "InfraNodus request failed")
    end
  end

  describe "#statements_for" do
    it "returns an empty list when the graph cannot be loaded" do
      client = described_class.new(api_key: "test-token")
      allow(HTTPX).to receive(:post).and_raise(HTTPX::Error.new("missing"))

      expect(client.statements_for(name: "jargon-insights")).to eq([])
    end
  end
end
