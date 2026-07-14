# Shared InfraNodus Gap Adapter — Contract

Two repos in the stack need InfraNodus gap detection:

- **Jargon (this repo)** — *discovery*: "What are the structural gaps in this corpus?"
  → a list of gaps. Powers the Negative Space Lens.
- **Aethelgard / the Forge** — *verdict*: "Did this incoming signal close a structural
  gap in the graph?" → a boolean + resource class. Powers REA value attestation
  (`ProcessSignalJob` → `ValueEvent`).

These are two faces of one capability. Rather than a literally-shared code file across
two independent git repos (premature), they share a **contract**: the same gating
discipline, the same stub-fallback discipline, and a normalized gap shape. When it
stabilizes, extract to a gem (`totem-infranodus`).

## Gating discipline (both repos)

An adapter goes live **only when configured**, and degrades safely otherwise — never
hard-fails on a missing key or an unreachable endpoint.

- Jargon: live when `INFRANODUS_API_KEY` is set; otherwise a stub result
  (`source: :stub`, empty gaps) and the Lens falls back to model-only analysis.
- Aethelgard: live when `AETHELGARD_LIVE=true` **and** `AETHELGARD_INFRANODUS_LIVE=true`
  **and** `SHURIQ_BRIDGE_URL` is set; otherwise `Aethelgard::Fixtures` deterministic stub.

## Transport (they differ today — that's fine)

- **Jargon** calls the InfraNodus REST API directly:
  `POST https://infranodus.com/api/v1/graphAndStatements`, `Authorization: Bearer <key>`,
  body `{name, text, aiTopics: true}`. Gaps live at
  `entriesAndGraphOfContext.extendedGraphSummary.contentGaps` (fallback:
  `extendedGraphSummary.contentGaps`); modularity at
  `graph.graphologyGraph.attributes.modularity`. Each `contentGaps` entry is a string:
  `"Gap N: ClusterA (terms) -> ClusterB (terms)"`.
- **Aethelgard** calls its Python bridge (`{SHURIQ_BRIDGE_URL}/analyze`, HTTParty), which
  wraps InfraNodus and returns a value-attestation verdict
  (`{structural_gap_closed, gap_id, resource_class, modularity, ...}`).

Convergence path: the Python bridge can expose a `type: :discovery` mode returning the
normalized gap list below, at which point both repos call the same endpoint; or Jargon's
`InfranodusClient` is extracted to the shared gem and the bridge calls it. Either way the
**normalized shape is the stable interface.**

## Normalized gap shape

```
Gap(from_topic:, to_topic:, terms:, raw:)        # a structural gap = an under-connected cluster pair
Result(gaps:, main_topics:, modularity:, source:)  # source ∈ {:infranodus, :stub}
  #=> grounded? == (source == :infranodus)
```

Aethelgard's verdict (`structural_gap_closed`, `resource_class`, `gap_id`) is a
*reduction* of the same data for the single-signal case; it can be derived from a
`Result` (a non-empty `gaps` for the signal's text ⇒ gap closed).

## Jargon implementation (reference)

- `lib/infranodus_client.rb` — `InfranodusClient` (HTTPX, bearer, `#graph_and_statements`).
- `lib/infranodus/gap_detector.rb` — `Infranodus::GapDetector#detect(text:, name:)`
  → `Result`. Parses `contentGaps`, gates on `#available?`, stubs otherwise, raises
  `Infranodus::Error` on transport/parse failure.
- `app/queries/negative_space_query.rb` — consumes the detector: when grounded, the
  measured structural gaps are fed into the (exposed) prompt; otherwise model-only.

## ENV

| Var | Repo | Meaning |
|-----|------|---------|
| `INFRANODUS_API_KEY` | Jargon | InfraNodus REST token (https://infranodus.com/api-access) |
| `AETHELGARD_LIVE` | Aethelgard | Master switch (default false) |
| `AETHELGARD_INFRANODUS_LIVE` | Aethelgard | Per-adapter switch |
| `SHURIQ_BRIDGE_URL` | Aethelgard | Python InfraNodus bridge base URL |
