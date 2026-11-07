# Jargon Visual Architecture Guide

## System Overview

```
                                    JARGON / SENSE COLLECTIVE
                              Dynamic Knowledge Ecosystem (DKR)

    +-----------------------------------------------------------------------------------+
    |                                                                                   |
    |   USER INPUT                          PROCESSING                    OUTPUT        |
    |   =========                           ==========                    ======        |
    |                                                                                   |
    |   +--------+     +----------------+     +----------------+     +-------------+    |
    |   |  URL   |---->|    INGEST      |---->|    EXTRACT     |---->|  ARTICLE    |    |
    |   +--------+     |  Web/YouTube   |     |  LLM Summary   |     |  + Summary  |    |
    |                  |  PDF/crawl4ai  |     |  Metadata      |     |  + Insights |    |
    |                  +----------------+     +----------------+     +-------------+    |
    |                          |                     |                      |           |
    |                          v                     v                      v           |
    |                  +----------------+     +----------------+     +-------------+    |
    |   +--------+     |    EMBED       |---->|    CLUSTER     |---->|  CONNECTED  |    |
    |   |Question|---->|  Vector 1536   |     |  Auto-group    |     |  KNOWLEDGE  |    |
    |   +--------+     |  pgvector      |     |  Synthesize    |     |  GRAPH      |    |
    |                  +----------------+     +----------------+     +-------------+    |
    |                          |                     |                      |           |
    |                          v                     v                      v           |
    |                  +----------------+     +----------------+     +-------------+    |
    |                  |    SEARCH      |---->|   SYNTHESIZE   |---->|  RESEARCH   |    |
    |                  |  Exa neural    |     |  LLM summary   |     |  THREADS    |    |
    |                  |  Select best   |     |  Follow-ups    |     |  (recursive)|    |
    |                  +----------------+     +----------------+     +-------------+    |
    |                                                                                   |
    +-----------------------------------------------------------------------------------+
```

---

## Core Data Model

```
    +========================================================================================+
    |                                    DATA MODEL                                          |
    +========================================================================================+

                                      +------------------+
                                      |     ARTICLE      |
                                      |------------------|
                                      | id               |
                                      | title            |
                                      | url (unique)     |
                                      | summary (LLM)    |
                                      | text (scraped)   |
                                      | embedding[1536]  |
                                      | status           |
                                      | parent_id -------|----+  (clustering)
                                      +------------------+    |
                                             |                |
                     +-----------------------+                |
                     |                                        |
                     | has_many                               v
                     v                                +------------------+
              +------------------+                    | ARTICLE (Parent) |
              |     INSIGHT      |                    |------------------|
              |------------------|                    | url = nil        |
              | id               |                    | children[]       |
              | article_id ------|---> Article        | synthesized      |
              | title            |                    +------------------+
              | body (LLM)       |
              | snippet (source) |
              | embedding[1536]  |
              | parent_id -------|----+  (clustering)
              +------------------+    |
                                      |
                                      v
                              +------------------+
                              | INSIGHT (Parent) |
                              |------------------|
                              | article_id = nil |
                              | children[]       |
                              | synthesized      |
                              +------------------+


              +------------------+         +------------------+
              |     SEARCH       |<--------|  SEARCH_ARTICLE  |
              |------------------|  many   |------------------|
              | id               |         | search_id -------|---> Search
              | query (user)     |         | article_id ------|---> Article
              | search_query     |         +------------------+
              | summary (LLM)    |
              | embedding[1536]  |
              | source_type -----|---> Article | Insight | Search (polymorphic)
              | source_id        |
              +------------------+
                     |
                     | has_many :searches (recursive)
                     v
              +------------------+
              | FOLLOW-UP SEARCH |
              +------------------+
```

---

## Article Ingestion Pipeline

```
    USER SUBMITS URL
           |
           v
    +----------------------------------------------+
    | QueriesController                            |
    | POST /queries                                |
    |----------------------------------------------|
    | Article.find_or_create_by!(url: params[:q])  |
    +----------------------------------------------+
           |
           | after_create_commit
           v
    +======================================================+
    |              IngestArticleJob                         |
    +======================================================+
           |
           +------------------+------------------+
           |                                     |
           v                                     v
    +----------------+                  +----------------+
    | YouTube URL?   |                  | Web URL        |
    |----------------|                  |----------------|
    | YoutubeClient  |                  | ExaClient.crawl|
    | .fetch()       |                  | or crawl4ai   |
    +----------------+                  +----------------+
           |                                     |
           v                                     v
    +----------------+                  +----------------+
    | VideoMetadata  |                  | ContentEval    |
    | Schema         |                  | Schema         |
    |----------------|                  |----------------|
    | - speaker      |                  | - content_type |
    | - summary      |                  | - is_paper?    |
    +----------------+                  | - full_text_url|
           |                            +----------------+
           |                                     |
           +------------------+------------------+
                              |
                              v
                    +------------------+
                    | ArticleMetadata  |
                    | Schema           |
                    |------------------|
                    | - title          |
                    | - author         |
                    | - published_at   |
                    +------------------+
                              |
                              v
                    +------------------+
                    | ArticleSummary   |
                    | Schema           |
                    |------------------|
                    | 200-300 chars    |
                    | with <strong>    |
                    | "State directly" |
                    +------------------+
                              |
                              v
    +======================================================+
    |                   FINALIZATION                        |
    +======================================================+
           |
           +---> generate_embedding!() --> pgvector[1536]
           |
           +---> find_similar_and_absorb!() --> Clustering
           |           |
           |           +---> Match found? --> become_child_of! or create_parent_with!
           |           |
           |           +---> regenerate_metadata!() --> ParentSynthesizer
           |
           +---> generate_searches!(count: 2) --> Research questions
           |
           +---> GenerateInsightsJob.perform_later()
           |
           +---> broadcast_self() --> Real-time UI update
```

---

## Insight Extraction Flow

```
    +======================================================+
    |              GenerateInsightsJob                      |
    +======================================================+
           |
           | article.text
           v
    +------------------+
    | Prompt Selection |
    +------------------+
           |
           +---> Full Article: "Extract key insights..."
           |
           +---> Video/Podcast: "Clean transcript artifacts..."
           |
           +---> Partial: "Infer ONE key insight..."
           |
           v
    +----------------------------------------------+
    | InsightsSchema                               |
    |----------------------------------------------|
    | {                                            |
    |   insights: [                                |
    |     {                                        |
    |       title: "3-5 word name",                |
    |       body: "200-300 chars <strong>",        |
    |       snippet: "Source excerpt..."           |
    |     }                                        |
    |   ]                                          |
    | }                                            |
    +----------------------------------------------+
           |
           | For each insight:
           v
    +======================================================+
    |                  PER-INSIGHT LOOP                     |
    +======================================================+
           |
           +---> Create Insight record
           |
           +---> generate_embedding!()
           |           |
           |           v
           |     LLM.embed(body) --> embedding[1536]
           |
           +---> find_similar_and_absorb!()
           |           |
           |           v
           |     +------------------+
           |     | Parentable       |
           |     |------------------|
           |     | threshold: 0.25  |
           |     | peer_scope:      |
           |     |   exclude same   |
           |     |   article        |
           |     +------------------+
           |           |
           |           +---> Match? --> Insight::ParentSynthesizer
           |                           "Synthesize into ONE canonical insight"
           |
           +---> generate_searches!(count: 2)
           |
           +---> AddLinksJob.set(wait: 30.seconds)
                        |
                        v
                  Add internal links: [text](insight:slug)
```

---

## Search & Research Thread Flow

```
    USER SUBMITS QUESTION
           |
           v
    +----------------------------------------------+
    | QueriesController                            |
    |----------------------------------------------|
    | Search.create!(query: params[:q], source:)   |
    | SearchJob.perform_later(search)              |
    +----------------------------------------------+
           |
           v
    +======================================================+
    |                    SearchJob                          |
    +======================================================+
           |
           +---> generate_search_query_and_embedding!()
           |           |
           |           v
           |     Transform user query --> optimized search query
           |     Generate embedding for similarity search
           |
           +---> ExaClient.search(search_query)
           |           |
           |           v
           |     Neural search returns ~10 candidates
           |
           +---> SelectedArticlesSchema (LLM filters)
           |           |
           |           v
           |     "Select 1-3 best articles"
           |     "Prefer diversity, exclude PDFs"
           |
           +---> For each selected:
           |           |
           |           v
           |     Article.find_or_create_by!(url:)
           |     SearchArticle.find_or_create_by!
           |
           +---> ready_to_summarize?()
                        |
                        v
                 all_articles_resolved? && viable_content?
                        |
                        v
    +======================================================+
    |               SummarizeSearchJob                      |
    +======================================================+
           |
           +---> aggregate_content()
           |           |
           |           +---> User's original query
           |           +---> Optimized search query
           |           +---> Article summaries
           |           +---> Top 5 insights per article
           |           +---> Related library items (vector search)
           |
           +---> SummarizeSearchSchema (LLM synthesis)
           |           |
           |           v
           |     +----------------------------------+
           |     | {                                |
           |     |   summary: "2-4 sentences",      |
           |     |   snippet: "Key quote <strong>", |
           |     |   followup_queries: [            |
           |     |     "Question 1 (~60 chars)",    |
           |     |     "Question 2 (~60 chars)"     |
           |     |   ]                              |
           |     | }                                |
           |     +----------------------------------+
           |
           +---> Update search: summary, snippet, status=complete
           |
           +---> generate_embedding!() on summary
           |
           +---> Create follow-up Search records
           |           |
           |           v
           |     +---> SearchJob (RECURSIVE!)
           |     +---> SearchJob (RECURSIVE!)
           |
           +---> AddLinksJob.perform_now(search)
```

---

## Auto-Clustering (Parentable Concern)

```
    NEW RECORD WITH EMBEDDING
           |
           v
    +----------------------------------------------+
    |          find_similar_and_absorb!()          |
    +----------------------------------------------+
           |
           +---> Has parent already? --> STOP
           |
           +---> Has embedding? --> No --> STOP
           |
           v
    +======================================================+
    |              FIND PARENT MATCH                        |
    +======================================================+
           |
           +---> Query parents_only scope
           |           (records that have children)
           |
           +---> nearest_neighbors(:embedding, cosine)
           |
           +---> distance < threshold? (0.3 for articles, 0.25 for insights)
           |           |
           |           +---> No --> Try peer match
           |           |
           |           +---> Yes --> Custom matching check?
           |                               |
           |                               +---> Article: SamenessCheck
           |                               |     "Are these the SAME article?"
           |                               |     (title similarity + LLM confirm)
           |                               |
           |                               +---> Pass --> MATCH FOUND
           |                               +---> Fail --> Try peer match
           |
           v
    +======================================================+
    |               FIND PEER MATCH                         |
    +======================================================+
           |
           +---> Query roots scope (no parent)
           |
           +---> Apply peer_scope filter
           |           (Insight: exclude same article)
           |
           +---> nearest_neighbors(:embedding, cosine)
           |
           +---> distance < threshold?
           |           |
           |           +---> No --> NO MATCH, continue
           |           |
           |           +---> Yes --> MATCH FOUND
           |
           v
    +======================================================+
    |                 CLUSTERING ACTION                     |
    +======================================================+
           |
           +---> Match has children?
           |           |
           |           +---> Yes --> become_child_of!(match)
           |           |
           |           +---> No --> Match has parent?
           |                               |
           |                               +---> Yes --> become_child_of!(match.parent)
           |                               |
           |                               +---> No --> create_parent_with!(match)
           |
           v
    +----------------------------------------------+
    |             POST-CLUSTERING                  |
    +----------------------------------------------+
           |
           +---> reparent_references()
           |           (Update Search, SearchArticle FKs)
           |
           +---> regenerate_metadata!()
           |           |
           |           v
           |     ParentSynthesizer.new(children).synthesize
           |           |
           |           v
           |     +----------------------------------+
           |     | Article: "Canonical title"       |
           |     | Insight: "Synthesized insight"   |
           |     +----------------------------------+
           |
           +---> broadcast_self()
```

---

## Real-Time Updates (Broadcastable)

```
    +======================================================+
    |                  MODEL CHANGES                        |
    +======================================================+
           |
           | after_commit callback
           v
    +----------------------------------------------+
    |            Broadcastable concern             |
    +----------------------------------------------+
           |
           +---> broadcast_self()
                        |
                        +---> broadcast_page()
                        |           |
                        |           v
                        |     target: "article_123_page"
                        |     partial: "articles/article_page"
                        |
                        +---> broadcast_card()
                        |           |
                        |           v
                        |     target: "article_123"
                        |     partial: "articles/article"
                        |
                        +---> broadcast_to_parents()
                                    |
                                    v
                              containing_searches.each(&:broadcast_self)
                              article&.broadcast_self


    +======================================================+
    |               TURBO STREAM FLOW                       |
    +======================================================+


      RAILS SERVER                    REDIS                    BROWSER
           |                            |                         |
           |                            |      subscribe_to()     |
           |                            |<------------------------|
           |                            |                         |
           | broadcast_replace_later_to |                         |
           |--------------------------->|                         |
           |                            |                         |
           |                            |    Turbo Stream HTML    |
           |                            |------------------------>|
           |                            |                         |
           |                            |                  [DOM replaced]
           |                            |                  [No page reload]
```

---

## LLM Integration Map

```
    +======================================================+
    |                 LLM INTEGRATION POINTS                |
    +======================================================+


    +--------------------------------+    +--------------------------------+
    |     IngestArticleJob           |    |    GenerateInsightsJob         |
    |--------------------------------|    |--------------------------------|
    | ContentEvaluationSchema        |    | InsightsSchema                 |
    |   "Classify content type"      |    |   "Extract key ideas"          |
    |                                |    |   - title: 3-5 words           |
    | VideoMetadataSchema            |    |   - body: 200-300 chars        |
    |   "Extract speaker, not        |    |   - snippet: source excerpt    |
    |    channel"                    |    |                                |
    |                                |    | Prompts vary by content_type:  |
    | ArticleMetadataSchema          |    |   - full article               |
    |   "Extract title, author,      |    |   - video/podcast              |
    |    date"                       |    |   - partial/abstract           |
    |                                |    +--------------------------------+
    | ArticleSummarySchema           |
    |   "200-300 chars, <strong>,    |
    |    state finding directly"     |
    +--------------------------------+


    +--------------------------------+    +--------------------------------+
    |         SearchJob              |    |     SummarizeSearchJob         |
    |--------------------------------|    |--------------------------------|
    | SelectedArticlesSchema         |    | SummarizeSearchSchema          |
    |   "Select 1-3 best articles"   |    |   "2-4 sentence synthesis"     |
    |   "Prefer diversity"           |    |   - summary                    |
    |   "Exclude PDFs"               |    |   - snippet with <strong>      |
    |                                |    |   - 2 follow-up queries        |
    +--------------------------------+    +--------------------------------+


    +--------------------------------+    +--------------------------------+
    |        AddLinksJob             |    |   SearchGeneratable concern    |
    |--------------------------------|    |--------------------------------|
    | Free-form prompt               |    | SearchQueriesSchema            |
    |   "Add internal links"         |    |   "Generate research           |
    |   "[text](insight:slug)"       |    |    questions to explore        |
    |   "Don't change words"         |    |    this topic further"         |
    +--------------------------------+    +--------------------------------+


    +--------------------------------+    +--------------------------------+
    |   Article::SamenessCheck       |    |   Article::ParentSynthesizer   |
    |--------------------------------|    |--------------------------------|
    | Schema: same_article, reason   |    | Schema: name, summary          |
    |   "Are these the SAME          |    |   "Canonical title for         |
    |    article?"                   |    |    cluster"                    |
    |   Uses: title similarity +     |    |   "100-300 char summary"       |
    |         LLM confirmation       |    +--------------------------------+
    +--------------------------------+
                                          +--------------------------------+
                                          |   Insight::ParentSynthesizer   |
                                          |--------------------------------|
                                          | Schema: title, body, snippet   |
                                          |   "Synthesize into ONE         |
                                          |    canonical insight"          |
                                          |   "Incorporate nuance from     |
                                          |    all variations"             |
                                          +--------------------------------+


    +======================================================+
    |                  LLM CONFIGURATION                    |
    +======================================================+

    config/initializers/ruby_llm.rb

    +--------------------------------+
    | Chat Model:                    |
    |   google/gemini-2.5-flash      |
    |   via OpenRouter               |
    |                                |
    | Embedding Model:               |
    |   openai/text-embedding-3-small|
    |   1536 dimensions              |
    |   via OpenRouter               |
    +--------------------------------+
```

---

## Concerns Architecture (Traits)

```
    +======================================================+
    |               ARTICLE / INSIGHT / SEARCH              |
    |                   (Rich Domain Models)                |
    +======================================================+
                              |
          +-------------------+-------------------+
          |                   |                   |
          v                   v                   v
    +----------+        +----------+        +----------+
    | Sluggable|        |Parentable|        |Embeddable|
    +----------+        +----------+        +----------+
    | slug     |        | parent_id|        | embedding|
    | nanoid   |        | children |        +----------+
    +----------+        +----------+        | generate_|
    | to_param |        | find_    |        | embedding|
    | resolve_ |        | similar_ |        | !()      |
    | identifier|       | and_     |        +----------+
    +----------+        | absorb!  |
                        +----------+
          |                   |                   |
          v                   v                   v
    +----------+        +----------+        +----------+
    |Broadcast-|        | Linkable |        | Search-  |
    | able     |        +----------+        |Generatabl|
    +----------+        | linkable_|        +----------+
    | broadcast|        | insights |        | generate_|
    | _self()  |        +----------+        | searches!|
    | broadcast|                            +----------+
    | _page()  |
    | broadcast|        +----------+
    | _card()  |        |Normalizes|
    +----------+        | Markup   |
                        +----------+
                        | **text** |
                        |   -->    |
                        | <strong> |
                        +----------+


    +======================================================+
    |                    DSL USAGE                          |
    +======================================================+

    class Article < ApplicationRecord
      include Sluggable
      include Parentable
      include Embeddable
      include Broadcastable
      include Linkable
      include SearchGeneratable
      include NormalizesMarkup

      slug -> { title }                    # Sluggable DSL
      embeddable :summary                  # Embeddable DSL
      normalizes_markup :summary           # NormalizesMarkup DSL

      parent_matching threshold: 0.3 do |candidate, distance|
        SamenessCheck.new(self, candidate, embedding_distance: distance).same?
      end                                  # Parentable DSL

      reparents Search, foreign_key: :source_id
      reparents Insight, foreign_key: :article_id
      reparents SearchArticle, foreign_key: :article_id
                                           # Parentable DSL

      search_context -> { "Title: #{title}\nSummary: #{summary}" }
                                           # SearchGeneratable DSL
    end
```

---

## Extension Points for DKR Prototype

```
    +======================================================+
    |              CURRENT JARGON ARCHITECTURE              |
    +======================================================+

    +-------------+     +-------------+     +-------------+
    |   Article   |---->|   Insight   |---->|   Search    |
    | (source)    |     | (extracted) |     | (research)  |
    +-------------+     +-------------+     +-------------+
           |                   |                   |
           v                   v                   v
    +-------------+     +-------------+     +-------------+
    |  Embedding  |     |  Embedding  |     |  Embedding  |
    |  [1536]     |     |  [1536]     |     |  [1536]     |
    +-------------+     +-------------+     +-------------+
           |                   |                   |
           +-------------------+-------------------+
                              |
                              v
                    +-------------------+
                    |  Vector Similarity|
                    |  (pgvector)       |
                    +-------------------+


    +======================================================+
    |                DKR EXTENSION POINTS                   |
    +======================================================+

    1. NEW CONTENT SOURCES
    +----------------------------------------------------------+
    |                                                          |
    |  +-------------+  +-------------+  +-------------+       |
    |  | Obsidian    |  | Roam        |  | Notion      |       |
    |  | Notes       |  | Pages       |  | Docs        |       |
    |  +-------------+  +-------------+  +-------------+       |
    |        |                |                |               |
    |        v                v                v               |
    |  +--------------------------------------------------+   |
    |  |          IngestObsidianNoteJob                   |   |
    |  |          IngestRoamPageJob                       |   |
    |  |          IngestNotionDocJob                      |   |
    |  +--------------------------------------------------+   |
    |                                                          |
    +----------------------------------------------------------+

    2. AI AGENTS
    +----------------------------------------------------------+
    |                                                          |
    |  +-------------+  +-------------+  +-------------+       |
    |  | DKR         |  | Matchmaking |  | Gap         |       |
    |  | Synthesis   |  | Agent       |  | Analysis    |       |
    |  | Agent       |  |             |  | Agent       |       |
    |  +-------------+  +-------------+  +-------------+       |
    |        |                |                |               |
    |        v                v                v               |
    |  +--------------------------------------------------+   |
    |  |           AgentCapable concern                   |   |
    |  |           Custom schemas per agent               |   |
    |  |           Workspace-scoped execution             |   |
    |  +--------------------------------------------------+   |
    |                                                          |
    +----------------------------------------------------------+

    3. EXPORT FORMATS
    +----------------------------------------------------------+
    |                                                          |
    |  +-------------+  +-------------+  +-------------+       |
    |  | Obsidian    |  | Roam        |  | GraphML     |       |
    |  | Markdown    |  | EDN         |  |             |       |
    |  +-------------+  +-------------+  +-------------+       |
    |        |                |                |               |
    |        v                v                v               |
    |  +--------------------------------------------------+   |
    |  |           Exportable concern                     |   |
    |  |           to_obsidian_markdown                   |   |
    |  |           to_roam_edn                            |   |
    |  |           to_graphml                             |   |
    |  +--------------------------------------------------+   |
    |                                                          |
    +----------------------------------------------------------+

    4. EXTERNAL INTEGRATION
    +----------------------------------------------------------+
    |                                                          |
    |  +-------------+  +-------------+  +-------------+       |
    |  | REST API    |  | MCP Server  |  | Webhooks    |       |
    |  | v1          |  |             |  |             |       |
    |  +-------------+  +-------------+  +-------------+       |
    |        |                |                |               |
    |        v                v                v               |
    |  +--------------------------------------------------+   |
    |  |    Api::V1::ArticlesController                   |   |
    |  |    TotemMcpServer                                |   |
    |  |    WebhookDeliveryJob                            |   |
    |  +--------------------------------------------------+   |
    |                                                          |
    +----------------------------------------------------------+

    5. MULTI-USER / WORKSPACE
    +----------------------------------------------------------+
    |                                                          |
    |  +--------------------------------------------------+   |
    |  |                    Workspace                     |   |
    |  +--------------------------------------------------+   |
    |        |                |                |               |
    |        v                v                v               |
    |  +-------------+  +-------------+  +-------------+       |
    |  | User A's    |  | User B's    |  | Shared      |       |
    |  | Articles    |  | Articles    |  | Articles    |       |
    |  | Insights    |  | Insights    |  | Insights    |       |
    |  +-------------+  +-------------+  +-------------+       |
    |        |                |                |               |
    |        v                v                v               |
    |  +--------------------------------------------------+   |
    |  |           WorkspaceScoped concern                |   |
    |  |           Cross-vault knowledge sharing          |   |
    |  |           Project-based contexts                 |   |
    |  +--------------------------------------------------+   |
    |                                                          |
    +----------------------------------------------------------+
```

---

## File Structure Quick Reference

```
    jargon/
    +-- app/
    |   +-- models/
    |   |   +-- article.rb                 # Core article entity
    |   |   +-- insight.rb                 # Extracted insight entity
    |   |   +-- search.rb                  # Research query + results
    |   |   +-- search_article.rb          # Junction table
    |   |   +-- structured_chat.rb         # LLM schema wrapper
    |   |   +-- article/
    |   |   |   +-- parent_synthesizer.rb  # Cluster synthesis
    |   |   |   +-- sameness_check.rb      # Duplicate detection
    |   |   +-- insight/
    |   |   |   +-- parent_synthesizer.rb  # Insight synthesis
    |   |   +-- concerns/
    |   |       +-- sluggable.rb           # URL slugs
    |   |       +-- parentable.rb          # Parent-child clustering
    |   |       +-- embeddable.rb          # Vector embeddings
    |   |       +-- broadcastable.rb       # Real-time updates
    |   |       +-- linkable.rb            # Related insights
    |   |       +-- search_generatable.rb  # Research questions
    |   |       +-- normalizes_markup.rb   # Markup normalization
    |   |
    |   +-- jobs/
    |   |   +-- ingest_article_job.rb      # Content scraping
    |   |   +-- generate_insights_job.rb   # Insight extraction
    |   |   +-- search_job.rb              # Neural search
    |   |   +-- summarize_search_job.rb    # Result synthesis
    |   |   +-- add_links_job.rb           # Internal linking
    |   |
    |   +-- schemas/
    |   |   +-- article_summary_schema.rb
    |   |   +-- insights_schema.rb
    |   |   +-- summarize_search_schema.rb
    |   |   +-- content_evaluation_schema.rb
    |   |   +-- ...
    |   |
    |   +-- controllers/
    |   +-- views/
    |   +-- queries/
    |       +-- home_feed_query.rb
    |       +-- similar_items_query.rb
    |
    +-- lib/
    |   +-- exa_client.rb                  # Exa neural search
    |   +-- youtube_client.rb              # YouTube transcripts
    |   +-- crawl4ai_client.rb             # Fallback crawler
    |
    +-- config/
    |   +-- initializers/ruby_llm.rb       # LLM configuration
    |   +-- cable.yml                      # ActionCable/Redis
    |   +-- routes.rb
    |
    +-- db/
        +-- structure.sql                  # PostgreSQL + pgvector
```

---

*Generated for Totem Protocol / DKR Prototype Development*
