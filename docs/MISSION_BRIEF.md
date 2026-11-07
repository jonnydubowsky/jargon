---
title: "Mission Brief — JargonDKR × ShurIQ"
subtitle: "Everything we're working to accomplish, and what the team found."
date: 2026-06-24
status: internal — confidential
---

## The one-paragraph version

The job is to fold the **JargonDKR** concept (this repo — *Sense Collective, a Dynamic Knowledge Ecosystem*) into the **updated ShurIQ vision**, and to prove it with real things: live experiments at real URLs, educational blog posts, and updates to the development bench. The recon turned up a clean answer to "how do these fit together," and the first experiment — the **Negative Space Lens** — is built and running. This brief covers the whole picture and every agent's contribution.

---

## The constellation — four pieces, one organism

The names that were floating around ("ShurIQ", "the Forge", "the studios", "startupOS", "JargonDKR") are not separate products. They are layers of one stack.

**1. Jargon / Sense Collective DKR** *(this repo)* — the **knowledge substrate**. A Rails 8.1 / Hotwire / RubyLLM app, forked from Jargon. It runs a five-function loop — **Ingest → Summarize → Extract → Connect → Thread** — turning articles, PDFs, and YouTube videos into linked "insight cards" in a persistent pgvector knowledge graph. Its philosophy is Engelbart's Dynamic Knowledge Repository: **exposed, modifiable prompts** (you can see and change how the AI reasons), a graph that accumulates instead of evaporating like chat, and *second-order improvement* (improving how you improve).

**2. Aethelgard — "The Totem Forge"** *(the Forge)* — a **separate** Rails 8.1 app at `~/Documents/projects/aethelgard/`. The **signal-ingestion engine + REA value-flow attestation + live Hotwire dashboard** for the Totem/ShurIQ stack. It watches signals (e.g. Google News via SerpApi), asks whether each one closes a structural gap in the graph, and records the ones that do as economic value events. Stage-1 is complete (verified: 100 live signals → 57 value events); everything is gated behind a master switch `AETHELGARD_LIVE=false` so it runs in a hermetic sandbox by default. **Stage-2 = flip the InfraNodus adapter live.**

**3. ShurIQ Report Studio** — the **client-facing product**, and the only piece already deployed: **live at `shuriq-report-studio.pages.dev`**. Built in Vite/React on Cloudflare Pages + D1 + the Anthropic SDK. It runs the first production "Managed Agent" in the ecosystem (Opus 4.8). It produces regulatory-grade brand-intelligence reports — *observations against a published rubric*, not marketing collateral — with a "report grammar," stack-ranking, and the flagship **Negative Space** concept.

**4. Founder OS / startupOS** — the **onboarding/account layer**, KG (Kristine) Hagedorn's "Shur Entrepreneur Operating System." A sequenced path: onboarding → ShurIQ "Health Check" report → feedback-loop chat → business plan → pitch deck. "Business school in a bottle." Design-handoff stage.

---

## The integration thesis (the core answer)

**JargonDKR and ShurIQ are the same organism at two altitudes.** Both are an ingest→connect→thread loop over a knowledge graph. JargonDKR is the **open, educational, second-order substrate** (glass-box prompts). ShurIQ is the **productized instrument** on top. Four concrete bridges make this real, not rhetorical:

1. **Negative Space = knowledge-graph gaps.** ShurIQ's flagship hook — "what a brand isn't saying" — is the under-connected regions of a knowledge graph. That is directly computable in the DKR.
2. **Studios = Workspaces.** A "studio" (Simulation, Writing, Pitch Deck) is one graph viewed through a swappable, exposed prompt configuration. Build the engine once; reconfigure the lens per studio.
3. **Exposed prompts = the SDK + the client-education product.** Prompt transparency is both how you de-risk the system from depending on one expert, and how you teach clients who don't yet understand AI.
4. **Substack authority play = the Thread function, published outward.** ShurIQ's planned Gartner-style competitive-intel Substack is the DKR's research-thread loop pointed at the public.

---

## What the recon team found (every agent)

Five agents ran in parallel. Here is what each one contributed.

### RepoCartographer — mapped this repo and the DKR vision
- Confirmed the **five-function pipeline** and where each prompt lives (`IngestArticleJob`, `GenerateInsightsJob`, `search_generatable.rb`, the `parent_synthesizer` files).
- Identified the **extension surface**: model concerns (`Parentable` auto-clustering, `Embeddable`, `Broadcastable` Turbo Streams, `Linkable`, `SearchGeneratable`) — the seams where new features bolt on.
- Documented the **deployment reality**: Docker + Falcon (fiber-based async server) + Postgres/pgvector + Redis; in-process jobs (no separate worker). Deployable to any Docker host.
- Flagged the planned **Phase 2 (`Workspace` + `PromptRegistry`)** — which is exactly the "Studios = Workspaces" mechanism.

### FieldRecon — built the recent-developments timeline
- Established that **ShurIQ is the center of gravity** and that the "studios" and "startupOS" are layers of it, not separate products.
- Surfaced the **strategic pivot**: new partner Christine/Kristine Hagedorn (joined May) is driving enterprise-services → **self-serve platform**, plus the Substack authority play.
- Mapped **momentum**: Simulation Studio launched ~June 18 (6,000 audience simulations at ~90% positive engagement for the AHA pitch); the knowledge graph hit ~80,000 statements; an SDK is in progress to reduce key-person dependency.
- Mapped **the people** (see below).

### MemoryKeeper — cracked "the Forge" and pulled the deep context
- Identified **Aethelgard = "The Totem Forge"** with its architecture, status, and exact file locations — the single biggest unknown going in.
- Recovered the **ShurIQ Semantic Layer thesis**: the knowledge graph as compound intelligence at scale, aiming for ~1 billion nodes per vertical.
- Recovered the operational insight that **re-running the negative-space pipeline on a new model surfaces a genuinely different top gap** — which became a live feature (the model selector).
- Confirmed **InfraNodus** as the real gap engine behind ShurIQ (content gaps, structural gaps, topical clusters, conceptual bridges) and the UX rule to **strip knowledge-graph jargon** from anything a reader sees.
- Surfaced the **July 4, 2026 deadline**: feature-complete Totem Framework v0.1.
- Flagged that **OpenMemory's MCP server is down** (all calls time out) — likely a stopped Docker container.

### ForgeScout — mapped Aethelgard for the shared adapter
- Documented Aethelgard's **adapter pattern** (`app/services/aethelgard/adapters/`, namespaced `Aethelgard::Adapters::*`), the **`AETHELGARD_LIVE` gating logic**, and the deterministic stub-fixtures discipline.
- Found the crucial nuance: **Aethelgard calls a Python bridge** (`SHURIQ_BRIDGE_URL/analyze`) that returns a value-attestation *verdict* — a *different operation* than the DKR's gap *discovery*. This shaped the adapter design (a shared contract, not a shared file).
- Mapped the **signal → value-event flow** (`MarketSignal` → `ProcessSignalJob` → `ValueEvent`, with Letta attestation) and the HTTP conventions (HTTParty, custom error classes, 15s timeout).

### Scribe — drafted the three educational blog posts
- **The Glass Box: Why We Expose Our Prompts** — prompt transparency as trust + teaching; Engelbart's A/B/C improvement levels; the de-risking/SDK angle.
- **Negative Space: Finding What a Brand Isn't Saying** — gaps as the highest-value signal; the cluster → sparse-bridge → missing-question method; ties to the live Lens.
- **Studios Are Just Workspaces** — one graph, swappable lens; configuration-not-construction is why it scales.

---

## What we built this session

### Experiment A — the Negative Space Lens *(live locally)*
A working demonstrator of ShurIQ's flagship hook, built openly on the DKR. At `/negative-space`, it reads the existing insight library, names the most significant **blind spots** via a **fully exposed prompt**, and gives each one an **"Explore this"** button that spawns a real research thread — closing the loop live (gap → thread → sources → blind spot shrinks). A **model selector** (Gemini / Opus 4.8 / Sonnet / GPT-5 / DeepSeek) lets you re-run the same prompt and watch the top blind spot change. Verified end-to-end against the real 230-insight corpus.

### The shared InfraNodus gap adapter
The convergence point between this repo and Aethelgard's Stage-2. Built jargon's side:
- `InfranodusClient` (REST client, mirrors the existing `ExaClient`).
- `Infranodus::GapDetector` — normalized gap result, gated on `INFRANODUS_API_KEY`, with a safe stub fallback so the Lens degrades to model-only instead of failing.
- Wired into the Lens so measured structural gaps ground the prompt when InfraNodus is configured; the glass-box panel shows which.
- A written **contract** (`docs/INFRANODUS_ADAPTER.md`) so Aethelgard converges on the same interface (or we extract a shared `totem-infranodus` gem).
- Fixed a real robustness bug: the schema's question-length cap was below typical model output, silently zeroing results; relaxed and verified.

### Deploy prep — Fly.io
`fly.toml` + a step-by-step `docs/DEPLOY_FLY.md` runbook for the **first public Rails URL** in the stack (ShurIQ's pages.dev is React-only and can't host Rails). Accounts for pgvector (Fly Managed Postgres) and Redis. Needs your `fly auth` + secrets to go live.

### Records
Populated the empty `openmemory.md` as the project index; wrote a development-bench update; and recorded the integration thesis + the Aethelgard/Forge definition into persistent memory.

---

## Recent developments timeline (most recent first)

- **Jun 18** — Simulation Studio launched; 6,000-simulation AHA demo (~90% positive). Report redesign (ambient + executive views, accessibility).
- **Jun 11** — "Negative Space" framework hardened as the core differentiator; AI-education gap with clients named.
- **Jun 4** — Pitch Deck + Writing Studio in active dev; Substack publishing MVP targeted.
- **May 29** — "ShurIQ Founder OS" doc created (the startupOS layer).
- **May 30 → Jun 4** — Aethelgard Stage-1 built and verified (100 signals → 57 value events).
- **May 14/15** — Christine Hagedorn joins as partner; enterprise → self-serve pivot; Substack decision; AHA dynamic dashboard replaces a static $200k/yr report; graph hits ~80k statements.
- **May 7** — ShurIQ reports → investor pitch decks (via Limore's "Refer" test); "Capital Efficiency Score" created.
- **Apr 2** — AHA validation: live demo to AHA's CMO + AI SVP triggers a beta/design-partner request.

---

## People & ownership

- **Jonny Dubowsky** — engine/AI lead: knowledge graph, report grammar, stack-ranking, studios, the SDK. Owns the technical core.
- **Limore Shur** — client strategy, messaging, AHA/influencer programs, the "Refer" app test.
- **Kristine "KG" Hagedorn** — partner (May); product strategy + capital raising; drives the self-serve pivot; de facto product lead on Founder OS.
- **Shawn Dennis** — sales/BD; pitching the VC firm "Listen" as a paid design partner; AHA liaison.
- **Diana Horowitz** — branding + report copy.
- **Alex Ishida** — UI/UX, report/dashboard design.
- **Kevin Mowrer** — commercialization (simulation platform).
- **Nuri** — prediction-model weighting, Substack API.
- **David Muller / Itaal Shur** — Sense Collective co-founders (not active in the recent ShurIQ thread).

---

## Open decisions & next steps

1. **Deploy the Lens** — run the Fly.io runbook (needs your auth + secrets, incl. `INFRANODUS_API_KEY`).
2. **Aethelgard convergence** — add a `type: :discovery` mode to the Python bridge, or extract a shared `totem-infranodus` gem.
3. **Turn on InfraNodus** — drop `INFRANODUS_API_KEY` into `.env` and the Lens flips from model-only to graph-grounded.
4. **Next experiments** — C (Glass Box Report: every claim shows its source + generating prompt) and B (Studio = Workspace: the `Workspace`/`PromptRegistry` Phase 2).
5. **Publish the blog posts** — finalize the three drafts.
6. **Fix OpenMemory** — its MCP server is down (restart the Docker container).

**Anchor deadline: July 4, 2026 — feature-complete Totem Framework v0.1.**

---

## Key facts & figures

- Knowledge graph: **~80,000 statements** today; semantic-layer target ~1B nodes/vertical.
- AHA: dynamic dashboard replacing a **$200k/yr** static report; ~$30M/yr marketing budget.
- Proposed design-partner pricing: **$5.5k/brand/month** (VC firm "Listen").
- Aethelgard Stage-1: **100 signals → 57 value events**, behind `AETHELGARD_LIVE=false`.
- This repo: 230 insights / 181 complete roots in the local corpus.
- Live today: **`shuriq-report-studio.pages.dev`** (React/Cloudflare). Local: `/negative-space`.
