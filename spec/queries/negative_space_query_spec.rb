# frozen_string_literal: true

require "rails_helper"

RSpec.describe NegativeSpaceQuery do
  # The stub detector keeps InfraNodus out of the picture.
  let(:detector) { instance_double(Infranodus::GapDetector) }
  let(:stub_result) { Infranodus::GapDetector::Result.new(gaps: [], main_topics: [], modularity: nil, source: :stub) }

  before { allow(detector).to receive(:detect).and_return(stub_result) }

  def gaps_response(count: 1)
    { "gaps" => Array.new(count) do |i|
      { "title" => "Gap #{i}", "rationale" => "Why", "question" => "Q?", "confidence" => 70, "certainty_basis" => "inference" }
    end }
  end

  describe "trail scope" do
    it "builds the corpus from the trail's opened articles only" do
      on_trail = create(:article)
      create(:insight, article: on_trail, title: "On-trail insight")
      off_trail = create(:article)
      create(:insight, article: off_trail, title: "Off-trail insight")

      trail = Trail.create!
      trail.record_opened!(on_trail)

      stub_llm_chat(default: gaps_response)
      query = described_class.new(trail:, detector:)
      result = query.call

      corpus = query.send(:corpus_message)
      expect(corpus).to include("On-trail insight")
      expect(corpus).not_to include("Off-trail insight")
      expect(result.corpus_count).to eq(1)
    end

    it "takes precedence over topic and narrows within the trail when both are given" do
      article = create(:article)
      create(:insight, article:, title: "Trail insight", embedding: Array.new(1536, 0.1))

      trail = Trail.create!
      trail.record_opened!(article)

      stub_llm
      query = described_class.new(trail:, topic: "ruby", detector:)

      corpus = query.send(:corpus_message)
      expect(corpus).to include("this research session")
      expect(corpus).to include("Trail insight")
    end

    it "returns an empty result for a trail with no opened articles" do
      trail = Trail.create!
      trail.record_search!("just a query")

      result = described_class.new(trail:, detector:).call

      expect(result).to be_empty
      expect(result.corpus_count).to eq(0)
    end

    it "caps the trail corpus at the limit" do
      article = create(:article)
      create_list(:insight, 5, article:)

      trail = Trail.create!
      trail.record_opened!(article)

      query = described_class.new(trail:, limit: 2, detector:)

      expect(query.send(:corpus_items).size).to eq(2)
    end
  end

  describe "error surfacing" do
    it "surfaces an embedding failure on the trail+topic path instead of raising" do
      article = create(:article)
      create(:insight, article:)
      trail = Trail.create!
      trail.record_opened!(article)

      allow(LLM).to receive(:embed).and_raise(StandardError, "no embed for you")

      result = described_class.new(trail:, topic: "ruby", detector:).call

      expect(result.gaps).to be_empty
      expect(result.error).to be_present
    end

    it "reports a friendly error instead of silently returning no gaps" do
      article = create(:article)
      create(:insight, article:)
      trail = Trail.create!
      trail.record_opened!(article)

      chat = stub_llm_chat
      allow(chat).to receive(:ask).and_raise(StandardError, "boom")

      result = described_class.new(trail:, detector:).call

      expect(result.gaps).to be_empty
      expect(result.error).to include("model call failed")
    end
  end
end
