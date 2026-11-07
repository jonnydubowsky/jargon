# OpenMemory Guide — Sense Collective (JargonDKR)

Living index for the `jonnydubowsky/jargon` project. Keep in sync with the code.

## Overview

**Sense Collective — Dynamic Knowledge Ecosystem** is a fork of [Jargon](https://github.com/jargon-io/jargon).
It is a Dynamic Knowledge Repository (Engelbart): a five-function loop that turns sources
into a persistent, linked knowledge graph.

**Core loop:** Ingest → Summarize → Extract → Connect → Thread.

**Differentiator:** exposed, modifiable prompts (you can see and change how the AI reasons);
a persistent pgvector graph (not ephemeral chat); second-order improvement.

**Relationship to ShurIQ:** JargonDKR is the open, educational substrate; ShurIQ is the
productized brand-intelligence instrument built on the same DNA. See
`docs/dev_bench/2026-06-24-negative-space-lens.md` for the integration thesis.

## Architecture

- **Stack:** Rails + Hotwire/Turbo, Falcon (async server), async-job (in-process),
  PostgreSQL + pgvector, RubyLLM (via OpenRouter by default), ruby_llm-schema, Exa, crawl4ai, pdftotext.
- **Domain models:** `Article` (source) → `Insight` (extracted idea); `Search` (research
  query) ↔ `Article` via `SearchArticle`. Insights/Articles cluster into synthesized parents.
- **LLM access:** `LLM.chat(model:)` and `LLM.embed(text)` in `config/initializers/ruby_llm.rb`.
  Structured output via `StructuredChat.new(Schema, instructions:, model:)`.
- **Vector search:** `SimilarItemsQuery` (pgvector `nearest_neighbors`, cosine).
- **Concerns (extension surface):** `Sluggable`, `Parentable` (auto-cluster), `Embeddable`,
  `Broadcastable` (Turbo Streams), `Linkable`, `SearchGeneratable` (auto research questions),
  `NormalizesMarkup`.
- **Jobs:** `IngestArticleJob`, `GenerateInsightsJob`, `SearchJob`, `SummarizeSearchJob`,
  `AddLinksJob`, `CleanupDeadLinksJob`.
- **Prompts live in:** `IngestArticleJob`, `GenerateInsightsJob`, `search_generatable.rb`,
  `*/parent_synthesizer.rb`, `negative_space_query.rb`.

## Components

- **Negative Space Lens** (`/negative-space`) — surfaces the collection's blind spots and
  turns each into a research thread. `NegativeSpaceQuery` + `NegativeSpaceSchema` +
  `NegativeSpaceController` + `negative_space/index.html.erb`. Exposed prompt + model
  selector (the "glass box"). Shipped 2026-06-24 (Experiment A).
- **InfraNodus gap adapter** — `lib/infranodus_client.rb` (REST client, mirrors `ExaClient`)
  + `lib/infranodus/gap_detector.rb` (`Infranodus::GapDetector#detect` → normalized gaps,
  gated on `INFRANODUS_API_KEY`, safe stub fallback). Grounds the Negative Space Lens when
  configured. Shared contract with Aethelgard's Stage-2: `docs/INFRANODUS_ADAPTER.md`.
- **Deploy** — Fly.io: `fly.toml` + `docs/DEPLOY_FLY.md` (first public Rails URL).

## Patterns

- New analysis feature = a query object in `app/queries/` + a `RubyLLM::Schema` in
  `app/schemas/` + a thin controller + an ERB view. Reuse `StructuredChat` for validated
  output and `queries_path` (POST `q`) to spawn research threads.
- User-facing copy avoids knowledge-graph jargon (no "embedding"/"modularity"/"graph").
  Say "blind spots", "what's missing", "unasked questions".
- Tailwind dark theme classes: `surface`, `surface-alt`, `border-strong`, `border-default`,
  `btn-primary`, `text-heading`, `text-body`, `text-muted`.
- Testing: app uses `allow_browser versions: :modern` + host authorization — integration
  sessions need a modern `User-Agent` and `host! "localhost"`.

## User Defined Namespaces
- [Leave blank - user populates]
