# frozen_string_literal: true

# Shared-contract InfraNodus gap detector. See docs/INFRANODUS_ADAPTER.md.
#
# Returns the *structural gaps* of a body of text — the under-connected pairs of
# topic clusters that a knowledge graph would bridge. This is the discovery half
# of the capability Aethelgard's Stage-2 adapter uses for value attestation; both
# repos share the same gating discipline (live only when configured), the same
# normalized result, and a safe fallback when the API is not configured.
#
# Live path calls the InfraNodus REST API. Without INFRANODUS_API_KEY it returns
# an empty, clearly-marked stub result so callers degrade gracefully (the Lens
# falls back to model-only analysis) rather than failing.
module Infranodus
  class Error < StandardError; end

  class GapDetector
    # "Gap 1: Latency (mojo ruby ...) -> Async Architecture (architecture favor ...)"
    GAP_PATTERN = /\AGap\s*\d+:\s*(.+?)\s*->\s*(.+)\z/

    Gap = Data.define(:from_topic, :to_topic, :terms, :raw)

    Result = Data.define(:gaps, :main_topics, :modularity, :source) do
      def grounded? = source == :infranodus
      delegate :any?, to: :gaps
    end

    def initialize(client: InfranodusClient.new)
      @client = client
    end

    def available?
      @client.configured?
    end

    def detect(text:, name: "sense-collective-dkr")
      return stub unless available?

      raw = @client.graph_and_statements(text:, name:)
      summary = extended_summary(raw)

      Result.new(
        gaps: parse_gaps(summary["contentGaps"]),
        main_topics: Array(summary["mainTopicNames"]),
        modularity: raw.dig("graph", "graphologyGraph", "attributes", "modularity"),
        source: :infranodus
      )
    rescue HTTPX::Error, JSON::ParserError, KeyError => e
      Rails.logger.error("[Infranodus::GapDetector] #{e.class}: #{e.message}")
      raise Error, e.message
    end

    private

    # InfraNodus has nested the summary under entriesAndGraphOfContext in practice;
    # fall back to the top-level key in case the shape varies.
    def extended_summary(raw)
      raw.dig("entriesAndGraphOfContext", "extendedGraphSummary") ||
        raw["extendedGraphSummary"] || {}
    end

    def parse_gaps(content_gaps)
      Array(content_gaps).filter_map do |line|
        next unless (m = GAP_PATTERN.match(line.to_s))

        Gap.new(from_topic: topic(m[1]), to_topic: topic(m[2]), terms: terms(line), raw: line.to_s)
      end
    end

    def topic(fragment)
      fragment.sub(/\s*\(.*\)\s*\z/, "").strip
    end

    def terms(line)
      line.to_s.scan(/\(([^)]*)\)/).flatten.join(" / ")
    end

    def stub
      Rails.logger.info("[Infranodus::GapDetector:STUB] INFRANODUS_API_KEY not set; model-only fallback")
      Result.new(gaps: [], main_topics: [], modularity: nil, source: :stub)
    end
  end
end
