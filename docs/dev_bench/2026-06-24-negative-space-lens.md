# Development Bench — 2026-06-24

## Context: JargonDKR × ShurIQ integration

Reconnaissance across the repo, the vault, OpenMemory, and recent meetings established
the current picture:

- **ShurIQ is the center of gravity.** The "studios" (Simulation, Writing, Pitch Deck),
  "startupOS" (= *ShurIQ Founder OS* / *Shur-OS*), and the "shuriq framework" are all
  layers of ShurIQ, not separate products. Simulation Studio launched ~June 18 (6,000
  audience simulations for the AHA pitch). New partner Christine Hagedorn is driving an
  enterprise-services → self-serve-platform pivot, plus a Substack authority play.
- **JargonDKR / Sense Collective is dormant as a standalone**, but its DKR concept now
  lives *inside* ShurIQ's ~80,000-statement knowledge graph.
- **"The Forge" = Aethelgard** — a *separate* Rails 8.1 app at `~/Documents/projects/aethelgard/`:
  the signal-ingestion engine + REA value-flow attestation + Hotwire dashboard for the Totem/ShurIQ
  stack. Stage-1 complete (commit `37fb5fb`), gated behind `AETHELGARD_LIVE=false`.
  **Stage-2 = "InfraNodus adapter live" — the same capability as this DKR's Negative Space Lens v2.**
  A real convergence point: the two repos should share one InfraNodus gap-detection adapter.

### The integration thesis

JargonDKR and ShurIQ are the same organism at two altitudes. Both are an
`ingest → summarize → extract → connect → thread` loop over a persistent pgvector graph.
JargonDKR is the **open, second-order, educational substrate** (exposed, modifiable
prompts; you can see and change how the AI reasons). ShurIQ is the **productized,
client-facing instrument** on top.

Four concrete bridges:

1. **Negative Space ≡ graph gaps.** ShurIQ's flagship "Negative Space" hook is the
   under-connected regions of a knowledge graph — computable here.
2. **Studios = Workspaces.** A studio is one graph viewed through a swappable, exposed
   prompt configuration (the planned Phase 2 `Workspace` / `PromptRegistry`).
3. **Exposed prompts = the SDK + the AI-education play.** Prompt transparency is both
   the de-risking SDK surface and the client-education product.
4. **Substack = the Thread function, published outward.**

---

## Shipped this session: Experiment A — Negative Space Lens

A live, open demonstrator of ShurIQ's "Negative Space" on the DKR substrate.

**Route:** `GET /negative-space`

**What it does:** reads the existing insight collection (optionally scoped to a topic),
asks a model to name the most significant blind spots — the questions a sharp expert
would expect answered here but can't find — and renders each with a one-click
**"Explore this"** that spawns a real research `Search`, closing the loop:
gap detected → thread spawned → sources ingested → blind spot shrinks.

**Why it's the bridge:** it's ShurIQ's core hook, demonstrated openly, and it doubles as
a glass box — the exact prompt and the model used are shown on the page.

### Files

| File | Role |
|------|------|
| `app/queries/negative_space_query.rb` | Analyzer. Exposed `INSTRUCTIONS` prompt, `MODELS` allowlist, corpus assembly (topic-scoped via `SimilarItemsQuery`, or recent insight roots), structured-output call. |
| `app/schemas/negative_space_schema.rb` | `RubyLLM::Schema` — array of `{title, rationale, question}`. |
| `app/controllers/negative_space_controller.rb` | `#index`; runs only when `params[:run]` present. |
| `app/views/negative_space/index.html.erb` | Form (topic + **model selector**), glass-box prompt panel (`<details>`), gap cards, per-gap explore form → `queries_path`. Plain-language copy, no graph jargon. |
| `config/routes.rb` | `get "negative-space"`. |
| `app/views/layouts/_guide.html.erb` | Sidebar entry point. |
| `config/initializers/ruby_llm.rb` | `LLM.chat(model:)` — optional per-request model override (backward compatible). |
| `app/models/structured_chat.rb` | `StructuredChat.new(..., model:)` — threads the model through (backward compatible). |

### Model switching (the live demo)

The lens runs the *same* exposed prompt against a selectable model
(Gemini 2.5 Flash · Claude Opus 4.8 · Sonnet 4.6 · GPT-5 · DeepSeek). This operationalizes
a stored ShurIQ finding: *re-running the negative-space pipeline on a new model surfaces a
genuinely different top gap.* Switching models on the page makes that visible — the core
"glass box" argument, demonstrated rather than asserted.

### Verified locally

- App boots; schema valid; route + helper resolve; model fallback works.
- End-to-end run against the real corpus (230 insights / 181 complete roots) returned 5
  coherent blind spots (ethics/governance, ROI, developer workflow, maintainability,
  cross-language interop) for a corpus that is otherwise Ruby/LLM/performance-heavy.
- `GET /negative-space` and `/` render 200 with all elements present.

> Note on testing: the app uses `allow_browser versions: :modern` and host authorization,
> so integration sessions need a modern `User-Agent` and `host! "localhost"`.

---

## Next on the bench

- **Deploy live.** Decision: host on **existing ShurIQ infra**. Needs access details
  (or the ShurIQ deploy config) to push a public URL. Until then it runs locally and via
  the repo's Docker/Falcon path.
- **InfraNodus upgrade (v2).** Swap/augment the LLM-only gap call with the real ShurIQ
  gap engine: `generate_content_gaps` + structural gaps + conceptual bridges. The
  `extendedGraphSummary.contentGaps` path is the one to read.
- **Experiment C — Glass Box Report** (low effort): every claim links to its source
  insight *and* shows the generating prompt. Reuses the glass-box panel pattern.
- **Experiment B — Studio = Workspace** (Phase 2): `Workspace` model + `PromptRegistry`
  concern; the Negative Space Lens becomes the first named "Studio."
- **Blog posts** (drafting in `docs/blog/`): The Glass Box · Negative Space · Studios Are
  Just Workspaces.

---

## Update — shared InfraNodus adapter + Fly.io prep

**Shared gap adapter (shipped).** Built jargon's side of the convergence with Aethelgard
Stage-2. Key finding from mapping the Forge: Aethelgard calls a *Python bridge*
(`SHURIQ_BRIDGE_URL/analyze`) returning a value-attestation *verdict*, not InfraNodus
directly — a different operation than the DKR's gap *discovery*. So a literally-shared
file is wrong; the right shared thing is a **contract** (see `docs/INFRANODUS_ADAPTER.md`).

- `lib/infranodus_client.rb` — `InfranodusClient` (HTTPX/bearer, mirrors `ExaClient`),
  `POST /api/v1/graphAndStatements`.
- `lib/infranodus/gap_detector.rb` — `Infranodus::GapDetector#detect` → normalized
  `Result(gaps:, main_topics:, modularity:, source:)`; gated on `INFRANODUS_API_KEY`;
  safe stub fallback; parses `entriesAndGraphOfContext.extendedGraphSummary.contentGaps`.
- `negative_space_query.rb` now grounds the exposed prompt in measured structural gaps
  when InfraNodus is configured; falls back to model-only otherwise. The glass-box panel
  shows which (`grounded by …`) and lists the measured gaps.
- **Bug fixed:** schema's `question` cap (100 chars) was below typical model output
  (~150 chars), so `StructuredChat` hit max-retries and the rescue silently returned zero
  gaps. Relaxed caps (title 100, rationale 500, question 160) + brevity hints in
  descriptions. Verified across repeated runs.

**Verified:** stub path + live-path parsing (fake client) + full end-to-end run through the
local server (`GET /negative-space?run=1` → 200, 5 gap cards, glass box, grounded-by line).

**Fly.io (prepped, not deployed).** `fly.toml` + `docs/DEPLOY_FLY.md` runbook. First public
Rails URL for the stack (ShurIQ's pages.dev is React-only). Needs your Fly auth + secrets
(incl. `INFRANODUS_API_KEY`) to go live.

**Aethelgard convergence (handoff).** To finish the shared contract: either add a
`type: :discovery` mode to the Python bridge that returns the normalized gap list, or
extract `InfranodusClient` to a `totem-infranodus` gem both repos depend on.
