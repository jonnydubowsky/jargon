# Ruby LLM Ecosystem Research

## Why Jargon's Ruby Architecture is Unique

This document explores what makes Jargon's approach to building AI-powered applications distinctive, and catalogs comparable Ruby LLM projects for Totem Protocol research.

---

## 1. The Ruby AI Landscape in 2024-2025

The Ruby ecosystem for AI/LLM development has matured significantly, offering alternatives to Python-dominated frameworks. While Python remains the default for ML research, Ruby's strengths in web application development, developer experience, and the Rails ecosystem make it compelling for **production AI applications**.

### Key Insight: Rails + LLM = Production-Ready AI Apps

Most AI application templates are:
- **JavaScript/TypeScript** (Next.js + LangChain.js)
- **Python** (FastAPI/Flask + LangChain)

Jargon demonstrates that **Ruby on Rails** provides:
- Battle-tested web framework
- Real-time features via Hotwire/ActionCable
- Elegant DSL patterns for configuration
- ActiveRecord for seamless database integration
- Convention over configuration philosophy

---

## 2. Ruby LLM Frameworks Comparison

### 2.1 RubyLLM (used by Jargon)

**Repository:** [github.com/crmne/ruby_llm](https://github.com/crmne/ruby_llm)
**Documentation:** [rubyllm.com](https://rubyllm.com/)

**Key Features:**
- Unified API for OpenAI, Anthropic, Gemini, Bedrock, OpenRouter, DeepSeek, Ollama
- Native streaming support
- Structured output via `RubyLLM::Schema`
- Rails integration with Turbo Streams
- Tool/function calling support
- Vision, audio, PDF, and image support

**Why Jargon Uses It:**
```ruby
# Clean, Ruby-like interface
RubyLLM.chat(provider: :openrouter)
       .with_schema(InsightsSchema)
       .ask(article.text)
```

**Structured Output DSL:**
```ruby
class InsightsSchema < RubyLLM::Schema
  array :insights do
    object do
      string :title, description: "3-5 word name"
      string :body, description: "200-300 char insight"
      string :snippet, description: "Source excerpt"
    end
  end
end
```

**Source:** [Introducing RubyLLM 1.0](https://paolino.me/rubyllm-1-0/)

---

### 2.2 LangChain.rb (langchainrb)

**Repository:** [github.com/patterns-ai-core/langchainrb](https://github.com/patterns-ai-core/langchainrb)

**Key Features:**
- Ruby port of LangChain concepts
- RAG (Retrieval Augmented Generation) support
- Vector database integrations (Pgvector, Pinecone, Qdrant, Weaviate)
- ActiveRecord integration via `langchainrb_rails`
- Prompt templates and chains
- Agent framework

**Comparison to Jargon's Approach:**

| Aspect | LangChain.rb | Jargon/RubyLLM |
|--------|--------------|----------------|
| Philosophy | Port Python patterns | Ruby-native design |
| Complexity | Many abstractions | Minimal, direct |
| Vector DB | Multiple options | pgvector only |
| Schema | JSON schema | Ruby DSL |
| Rails integration | Via separate gem | Native |

**When to Use LangChain.rb:**
- Complex agent workflows
- Multiple vector database backends
- Familiar with Python LangChain patterns

**Source:** [Building LLM-powered applications in Ruby](https://medium.com/@rushing_andrei/building-llm-powered-applications-in-ruby-6e16d8a17548)

---

### 2.3 FlowNodes

**Repository:** [dev.to/rjrobinson/build-llm-agents-in-ruby-with-flownodes](https://dev.to/rjrobinson/build-llm-agents-in-ruby-with-flownodes-a-langchain-alternative-41ab)

**Key Features:**
- Ruby-first workflow orchestration
- Composable node-based architecture
- Can integrate with RubyLLM
- Lightweight, no heavy dependencies

**Philosophy:**
> "You don't need LangChain. You don't need Python. You just need Ruby."

**Comparison to Jargon:**
FlowNodes focuses on workflow orchestration, while Jargon uses Rails concerns for composability. Both share the Ruby-native philosophy.

---

### 2.4 Boxcars

**Repository:** github.com/BoxcarsAI/boxcars

**Key Features:**
- LangChain-inspired composability
- SQL and ActiveRecord query generation
- Google search integration
- Natural language to database queries

**Unique Capability:**
Operating ActiveRecord with natural language—users can query databases conversationally.

**Comparison to Jargon:**
Boxcars focuses on data querying; Jargon focuses on knowledge synthesis. Potentially complementary for DKR extensions.

---

### 2.5 Aoororachain

**Focus:** Open-source LLMs, privacy, local deployment

**Key Features:**
- Emphasis on open-source models
- Local model deployment
- Privacy-first architecture

**Relevance to Totem:**
For users who want on-premise knowledge graphs without cloud LLM dependencies.

---

## 3. What Makes Jargon's Architecture Unique

### 3.1 Concern-Based DSL Architecture

Unlike most AI app templates that use service objects or procedural code, Jargon uses **Rails concerns as traits**:

```ruby
class Article < ApplicationRecord
  include Sluggable       # URL-friendly identifiers
  include Parentable      # Auto-clustering
  include Embeddable      # Vector embeddings
  include Broadcastable   # Real-time updates
  include Linkable        # Related content
  include SearchGeneratable  # Research questions

  slug -> { title }
  embeddable :summary
  parent_matching threshold: 0.3 do |candidate, distance|
    SamenessCheck.new(self, candidate, embedding_distance: distance).same?
  end
end
```

This DSL approach means:
- **Configuration is declarative**, not imperative
- **Behavior is composable** across models
- **Prompts are localized** to their domain
- **Easy to extend** without modifying core logic

### 3.2 Exposed Prompt Architecture

Most AI apps hide prompts in service classes. Jargon puts them in **discoverable, modifiable locations**:

```
app/jobs/ingest_article_job.rb      → SUMMARY_INSTRUCTIONS
app/jobs/generate_insights_job.rb   → build_prompt()
app/models/article/sameness_check.rb → Comparison prompt
app/models/concerns/search_generatable.rb → QUERIES_PROMPT
```

This enables the **second-order feedback loop** that defines DKR methodology.

### 3.3 Falcon + Async-Job Integration

Most Rails apps use:
- **Puma** (thread-based server) + **Sidekiq** (separate worker process)

Jargon uses:
- **Falcon** (fiber-based async server) + **async-job** (in-process jobs)

**Benefits:**
- No separate worker process needed
- Thousands of concurrent jobs via fibers
- Lower memory overhead (4KB/fiber vs 8KB/thread)
- Native WebSocket support for real-time updates

**Source:** [Falcon Web Server: Async Ruby in Production](https://jetthoughts.com/blog/falcon-web-server-async-ruby-in-production/)

### 3.4 pgvector for Vector Similarity

Instead of external vector databases (Pinecone, Weaviate), Jargon uses PostgreSQL's **pgvector** extension:

```sql
CREATE TABLE articles (
  embedding vector(1536),
  ...
);

-- Similarity search
SELECT * FROM articles
ORDER BY embedding <=> query_embedding
LIMIT 10;
```

**Benefits:**
- Single database for all data
- ACID transactions include embeddings
- No external service dependencies
- Full SQL power for filtering

**Source:** [RAG With PostgreSQL](https://pgdash.io/blog/rag-with-postgresql.html)

### 3.5 Real-Time Updates via Turbo Streams

Jargon uses Hotwire/Turbo for real-time UI without JavaScript framework complexity:

```ruby
# In Broadcastable concern
def broadcast_self
  broadcast_replace_later_to(
    self,
    target: page_dom_id,
    partial: page_partial,
    locals: broadcast_locals
  )
end
```

```erb
<%# In view %>
<%= subscribe_to(@article) %>
```

When an article's summary is generated asynchronously, the UI updates instantly without page refresh.

**Source:** [Streaming LLM Responses with Rails: SSE vs. Turbo Streams](https://www.aha.io/engineering/articles/streaming-llm-responses-rails-sse-turbo-streams)

---

## 4. Projects to Investigate for Totem Protocol

### 4.1 RubyLLM MCP Support

**Repository:** [github.com/patvice/ruby_llm-mcp](https://github.com/patvice/ruby_llm-mcp)

Full-featured MCP (Model Context Protocol) support for Ruby. Enables structured, composable LLM workflows—directly relevant to Totem's multi-surface integration vision.

### 4.2 Neighbor Gem (pgvector wrapper)

**Used by Jargon** for ActiveRecord integration with pgvector:
```ruby
has_neighbors :embedding
Article.nearest_neighbors(:embedding, query_vector, distance: "cosine")
```

### 4.3 Langchainrb_rails

Rails generator for LangChain.rb integration. Could provide inspiration for Totem Plugin Rails components:
```bash
rails generate langchainrb_rails:pgvector --model=Document --llm=openai
```

### 4.4 async-cable

ActionCable adapter for Falcon's async architecture. Used by Jargon for real-time updates without blocking.

### 4.5 Rumale

**Repository:** github.com/yoshoku/rumale

Traditional ML library for Ruby (sklearn-like). Reached 1.0.0 in January 2025. Could complement LLM features with classical ML (clustering, classification).

**Source:** [Ruby Machine Learning Gems in 2025](https://dev.to/daviducolo/machinelearning-with-ruby-3m75)

---

## 5. Architecture Comparison Matrix

| Feature | Jargon | Typical AI Template | LangChain.rb App |
|---------|--------|---------------------|------------------|
| **Framework** | Rails 8.1 | Next.js / FastAPI | Rails |
| **Server** | Falcon (async) | Node / Uvicorn | Puma |
| **Jobs** | async-job (in-process) | Separate worker | Sidekiq |
| **Vector DB** | pgvector | Pinecone/external | Configurable |
| **Real-time** | Turbo Streams | WebSocket/SSE | ActionCable |
| **LLM Client** | RubyLLM | LangChain.js/py | langchainrb |
| **Prompts** | Exposed in jobs | Hidden in services | In chains |
| **Composability** | Concerns (DSL) | Components | Chains |
| **Embeddings** | In-database | External service | Configurable |

---

## 6. Relevance to Totem Protocol

### 6.1 Why Ruby for DKR?

1. **Developer Experience**: Ruby's expressiveness makes prompt engineering readable
2. **Rails Conventions**: Established patterns for web apps, real-time, background jobs
3. **Composability**: Concerns enable modular, reusable AI behaviors
4. **Full-Stack**: Single codebase for frontend, backend, and AI logic
5. **Production Mature**: Rails apps serve millions of users reliably

### 6.2 Extension Opportunities

Based on ecosystem research, Totem Protocol could integrate:

| Capability | Library | Purpose |
|------------|---------|---------|
| MCP Support | ruby_llm-mcp | Multi-surface tool integration |
| Additional Vectors | langchainrb | Multiple embedding models |
| Classical ML | Rumale | Clustering, classification |
| Workflow Orchestration | FlowNodes | Complex agent pipelines |
| Local LLMs | Ollama support | Privacy-first deployments |

### 6.3 The Jargon-Totem Bridge

Jargon provides the foundation for Totem Protocol's DKR implementation:

```
JARGON                          TOTEM EXTENSION
──────                          ───────────────
5 Core Functions          →     Workspace-aware prompts
Exposed Prompts           →     Agent modification layer
pgvector embeddings       →     Cross-workspace similarity
Turbo real-time           →     Multi-surface sync
Concern-based DSL         →     Plugin architecture
```

---

## 7. Further Research Links

### Ruby LLM Libraries
- [RubyLLM Documentation](https://rubyllm.com/)
- [LangChain.rb GitHub](https://github.com/patterns-ai-core/langchainrb)
- [Building LLM Apps with Ruby (Hivekind)](https://hivekind.com/blog/building-llm-applications-with-ruby)

### Real-Time & Streaming
- [Streaming LLM Responses with Rails](https://www.aha.io/engineering/articles/streaming-llm-responses-rails-sse-turbo-streams)
- [Crafting Real-Time AI Chat with Rails](https://medium.com/@anusha.gundeti2298/crafting-a-real-time-ai-chat-application-a-deep-dive-into-ruby-on-rails-hotwire-and-stimulus-ee4d3539bbc6)

### Async & Falcon
- [Falcon Web Server](https://github.com/socketry/falcon)
- [Ruby Rogues: Falcon & Async](https://topenddevs.com/podcasts/ruby-rogues/episodes/revolutionizing-ruby-deployment-with-falcon-web-server-and-async-concurrency-framework-ruby-627)
- [Scale with Async (RubyLLM)](https://rubyllm.com/async/)

### Vector Databases
- [RAG with PostgreSQL](https://pgdash.io/blog/rag-with-postgresql.html)
- [Vector Embeddings with Ruby](https://www.rubyguides.com/2023/12/vector-embeddings-rag/)

---

## 8. Conclusion

Jargon represents a **Ruby-native approach to AI application development** that differs fundamentally from Python-centric templates. Its architecture enables:

1. **Transparent AI**: Prompts are discoverable and modifiable
2. **Composable Behavior**: Concerns provide reusable AI capabilities
3. **Production-Ready**: Built on battle-tested Rails patterns
4. **Real-Time Native**: Hotwire integration from the ground up
5. **Simplified Deployment**: Falcon + async-job eliminates infrastructure complexity

For Totem Protocol, this architecture provides the ideal foundation for implementing Doug Engelbart's DKR vision—a system where users can not only use AI tools, but observe, modify, and improve how those tools work.

---

*Research compiled for Totem Protocol / Sense Collective*
*December 2024*
