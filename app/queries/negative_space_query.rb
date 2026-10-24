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
  DEFAULT_MODEL = "google/gemini-3.8-flash"

  # Models offered in the lens. Keys are RubyLLM/OpenRouter ids; values are labels.
  # Kept to current flagships + fast/value picks across vendors (verified against
  # the OpenRouter registry, Oct 2026).
  MODELS = {
    "google/gemini-3.8-flash" => "Gemini 3.8 Flash",
    "anthropic/claude-opus-5.5" => "Claude Opus 5.5",
    "anthropic/claude-sonnet-5.5" => "Claude Sonnet 5.5",
    "openai/gpt-5.5" => "GPT-5.5",
    "x-ai/grok-4.7" => "Grok 4.7",
    "deepseek/deepseek-v4.1-flash" => "DeepSeek V4.1 Flash"
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
  Result = Data.define(:gaps, :model, :model_label, :models, :topic, :trail, :prompt,
                       :corpus_count, :grounded_by, :structural_gaps, :error) do
    delegate :empty?, to: :gaps
  end

  def initialize(topic: nil, model: DEFAULT_MODEL, limit: 40, detector: Infranodus::GapDetector.new, trail: nil)
    @topic = topic.to_s.strip.presence
    @trail = trail
    @model = MODELS.key?(model) ? model : DEFAULT_MODEL
    @limit = limit
    @detector = detector
  end

  def call
    return empty_result if corpus_items.empty?

    structural = detect_structural_gaps
    gaps, error = generate_gaps(structural)

    Result.new(
      gaps:,
      error:,
      model: @model,
      model_label: MODELS.fetch(@model),
      models: MODELS,
      topic: @topic,
      trail: @trail,
      prompt: INSTRUCTIONS,
      corpus_count: corpus_items.size,
      grounded_by: structural.grounded? ? "InfraNodus graph analysis" : "model only",
      structural_gaps: structural.gaps.map(&:raw)
    )
  rescue StandardError => e
    # Corpus assembly (incl. topic embedding) can fail too: same honest error
    # path as a failed model call, never a 500.
    Rails.logger.error("NegativeSpaceQuery corpus failed: #{e.message}")
    empty_result.with(error: self.class.friendly_error(e, context: :corpus))
  end

  # One honest line about why the run failed, shown on the page instead of a
  # silent empty result. Context distinguishes the gap-model call from corpus
  # assembly (topic embedding etc.), so the message points at the right knob.
  def self.friendly_error(exception, context: :model)
    case exception
    when RubyLLM::PaymentRequiredError
      "The model provider rejected the request for lack of credits \u2014 top up at openrouter.ai/settings/credits."
    when RubyLLM::UnauthorizedError
      "The model provider rejected the API key \u2014 check OPENROUTER_API_KEY in .env."
    when StructuredChat::ValidationError
      "The model kept returning malformed output \u2014 try a different model."
    else
      if context == :corpus
        "Couldn't assemble the corpus (#{exception.class.name.demodulize}) \u2014 the embedding call may be failing; check EMBEDDING_* settings and the provider key."
      else
        "The model call failed (#{exception.class.name.demodulize}) \u2014 try again or switch models."
      end
    end
  end

  private

  # Returns [gaps, error]; a failure comes back as an empty list plus an honest
  # one-line reason instead of silently empty.
  def generate_gaps(structural)
    content = StructuredChat.new(NegativeSpaceSchema, instructions: INSTRUCTIONS, model: @model)
                            .ask(message_with(structural))

    gaps = content["gaps"].map do |g|
      Gap.new(
        title: g["title"], rationale: g["rationale"], question: g["question"],
        confidence: g["confidence"].to_i, certainty_basis: g["certainty_basis"]
      )
    end

    [gaps, nil]
  rescue StandardError => e
    Rails.logger.error("NegativeSpaceQuery failed: #{e.message}")
    [[], self.class.friendly_error(e)]
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
               topic: @topic, trail: @trail, prompt: INSTRUCTIONS, corpus_count: 0,
               grounded_by: "model only", structural_gaps: [], error: nil)
  end

  def corpus_message
    header = if @trail
               "What this research session has covered so far (trail: #{@trail.display_name}):"
             elsif @topic
               "What the collection currently covers about \"#{@topic}\":"
             else
               "What the collection currently covers:"
             end
    "#{header}\n#{corpus_items.map { |item| "- #{item_title(item)}" }.join("\n")}"
  end

  def corpus_items
    @corpus_items ||= if @trail
                        trail_scoped_items
                      elsif @topic
                        topic_scoped_items
                      else
                        recent_roots
                      end
  end

  # The insights of the articles opened on the trail (parent roll-up included):
  # "what hasn't this session looked at". A topic, when given, narrows within
  # the trail by embedding similarity; either way the corpus is capped at @limit.
  def trail_scoped_items
    scope = Insight.complete.where(id: trail_insight_ids)

    if @topic
      embedding = LLM.embed(@topic).vectors
      scope.nearest_neighbors(:embedding, embedding, distance: "cosine").limit(@limit).to_a
    else
      scope.order(created_at: :desc).limit(@limit).to_a
    end
  end

  # Rolled-up insight ids for every article opened on the trail, in three
  # queries total (articles + their children, root insights, child parents).
  def trail_insight_ids
    articles = @trail.trail_steps.opened.includes(:subject).filter_map(&:subject).grep(Article)
    article_ids = articles.map(&:id) + Article.where(parent_id: articles.map(&:id)).pluck(:id)

    root_ids = Insight.complete.roots.where(article_id: article_ids).pluck(:id)
    parent_ids = Insight.complete.children.where(article_id: article_ids).pluck(:parent_id)

    (root_ids + parent_ids).uniq
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
