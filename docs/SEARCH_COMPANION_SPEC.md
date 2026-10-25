---
id: search-companion
type: goal-and-requirements
status: active
title: Jargon as a glass-box search companion
---

## Goal

Jargon becomes a **search and browsing companion that remembers how you got there**. You search
and read inside it (Perplexity-style), and it captures your associative trail — the sequence of
questions, pages, and ideas that led from one to the next (Bush's memex trails, Engelbart's DKR) —
connects each new page to everything you've already seen, and names the gaps in what you've
collected. It is the open, glass-box sibling of ShurIQ: every prompt that shapes what you see is
visible on the page, and editable where that's cheap. The primary user is Jonny, dogfooding daily
research; the ShurIQ/educational value follows from it being real.

Out of scope by decision: auth, billing, deployment. Stack stays Rails / Hotwire / pgvector /
RubyLLM.

## The three core flows

1. **Search & read.** Ask a question on the front door (the home page becomes the search surface).
   Exa results appear immediately. Opening a result loads it in an **in-app reader**: the existing
   ingestion pipeline (scrape → summarize → extract insights → embed) runs on it, and a "connects
   to what you've seen" panel shows its nearest neighbors in your library and in the current trail.
   The query and every page-open are recorded as trail steps.

2. **Trail review.** A **Trail** is a first-class object: a named, ordered session of steps
   (queries asked, pages opened, threads explored), revisitable and renamable. The trail page
   replays the associative sequence — what led to what — with each step linking into the global
   graph. Pages and insights also land in the library as they do today; the trail is the temporal
   layer the current app discards.

3. **Gap-directed exploration.** The Negative Space Lens, scoped to a trail or to the whole
   library, names what you *haven't* looked at. Each gap's "Explore this" spawns a research
   thread (existing Search → Exa → ingest loop), whose discoveries flow back into the library —
   gap found → thread spawned → blind spot shrinks.

Glass box across all three: every surface shows its generating prompt (the lens's `<details>`
panel pattern). Editing starts with the companion's own prompts via a small PromptRegistry —
not all five pipeline prompts — and grows from there.

## Trail capture: in-app search + reader (decided)

Considered: browser extension, in-app browser/reader, search-only.

**Decision: in-app search + reader.** You own the surface, so capture is total and needs no second
codebase: `Trail` (name, started_at) `has_many :trail_steps`; `TrailStep` (position, polymorphic
`subject`: Search / Article / Insight, `action`: searched / opened / explored). The current trail
rides in the session; a new one starts explicitly or on a fresh visit. The reader is the existing
pipeline pointed at one URL — nothing new to build for "read", only for "remember the order".

A **browser extension is a named later capability**, not a v1 goal: when it comes, it posts
visited URLs to the same trail-step endpoint, so the model doesn't change — only the capture
surface widens. Search-only was rejected because the "read" half of the trail would be invisible.

## Existing code: keep, change, cut

**Keep (the substrate — nothing here is wasted):**
- `Article`, `Insight` + all concerns (`Parentable` clustering, `Embeddable`, `Linkable`,
  `SearchGeneratable`, `Broadcastable`, `Sluggable`) — the library IS the trail's memory.
- The ingestion pipeline (`IngestArticleJob`, `GenerateInsightsJob`, `AddLinksJob`) — it becomes
  the reader's engine.
- `Search` + `SearchJob`/`SummarizeSearchJob` — the research-thread loop behind "Explore this".
- `NegativeSpaceQuery` / schema / controller / view, incl. model selector and InfraNodus grounding
  (`InfranodusClient`, `Infranodus::GapDetector`).
- `SimilarItemsQuery`, `StructuredChat`, `ExaClient`, `YoutubeClient`, `Crawl4aiClient`.

**Change:**
- **Front door**: `welcome#index` home feed is replaced by the search surface; the feed moves to a
  `/library` route.
- **`QueriesController`** (or a successor): a user query creates a trail step and shows Exa
  results *immediately* (today a query becomes a pending `Search` that auto-ingests everything;
  the companion ingests on click, not on result).
- **Article show** grows the reader framing: trail context + "connects to what you've seen" panel
  (wraps existing `find_related_items`).
- **Negative Space page**: gains trail scoping (corpus = the trail's insights) alongside the
  existing topic/library scope.
- **Prompts**: the companion-surface prompts move behind a minimal `PromptRegistry` (defaults in
  code, overrides in DB) so "editable where cheap" is real.

**Cut (nothing destructive in v1):**
- No code is deleted. Demoted: the home feed as entry point. Explicitly *not* built: auth,
  billing, deployment automation (the Fly runbook stays as a doc), the full Workspace/Studio
  system from `DKR_FUTURE_SPECIFICATION.md` (PromptRegistry is its first sliver, the rest stays
  future).

## First slice (built)

The demo slice is implemented:

- **Models**: `Trail` (`name`, auto-named from the first query, renamable) `has_many :trail_steps`
  ordered by `position`; `TrailStep` (`action`: searched/opened/explored, polymorphic `subject`,
  `query` for searched steps). Consecutive duplicates (same query, or re-opening the same page)
  are not recorded twice. The current trail rides the session (`session[:trail_id]`), created
  lazily on the first step; "Start a new trail" clears the session — empty trails are never
  created.
- **Front door** (`CompanionController#index`, root route): query → `ExaClient#search` results
  rendered with a glass-box panel stating that no prompt sits between the query and the list; a
  pasted URL skips search and opens the reader directly. Exa failures render a friendly message.
- **Open-in-reader** (`ReadingsController#create`): `Article.find_or_create_by!(url:)` — the
  existing `after_create_commit` ingestion does the rest — plus an `opened` step; the article page
  shows an "On trail" banner and already had the related-items panel.
- **Trail page** (`/trails/:id`): ordered step timeline — query chips are re-runnable searches,
  opened pages render as article cards — with inline rename.
- The old home feed lives at `/library`, linked from the sidebar.

Deliberately persisted on the trail: the query text only, not the Exa result list — results are
transient on the search page (re-running the chip re-searches).

Still open as named follow-ons: trail-scoped negative space, PromptRegistry (prompt editing),
the browser-extension trail-step endpoint, a richer `/library`, `explored` step recording when a
gap's "Explore this" is clicked from a trail context.
