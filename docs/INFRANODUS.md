# Entailment ↔ InfraNodus

The Entailment library's insight corpus is mirrored into a named InfraNodus graph so you
can see the concept network visually and query it from any AI client.

**The graph:** https://infranodus.com/sensecollective/entailment-library/edit
(Graph name: `entailment-library`, account: `sensecollective`)

## What's in it

- Every **complete insight** from every **complete article** in the local library —
  362 insight statements across 65 articles at first ingest.
- Each statement is the insight's title plus body, cleaned of HTML/markdown, with the
  source article named at the end: `… (from: Article Title)`.
- First import measured: 8 topical clusters, "focused" discourse state (modularity 0.36),
  top concepts: agent, ai, ruby, insight, metaprogramming.

## Exploring it on infranodus.com

Open the graph URL and sign in as `sensecollective`.

- **Graph view**: nodes are concepts, edges are co-occurrence within a 4-word window.
  Bigger nodes = more connections. Colors = topical clusters (Louvain communities).
- **Analytics panel** (right sidebar): main topical clusters, top influential concepts,
  and **content gaps** — the structural holes between clusters. These are the same
  "negative space" the app's lens reports, computed visually over the whole library.
- **Click a node** to see every statement it appears in — each one names its source
  article, so you can trace a concept back to the reading.
- **Remove nodes** (select + hide) to re-analyze the graph without dominant concepts;
  peripheral structure surfaces.

## Querying it from an AI client

The graph is named and persistent, so any client with the InfraNodus MCP server can use
it as a knowledge base. In ThinkRail, just ask — e.g.:

- "What's in the entailment-library graph?" → reads clusters and stats
- "What are the content gaps in entailment-library?" → structural gap analysis
- "Ask entailment-library what I know about agentic UI" → GraphRAG retrieval
- "Generate research questions from the gaps in entailment-library"

Useful tools (all accept `graphName: "entailment-library"`):

| Want | Tool |
|---|---|
| Clusters, stats, gaps | `analyze_existing_graph_by_name` |
| Ask questions of the corpus | `retrieve_from_knowledge_base` |
| Research questions from gaps | `generate_research_questions` |
| Compare against new text | `difference_between_texts` / `overlap_between_texts` |
| Add more statements | `create_knowledge_graph` (appends to the same name) |

## Refreshing the corpus

Ingestion is append-only: writing to `entailment-library` again **adds** statements, it
does not replace them. To refresh:

1. Export the current corpus:

   ```bash
   bundle exec rails runner tmp/export_corpus.rb   # writes tmp/infranodus_corpus.json
   ```

2. Ask the agent to re-pipe it. For a full rebuild it will empty the graph first
   (`delete_statements` with `deleteAll`), then re-ingest — names and URL stay the same.

The export script lives at `tmp/export_corpus.rb` (gitignored). The transfer mechanism is
a briefly-public file served through Tailscale Funnel with an unguessable name, deleted
immediately after ingest; nothing is committed or left exposed.

## Setup notes (already done)

- ThinkRail MCP config: `~/.pi/agent/mcp.json`, server `infranodus`, package pinned to
  `infranodus-mcp-server@1.8.5`, API key read dynamically from the main checkout's `.env`.
- Claude Code has its own user-scope InfraNodus MCP connection with a separate key; both
  can read and write the same named graphs.
