---
id: insight-save
type: module-design
status: active
title: Save insight cards to vault, InfraNodus, git, and beyond
parent: search-companion
---

## Responsibility

One **Save** action on an insight card fans out to every configured destination, each keyed by
the same stable identity (`{nanoid}`) so a re-save updates instead of duplicating. Saving is how
an insight leaves Entailment and enters the user's knowledge systems: the Obsidian vault (read by
~40 Bases dashboards), InfraNodus (the concept network), and git (durability and history).

Prototype: PR #3 (branch `cursor/insight-vault-save-a20c`, off `origin/main`) implements the vault
+ InfraNodus pair. This spec supersedes its front matter and extends it to the full destination
set and the ShurIQ contract.

## Save paths

Destinations are a registry: each is a small class under `app/models/insight/` with a uniform
`save`/`write` returning a `Result` (`status`, `message`, plus destination-specific locators).
All configured destinations fire by default; the UI offers per-save toggles and the rake task
takes `--only=` / `--skip=` flags.

### 1. Vault markdown note (the durable write / publish path)

Writes `{JARGON_VAULT_PATH}/{JARGON_VAULT_INSIGHTS_FOLDER}/{slug}.md`
(`JARGON_VAULT_INSIGHTS_FOLDER` default `Insights`). When the vault folder is under Obsidian
Sync, iCloud, or any other sync/durable-write mechanism, the file write **is** the publish — no
separate publishing step exists in this spec. Path-escape guard from PR #3 is kept: the resolved
path must stay inside `JARGON_VAULT_PATH`.

Body: the insight text (HTML stripped, `<strong>` → `**`), then an `## Evidence` section when a
source snippet exists.

### 2. InfraNodus

Create-or-update a statement on graph `INFRANODUS_GRAPH_NAME` (default `entailment-insights`),
carrying the identity token `entailment:{nanoid}` in both the statement text and its category, so
a second save updates in place. Reuses `InfranodusClient` (`lib/infranodus_client.rb`), extended
in place with `statements_for`, `update_statements`, `Error`, and `graph_name` — no second
client. When `INFRANODUS_API_KEY` is unset the destination reports `:stub` and the save
continues. Naming note: PR #3 used `jargon-insights` / `jargon:`; the product is Entailment, so
the defaults rename accordingly (configurable via env).

### 3. Git

After the vault write, a **local commit per save** in the vault's git repository:
`save(insight): {title}` with the note path. Never pushes; pushing belongs to the user's normal
sync flow. When the vault is not a git repo (or git identity is unset), the destination reports
`:skipped` and everything else still succeeds.

### 4. More destinations (extension point, designed not built)

The registry is the point. Candidates, in rough priority: clipboard copy of the markdown;
Turtle/RDF export of the projection below; webhook POST of note + front matter JSON; email. Each
is additive — a new class plus a config line, no changes to existing destinations.

## Front matter contract (`type: insight`)

The note is a new vault artifact type, `insight`, approved by the schema owner in the design
interview. Schema-is-law applies: no invented keys, no omitted required keys. Values are written
so Bases infers the right column types (dates as `YYYY-MM-DD`, lists as YAML lists, links as
`[[wikilinks]]`).

| Key | Shape | Required | Feeds |
|---|---|---|---|
| `type: insight` | const | yes | artifact registry, Bases routing |
| `id` | insight nanoid | yes | identity across all destinations |
| `created` / `modified` | `YYYY-MM-DD` | yes | base fields; `modified` bumps on re-save |
| `status` | `active \| archive \| reference` | yes | base fields |
| `origin` | `entailment` | yes | provenance |
| `tags` | list, includes `insight`, `entailment` | yes | Bases tags |
| `style_guide` | `house-voice-canon \| google-developer \| asd-ste100 \| none` | yes | writing governance (insight notes are read by people → not registry-exempt) |
| `reader` | named person or role | yes | writing governance |
| `source` / `source_title` | URL / string | when article-backed | provenance |
| `evidence_label` | `PUBLIC-VERIFIED \| REPORTED \| COMPANY-ASSERTED \| DECK-ASSERTED` | yes | evidence trail (CLM→EVD→SRC walks) |
| `dkr_relations` | list of `{to, code, note}`; `code` from the closed 10-code vocabulary | optional | OKF/DKR typed edges; RDF-star projection |
| `sbpi_dimensions` | list, subset of the five permitted SBPI dimensions | optional | SBPI conditional logic — which score an insight bears on |
| `writing_score` | number 0–1 or null | optional | writing gate result, populated **later** by scoring, never at save time |

Permitted `sbpi_dimensions` values: `Content Strength`, `Narrative Ownership`,
`Distribution Power`, `Community Strength`, `Monetization Infrastructure`.

## RDF-star / SHACL integration

- **Projection.** The front matter projects to triples: the note is a subject keyed by `id`;
  scalar keys become literal predicates; `dkr_relations` become **RDF-star quoted triples** with
  `code` as the predicate and `note`/`evidence_label` as annotations on the edge. This is what
  lets the OKF export consume saved insights without a special case.
- **Internal-only keys.** The `dkr_*` family is internal-only; the OKF export projection must
  provably drop it (existing vault rule, restated here because this spec writes `dkr_*` keys).
- **Validation.** A SHACL shape `InsightShape` validates saved notes: required properties
  present, datatypes correct, `evidence_label` and `sbpi_dimensions` within their enumerations.
  The shape ships with the implementation (Turtle file alongside the destination code) so the
  vault's shape-checking flow can pick it up.

## Behavior

- **UI:** Save button on the insight page with per-destination toggles reflecting what's
  configured; flash reports each destination's outcome in one line.
- **CLI:** `bin/rails insights:save[slug-or-nanoid]` with `--only=` / `--skip=`; exit non-zero
  only when every configured destination failed.
- **Idempotent:** vault file overwritten in place, `modified` bumped; InfraNodus update-in-place
  via the identity token; git commits only when the note content changed.
- **Failure isolation:** one destination's error never rolls back another's success; the
  aggregate result names what failed.
- **Nothing configured** → a single guidance message naming the env vars, no writes.

## Deferrals

- Bulk export (a trail, a query result set, the whole library) — the registry and identity scheme
  are designed for it; not built in this round.
- Git push to a remote.
- Auto-suggesting `dkr_relations` from embeddings/InfraNodus at save time.
- Computing `writing_score` during save (the writing gate owns that).
- Browser-extension capture endpoint (unchanged from the parent spec's deferral).

## Boundary

- **Owns:** the save fan-out, destination registry, note encoding, front matter contract,
  InfraNodus create-or-update, git commit, CLI + UI entry points.
- **Does not own:** insight creation or distillation (ingest pipeline), the vault's schema
  registry (this spec proposes one new type into it), OKF export machinery, SHACL engine, the
  writing gate that fills `writing_score`, Obsidian Sync or any sync mechanism itself.
- **Depends on:** `InfranodusClient` (extended in place), the insight's `slug`/`nanoid`
  identity, env-based configuration (`JARGON_VAULT_PATH`, `JARGON_VAULT_INSIGHTS_FOLDER`,
  `INFRANODUS_API_KEY`, `INFRANODUS_GRAPH_NAME`). Secrets stay in `.env`, never logged or
  committed.
