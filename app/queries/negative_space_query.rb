# frozen_string_literal: true

# Negative Space Lens
#
# Maps the "negative space" of the knowledge base: the important angles,
# tensions, and unasked questions that are absent or underdeveloped — not the
# things already well covered. This is the open, second-order sibling of the
# ShurIQ "Negative Space" report, built on the same ingest -> connect -> thread
# loop. Each gap can be turned into a research Search, which fills the gap and
# shrinks the negative space.
#
# The prompt is exposed on purpose (see INSTRUCTIONS). The same prompt can be
# run against different models; the top blind spot often changes with the model.
class NegativeSpaceQuery
  DEFAULT_MODEL = "google/gemini-2.5-flash"

  # Models offered in the lens. Keys are RubyLLM/OpenRouter ids; values are labels.
  MODELS = {
    "google/gemini-2.5-flash" => "Gemini 2.5 Flash",
    "anthropic/claude-opus-4-8" => "Claude Opus 4.8",
    "anthropic/claude-sonnet-4-6" => "Claude Sonnet 4.6",
    "openai/gpt-5" => "GPT-5",
    "deepseek/deepseek-chat" => "DeepSeek"
  }.freeze

  # Exposed prompt — this is the glass box. Change it and the blind spots change.
  INSTRUCTIONS = <<~PROMPT
    You are mapping the NEGATIVE SPACE of a body of knowledge: the important
    subjects, tensions, and questions that are absent or underdeveloped — not the
    things it already covers well.

    You will be given a list of what the collection currently contains. Identify
    its most significant blind spots: subjects a thoughtful expert would expect to
    find here but cannot, adjacent domains that would yield real insight, and
    unasked questions whose answers would change the overall picture.

    Rules:
    - Do not summarize or restate what is present. Name what is missing.
    - For each blind spot, explain why its absence matters.
    - Prefer structural gaps (a whole missing perspective) over small omissions.
    - End each with one concrete question that would begin to fill the gap.
    - Give each a CALIBRATED confidence (0-100) that it is a real, significant gap.
      Be honest and do not inflate: reserve 80+ for gaps strongly implied by what is
      present or confirmed by measured structural gaps; use 45-65 for reasonable
      inferences; go below 40 when speculative. Say in one phrase what it rests on.

    If you are also given measured structural gaps between topic clusters, treat them
    as strong evidence of where the negative space lies — prioritize them and rate
    them with higher confidence.
  PROMPT

  Gap = Data.define(:title, :rationale, :question, :confidence, :certainty_basis) do
    # Confidence band for display: :high (>=75), :moderate (50-74), :low (<50)
    def band
      case confidence.to_i
      when 75.. then :high
      when 50...75 then :moderate
      else :low
      end
    end
  end
  Result = Data.define(:gaps, :model, :model_label, :models, :topic, :prompt,
                       :corpus_count, :grounded_by, :structural_gaps) do
    def empty? = gaps.empty?
  end

  def initialize(topic: nil, model: DEFAULT_MODEL, limit: 40, detector: Infranodus::GapDetector.new)
    @topic = topic.to_s.strip.presence
    @model = MODELS.key?(model) ? model : DEFAULT_MODEL
    @limit = limit
    @detector = detector
  end

  def call
    return empty_result if corpus_items.empty?

    structural = detect_structural_gaps

    Result.new(
      gaps: generate_gaps(structural),
      model: @model,
      model_label: MODELS.fetch(@model),
      models: MODELS,
      topic: @topic,
      prompt: INSTRUCTIONS,
      corpus_count: corpus_items.size,
      grounded_by: structural.grounded? ? "InfraNodus graph analysis" : "model only",
      structural_gaps: structural.gaps.map(&:raw)
    )
  end

  private

  def generate_gaps(structural)
    content = StructuredChat.new(NegativeSpaceSchema, instructions: INSTRUCTIONS, model: @model)
                            .ask(message_with(structural))

    content["gaps"].map do |g|
      Gap.new(
        title: g["title"], rationale: g["rationale"], question: g["question"],
        confidence: g["confidence"].to_i, certainty_basis: g["certainty_basis"]
      )
    end
  rescue StructuredChat::ValidationError, StandardError => e
    Rails.logger.error("NegativeSpaceQuery failed: #{e.message}")
    []
  end

  # Ground the prompt in measured structural gaps when InfraNodus is configured;
  # otherwise the detector returns a stub and we fall back to model-only analysis.
  def detect_structural_gaps
    @detector.detect(text: corpus_message)
  rescue Infranodus::Error
    Infranodus::GapDetector::Result.new(gaps: [], main_topics: [], modularity: nil, source: :stub)
  end

  def message_with(structural)
    return corpus_message unless structural.grounded? && structural.any?

    lines = structural.gaps.map { |g| "- #{g.from_topic} ↔ #{g.to_topic}" }.join("\n")
    "#{corpus_message}\n\nMeasured structural gaps between topic clusters (from graph analysis):\n#{lines}"
  end

  def empty_result
    Result.new(gaps: [], model: @model, model_label: MODELS.fetch(@model), models: MODELS,
               topic: @topic, prompt: INSTRUCTIONS, corpus_count: 0,
               grounded_by: "model only", structural_gaps: [])
  end

  def corpus_message
    header = @topic ? "What the collection currently covers about \"#{@topic}\":" : "What the collection currently covers:"
    "#{header}\n#{corpus_items.map { |item| "- #{item_title(item)}" }.join("\n")}"
  end

  def corpus_items
    @corpus_items ||= @topic ? topic_scoped_items : recent_roots
  end

  def topic_scoped_items
    embedding = LLM.embed(@topic).vectors
    SimilarItemsQuery.new(embedding:, limit: 25).call
  end

  def recent_roots
    Insight.complete.roots.order(created_at: :desc).limit(@limit).to_a
  end

  def item_title(item)
    item.try(:title).presence || item.try(:query).presence || "Untitled"
  end
end
