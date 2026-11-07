# Jargon DKR Documentation

> **Sense Collective / Totem Protocol**
>
> Dynamic Knowledge Repository Architecture & Future Vision

---

## Documentation Index

### Core Architecture
| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Complete technical architecture analysis including data models, flows, and extension points |
| [DIAGRAMS.md](DIAGRAMS.md) | Mermaid diagrams for all system components (18 diagrams) |
| [VISUAL_ARCHITECTURE.md](VISUAL_ARCHITECTURE.md) | ASCII art diagrams for universal compatibility |

### Totem Protocol Vision
| Document | Description |
|----------|-------------|
| [DKR_FUTURE_SPECIFICATION.md](DKR_FUTURE_SPECIFICATION.md) | Future roadmap implementing Engelbart's DKR methodology |
| [RUBY_LLM_ECOSYSTEM.md](RUBY_LLM_ECOSYSTEM.md) | Research on Ruby AI/LLM frameworks and why Jargon's approach is unique |

---

## Quick Start: Understanding Jargon

### The Five Core Functions

```
1. INGEST   → Content scraped and parsed (web, YouTube, PDF)
2. SUMMARIZE → AI distills key points (200-300 char summaries)
3. EXTRACT  → Insights become linked cards (auto-extracted ideas)
4. CONNECT  → Similar content clusters (pgvector embeddings)
5. THREAD   → Research questions find more (recursive search)
```

### Why This Architecture Matters

Unlike Perplexity.ai and other AI tools:
- **Prompts are exposed** - You can observe and modify AI behavior
- **Knowledge persists** - Artifacts accumulate, don't disappear
- **Connections are automatic** - Embeddings link related content
- **Research is recursive** - Follow-up questions create knowledge trees

This enables **second-order feedback loops** (Engelbart's DKR):
- A-Level: Use the tool to do knowledge work
- B-Level: Modify the tool to do knowledge work better
- C-Level: Learn from modifications to improve the improvement process

---

## Key Technical Decisions

| Choice | Why |
|--------|-----|
| **Ruby/Rails** | Mature ecosystem, elegant DSL, real-time via Hotwire |
| **RubyLLM** | Clean Ruby API, structured output, multi-provider |
| **pgvector** | Single DB for all data, SQL power, no external deps |
| **Falcon** | Async fibers, in-process jobs, efficient concurrency |
| **Concerns** | Composable behaviors, declarative configuration |

---

## Prompt Locations (For Modification)

```
app/jobs/ingest_article_job.rb:4      → SUMMARY_INSTRUCTIONS
app/jobs/ingest_article_job.rb:16     → CONTENT_EVALUATION_INSTRUCTIONS
app/jobs/generate_insights_job.rb:40  → build_prompt() (insight extraction)
app/models/concerns/search_generatable.rb:8 → QUERIES_PROMPT
app/models/article/sameness_check.rb:34     → Duplicate detection
app/models/article/parent_synthesizer.rb:11 → Cluster synthesis
app/models/insight/parent_synthesizer.rb:11 → Insight synthesis
```

---

## Totem Protocol Integration Points

Jargon is one surface in the Totem Protocol ecosystem:

```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ Jargon DKR  │  │ GenAI Studio│  │ Obsidian    │
│ (this app)  │  │             │  │ Plugin      │
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                │
       └────────────────┴────────────────┘
                        │
                        ▼
              ┌─────────────────┐
              │ Totem Protocol  │
              │ - OAuth Identity│
              │ - Artifact Store│
              │ - Letta Agents  │
              └─────────────────┘
```

---

## Educational Framework: Mental Modelling Agency

The documentation supports a curriculum for teaching:

1. **Understanding Feedback Loops** - Map knowledge workflows
2. **The DKR Pipeline** - Observe prompt → output relationships
3. **Second-Order Improvement** - Modify and measure
4. **Context Engineering** - Design workspace-aware systems
5. **Agent Design** - Build observation and modification agents
6. **Integration Patterns** - Connect across surfaces

---

## Viewing the Diagrams

### Mermaid Diagrams (DIAGRAMS.md)

**GitHub**: Renders automatically

**VS Code**: Install "Markdown Preview Mermaid Support" extension

**Obsidian**: Built-in support

**Export to PNG**:
```bash
npm install -g @mermaid-js/mermaid-cli
mmdc -i docs/DIAGRAMS.md -o docs/images/ -e png
```

### ASCII Diagrams (VISUAL_ARCHITECTURE.md)

Works in any text viewer, terminal, or basic markdown renderer.

---

## Further Development

See [DKR_FUTURE_SPECIFICATION.md](DKR_FUTURE_SPECIFICATION.md) for:
- Workspace-aware prompt modification
- Letta agent integration
- Multi-surface synchronization
- Implementation roadmap

---

*Sense Collective / Totem Protocol*
*December 2024*
