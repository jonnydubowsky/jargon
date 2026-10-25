# Jargon (Sense Collective) - Complete Architecture Analysis

> **Totem Protocol Foundation Document**
>
> This architecture analysis documents Jargon's design as the foundation for implementing Doug Engelbart's Dynamic Knowledge Repository (DKR) methodology. The exposed prompt architecture enables second-order feedback loops in knowledge work—a core pillar of the Totem Protocol vision.
>
> Related Documents:
> - [DKR Future Specification](DKR_FUTURE_SPECIFICATION.md)
> - [Ruby LLM Ecosystem Research](RUBY_LLM_ECOSYSTEM.md)
> - [Visual Diagrams](DIAGRAMS.md)

## Table of Contents
1. [System Overview](#1-system-overview)
2. [Domain Model & Entity Relationships](#2-domain-model--entity-relationships)
3. [Data Flow Diagrams](#3-data-flow-diagrams)
4. [LLM Integration Points](#4-llm-integration-points)
5. [Real-Time Architecture](#5-real-time-architecture)
6. [State Storage & Data Locations](#6-state-storage--data-locations)
7. [Extension Points for DKR](#7-extension-points-for-dkr)
8. [File Reference](#8-file-reference)
9. [Totem Protocol Integration](#9-totem-protocol-integration)

---

## 1. System Overview

### Tech Stack
```
+------------------+     +------------------+     +------------------+
|   Frontend       |     |   Backend        |     |   External       |
+------------------+     +------------------+     +------------------+
| Hotwire/Turbo    |     | Rails 8.1        |     | Exa API          |
| Stimulus.js      |<--->| Falcon (async)   |<--->| OpenRouter/OpenAI|
| Tailwind CSS     |     | async-job        |     | YouTube API      |
| ActionCable WS   |     | PostgreSQL+pgvec |     | crawl4ai         |
+------------------+     +------------------+     +------------------+
```

### Core Loop
```
USER INPUT (URL or Question)
       |
       v
+----------------+     +------------------+     +------------------+
|  INGEST        | --> |  EXTRACT         | --> |  CONNECT         |
|  - Web scrape  |     |  - LLM summarize |     |  - Embeddings    |
|  - PDF/YouTube |     |  - Extract ideas |     |  - Auto-cluster  |
+----------------+     +------------------+     +------------------+
       |                                               |
       v                                               v
+----------------+     +------------------+     +------------------+
|  EXPLORE       | <-- |  THREAD          | <-- |  LINK            |
|  - Related     |     |  - Research Qs   |     |  - Internal refs |
|  - Similarity  |     |  - Web search    |     |  - Cross-insight |
+----------------+     +------------------+     +------------------+
```

---

## 2. Domain Model & Entity Relationships

### Entity Relationship Diagram (ERD)
```
                              +------------------+
                              |     Article      |
                              +------------------+
                              | id               |
                              | title            |
                              | url (unique)     |
                              | author           |
                              | published_at     |
                              | summary (LLM)    |
                              | text (scraped)   |
                              | image_url        |
                              | status           |
                              | content_type     |
                              | origin           |
                              | embedding[1536]  |
                              | slug (unique)    |
                              | nanoid           |
                              | last_error       |
                              | parent_id (FK)---|---+
                              +------------------+   |
                                  |    |    |       |
                     parent_id ---+    |    |       |
                                       |    |       |
              +------------------------+    |       |
              |                             |       |
              v                             v       v
    +------------------+         +------------------+
    |     Insight      |         |  Article (Parent)|
    +------------------+         |  (clustered)     |
    | id               |         +------------------+
    | article_id (FK)--|-------->| url = nil        |
    | title            |         | Has children[]   |
    | body (LLM)       |         +------------------+
    | snippet (source) |
    | status           |
    | embedding[1536]  |
    | slug (unique)    |
    | nanoid           |
    | parent_id (FK)---|---+
    +------------------+   |
           |               |
           v               v
    +------------------+
    |  Insight (Parent)|
    |  (synthesized)   |
    +------------------+
    | article_id = nil |
    | Has children[]   |
    +------------------+


    +------------------+         +------------------+
    |     Search       |<--------|  SearchArticle   |
    +------------------+  has_   +------------------+
    | id               |  many   | search_id (FK)   |
    | query (user)     |         | article_id (FK)  |------> Article
    | search_query(opt)|         +------------------+
    | search_query_emb |
    | summary (LLM)    |
    | snippet          |
    | embedding[1536]  |
    | status           |
    | source_type      |---+
    | source_id        |---+--> Article | Insight | Search (polymorphic)
    | slug             |
    | nanoid           |
    +------------------+
           |
           | has_many :searches (recursive)
           v
    +------------------+
    |  Follow-up Search|
    +------------------+
```

### Concerns as Traits (Mixin Architecture)
```
Article / Insight / Search
    |
    +-- Sluggable .............. URL-friendly identifiers
    |   - slug -> { title }
    |   - resolve_identifier!
    |
    +-- Parentable ............. Parent-child clustering
    |   - parent_matching threshold: N
    |   - find_similar_and_absorb!
    |   - reparents Model, foreign_key:
    |
    +-- Embeddable ............. Vector embeddings
    |   - embeddable :field
    |   - generate_embedding!
    |
    +-- Broadcastable .......... Real-time updates
    |   - broadcast_self
    |   - broadcast_to_parents
    |
    +-- Linkable ............... Related insights
    |   - linkable_insights
    |
    +-- SearchGeneratable ...... Auto research questions
    |   - generate_searches!
    |   - search_context
    |
    +-- NormalizesMarkup ....... **text** -> <strong>
        - normalizes_markup :field
```

---

## 3. Data Flow Diagrams

### 3.1 Article Ingestion Flow
```
User submits URL
        |
        v
+-------------------+
| QueriesController |
| POST /queries     |
+-------------------+
        |
        | Article.find_or_create_by!(url:)
        v
+-------------------+
| Article.create!   |
| status: pending   |
+-------------------+
        |
        | after_create_commit
        v
+-------------------+
| IngestArticleJob  |
+-------------------+
        |
        +---> YouTube URL? --> YoutubeClient.fetch()
        |                          |
        |                          v
        |                     +------------------+
        |                     | VideoMetadataSchema
        |                     | - title
        |                     | - author (speaker)
        |                     | - summary
        |                     +------------------+
        |
        +---> Web URL? --> Exa.crawl() or crawl4ai
                               |
                               v
                          +------------------+
                          | ContentEvaluation|
                          | Schema           |
                          | - content_type   |
                          | - full_text_url  |
                          | - is_paper?      |
                          +------------------+
                               |
        +----------------------+
        |                      |
        v                      v
   full/paper             abstract/partial
        |                      |
        v                      v
   extract_metadata()     Follow full_text_url
        |                 or use partial
        v
+-------------------+
| ArticleMetadata   |
| Schema            |
| - title           |
| - author          |
| - published_at    |
+-------------------+
        |
        v
+-------------------+
| generate_summary()|
| ArticleSummary    |
| Schema            |
| 200-300 chars     |
| with <strong>     |
+-------------------+
        |
        v
+-------------------+
| finalize_article  |
+-------------------+
        |
        +---> generate_embedding!()
        |         |
        |         v
        |    LLM.embed(summary) --> embedding[1536]
        |
        +---> find_similar_and_absorb!()
        |         |
        |         v
        |    +---------------------------+
        |    | Parentable concern        |
        |    | find_parent_match()       |
        |    | find_peer_match()         |
        |    | similar_enough?(threshold)|
        |    +---------------------------+
        |              |
        |    +---------+----------+
        |    |                    |
        |    v                    v
        | Match found          No match
        |    |                    |
        |    v                    v
        | become_child_of!    continue
        | or create_parent!
        |         |
        |         v
        |    regenerate_metadata!()
        |    ParentSynthesizer.new(children).synthesize
        |
        +---> generate_searches!(count: 2)
        |         |
        |         v
        |    SearchQueriesSchema
        |    "Generate research questions..."
        |
        +---> GenerateInsightsJob.perform_later()
                  |
                  v
           [See Insight Flow]
```

### 3.2 Insight Extraction Flow
```
GenerateInsightsJob.perform(article)
        |
        v
+-------------------+
| InsightsSchema    |
| Prompt based on   |
| content_type:     |
| - full/paper      |
| - video/podcast   |
| - partial         |
+-------------------+
        |
        v
Extract N insights from article.text
        |
        v
+-------------------+
| For each insight: |
+-------------------+
        |
        +---> Create Insight record
        |         title, body, snippet
        |
        +---> generate_embedding!()
        |         LLM.embed(body)
        |
        +---> find_similar_and_absorb!()
        |         |
        |         v
        |    Insight.parent_matching threshold: 0.25
        |    peer_scope: exclude same article
        |         |
        |    +---------+----------+
        |    |                    |
        |    v                    v
        | Match found          No match
        |    |
        |    v
        | Insight::ParentSynthesizer
        | "Synthesize into ONE canonical insight"
        |
        +---> generate_searches!(count: 2)
        |
        +---> AddLinksJob.set(wait: 30.seconds)
                  |
                  v
           [See Linking Flow]
```

### 3.3 Search & Research Thread Flow
```
User submits question
        |
        v
+-------------------+
| QueriesController |
| POST /queries     |
+-------------------+
        |
        | Search.create!(query:, source:)
        | SearchJob.perform_later()
        v
+-------------------+
| SearchJob         |
+-------------------+
        |
        +---> generate_search_query_and_embedding!()
        |         |
        |         v
        |    LLM transforms user query
        |    into optimized search query
        |    + generates embedding
        |
        +---> ExaClient.search(search_query)
        |         |
        |         v
        |    Neural search results (10 candidates)
        |
        +---> Filter with SelectedArticlesSchema
        |         |
        |         v
        |    LLM selects 1-3 best articles
        |    "Prefer diversity, exclude PDFs..."
        |
        +---> For each selected article:
        |         Article.find_or_create_by!(url:)
        |         SearchArticle.find_or_create_by!
        |
        +---> ready_to_summarize?
                  |
                  v
           all_articles_resolved? && viable_content?
                  |
                  v
+-------------------+
| SummarizeSearchJob|
+-------------------+
        |
        +---> aggregate_content()
        |         - User query + optimized query
        |         - Each article's title, summary
        |         - Top 5 rolled_up_insights per article
        |         - Related library items (vector search)
        |
        +---> LLM synthesis via SummarizeSearchSchema
        |         - summary: 2-4 sentences
        |         - snippet: key quote <strong>
        |         - followup_queries: 2 questions
        |
        +---> Update search: summary, snippet, status=complete
        |
        +---> generate_embedding!() on summary
        |
        +---> Create follow-up Search records (recursive!)
        |         search.searches.create!(query: followup, source: search.source)
        |
        +---> AddLinksJob.perform_now(search)
```

### 3.4 Auto-Linking Flow
```
AddLinksJob.perform(record)
        |
        +---> Get linkable_insights(limit: 20)
        |         via Linkable concern
        |         vector similarity on embedding
        |
        +---> For each content field:
        |         Article: summary
        |         Insight: body, snippet
        |         Search: summary, snippet
        |
        +---> LLM prompt:
        |         "Add internal links using [text](insight:slug)"
        |         "Only link to available targets"
        |         "Don't change words, only add markup"
        |
        +---> Validate linked content:
        |         - Plain text unchanged
        |         - All link targets valid
        |
        +---> Update field with linked content
```

### 3.5 Real-Time Broadcast Flow
```
Model changes (after_commit)
        |
        v
+-------------------+
| Broadcastable     |
| concern           |
+-------------------+
        |
        +---> broadcast_self()
                  |
                  +---> broadcast_page()
                  |         target: "article_123_page"
                  |         partial: "articles/article_page"
                  |
                  +---> broadcast_card()
                  |         target: "article_123"
                  |         partial: "articles/article"
                  |
                  +---> broadcast_to_parents()
                            |
                            v
                       containing_searches.find_each(&:broadcast_self)
                            |
                            v
                       article&.broadcast_self


+-------------------+        +-------------------+
| Turbo Streams     |        | ActionCable       |
| broadcast_replace_|------->| WebSocket         |
| later_to()        |        | Redis pub/sub     |
+-------------------+        +-------------------+
                                    |
                                    v
                             +-------------------+
                             | Browser           |
                             | subscribe_to()    |
                             | turbo_stream_from |
                             +-------------------+
                                    |
                                    v
                             DOM element replaced
                             without page reload
```

---

## 4. LLM Integration Points

### Prompt Locations Map
```
+------------------------------------------+-------------------------------------------+
| File                                      | Prompt Purpose                            |
+------------------------------------------+-------------------------------------------+
| app/jobs/ingest_article_job.rb:4-14      | SUMMARY_INSTRUCTIONS                      |
|                                           | "Distill key idea into 200-300 chars"     |
+------------------------------------------+-------------------------------------------+
| app/jobs/ingest_article_job.rb:16-29     | CONTENT_EVALUATION_INSTRUCTIONS           |
|                                           | "Classify scraped content"                |
+------------------------------------------+-------------------------------------------+
| app/jobs/ingest_article_job.rb:76-89     | Video metadata extraction prompt          |
|                                           | "Extract speaker, not channel"            |
+------------------------------------------+-------------------------------------------+
| app/jobs/generate_insights_job.rb:40-65  | Insight extraction prompts (by type)      |
|                                           | full/partial/video/podcast                |
+------------------------------------------+-------------------------------------------+
| app/jobs/search_job.rb:39-48             | Article selection prompt                  |
|                                           | "Select 1-3 best articles"                |
+------------------------------------------+-------------------------------------------+
| app/jobs/summarize_search_job.rb:4-11    | INSTRUCTIONS for synthesis                |
|                                           | "2-4 sentence synthesis..."               |
+------------------------------------------+-------------------------------------------+
| app/jobs/add_links_job.rb:36-51          | Internal linking prompt                   |
|                                           | "Add [text](insight:slug) links"          |
+------------------------------------------+-------------------------------------------+
| app/models/concerns/search_generatable.rb| QUERIES_PROMPT                            |
| :8-15                                     | "Generate research questions..."          |
+------------------------------------------+-------------------------------------------+
| app/models/article/parent_synthesizer.rb | PROMPT for cluster synthesis              |
| :11-16                                    | "Canonical title + summary"               |
+------------------------------------------+-------------------------------------------+
| app/models/article/sameness_check.rb     | Article comparison prompt                 |
| :34-47                                    | "Are these the SAME article?"             |
+------------------------------------------+-------------------------------------------+
| app/models/insight/parent_synthesizer.rb | PROMPT for insight synthesis              |
| :11-17                                    | "Synthesize into ONE insight"             |
+------------------------------------------+-------------------------------------------+
| app/models/search.rb:67-70               | Search query optimization                 |
|                                           | "Generate concise search query"           |
+------------------------------------------+-------------------------------------------+
```

### Schema Definitions
```
app/schemas/
├── article_metadata_schema.rb    # title, author, published_at
├── article_summary_schema.rb     # summary (200-300 chars)
├── content_evaluation_schema.rb  # content_type, full_text_url, is_paper
├── insights_schema.rb            # array of {title, body, snippet}
├── research_queries_schema.rb    # array of queries
├── search_queries_schema.rb      # array of queries (max 60 chars)
├── selected_articles_schema.rb   # array of {url, title}
├── summarize_search_schema.rb    # summary, snippet, followup_queries
└── video_metadata_schema.rb      # title, author, published_at, summary
```

### LLM Configuration
```ruby
# config/initializers/ruby_llm.rb

RubyLLM.configure do |config|
  config.default_model = "google/gemini-2.5-flash"
  config.default_embedding_model = "openai/text-embedding-3-small"
end

module LLM
  def self.chat
    RubyLLM.chat(provider: LLM_PROVIDER, assume_model_exists: true)
  end

  def self.embed(text)
    RubyLLM.embed(text, provider: EMBEDDING_PROVIDER, assume_model_exists: true)
  end
end
```

---

## 5. Real-Time Architecture

### WebSocket Flow
```
Browser                    Rails                     Redis
   |                          |                        |
   |--subscribe_to(@article)->|                        |
   |                          |--SUBSCRIBE article_1-->|
   |                          |                        |
   |                          |                        |
   |                    [Article updated]              |
   |                          |                        |
   |                          |--PUBLISH article_1---->|
   |                          |    turbo_stream HTML   |
   |                          |                        |
   |<--turbo_stream HTML------|<-----------------------|
   |                          |                        |
   | [DOM replaced]           |                        |
```

### Configuration Files
```yaml
# config/cable.yml
development:
  adapter: redis
  url: redis://localhost:6379/1
  channel_prefix: jargon_development

production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") %>
  channel_prefix: jargon_production
```

### View Subscription
```erb
<%# app/views/articles/show.html.erb %>
<%= subscribe_to(@article) %>  <%# Creates WebSocket subscription %>
<%= render "articles/article_page", article: @article %>
```

---

## 6. State Storage & Data Locations

### Where Data Lives
```
+------------------------------------------+-------------------------------------------+
| Data Type                                 | Storage Location                          |
+------------------------------------------+-------------------------------------------+
| Articles, Insights, Searches              | PostgreSQL (articles, insights, searches) |
| Full scraped text                         | PostgreSQL articles.text column           |
| LLM-generated summaries                   | PostgreSQL (summary/body columns)         |
| Vector embeddings                         | PostgreSQL pgvector (embedding columns)   |
| Parent-child relationships                | PostgreSQL (parent_id FK columns)         |
| Search results junction                   | PostgreSQL search_articles table          |
| Real-time pub/sub                         | Redis                                     |
| WebSocket connections                     | Redis (ActionCable adapter)               |
| Application cache                         | Memory (dev) / Redis (prod)               |
| Session data                              | Cookie-based (Rails default)              |
+------------------------------------------+-------------------------------------------+
```

### Database Schema (Key Tables)
```sql
-- Articles: Source content
CREATE TABLE articles (
  id bigint PRIMARY KEY,
  title varchar,
  url varchar UNIQUE,           -- Original source URL
  author varchar,
  published_at timestamp,
  summary text,                 -- LLM-generated 200-300 char summary
  text text,                    -- Full scraped content
  image_url varchar,
  status integer DEFAULT 0,     -- pending(0), complete(1), failed(2)
  content_type integer DEFAULT 0, -- full/partial/video/podcast/paper
  origin integer DEFAULT 0,     -- manual(0), discovered(1)
  embedding vector(1536),       -- OpenAI text-embedding-3-small
  slug varchar UNIQUE,
  nanoid varchar NOT NULL,      -- Fallback identifier
  parent_id bigint REFERENCES articles(id),  -- Clustering
  last_error text               -- JSON error details
);

-- Insights: Extracted ideas
CREATE TABLE insights (
  id bigint PRIMARY KEY,
  article_id bigint REFERENCES articles(id), -- Can be NULL for parents
  title varchar,                -- 3-5 word insight name
  body text,                    -- 200-300 char with <strong>
  snippet text,                 -- Source excerpt
  status integer DEFAULT 0,
  embedding vector(1536),
  slug varchar UNIQUE,
  nanoid varchar NOT NULL,
  parent_id bigint REFERENCES insights(id)  -- Clustering
);

-- Searches: Research queries and results
CREATE TABLE searches (
  id bigint PRIMARY KEY,
  query text NOT NULL,          -- User's original question
  search_query text,            -- LLM-optimized query
  search_query_embedding vector(1536),
  summary text,                 -- LLM synthesis of results
  snippet text,                 -- Key quote from sources
  embedding vector(1536),       -- Embedding of summary
  status integer DEFAULT 0,     -- pending/searching/complete/failed
  source_type varchar,          -- Polymorphic: Article/Insight/Search
  source_id bigint,
  slug varchar UNIQUE,
  nanoid varchar NOT NULL
);

-- Search-Article junction
CREATE TABLE search_articles (
  id bigint PRIMARY KEY,
  search_id bigint REFERENCES searches(id) NOT NULL,
  article_id bigint REFERENCES articles(id) NOT NULL,
  UNIQUE(search_id, article_id)
);
```

### Accessing Full Knowledge State

To export all knowledge artifacts as text:

```ruby
# Export all articles with their insights
Article.complete.roots.includes(:insights, :children).each do |article|
  puts "=" * 80
  puts "ARTICLE: #{article.title}"
  puts "URL: #{article.url}"
  puts "SUMMARY: #{article.summary}"
  puts ""
  puts "INSIGHTS:"
  article.rolled_up_insights.each do |insight|
    puts "  - #{insight.title}"
    puts "    #{insight.body}"
    puts "    [#{insight.snippet}]"
  end
end

# Export all searches with synthesis
Search.complete.each do |search|
  puts "=" * 80
  puts "QUERY: #{search.query}"
  puts "SUMMARY: #{search.summary}"
  puts "SNIPPET: #{search.snippet}"
end

# Get related items for any record
embedding = article.embedding  # or insight.embedding, search.embedding
SimilarItemsQuery.new(embedding: embedding, limit: 10).call
```

---

## 7. Extension Points for DKR

### 7.1 Adding New Content Types

```ruby
# Add a new content source type in article.rb
enum :content_type, {
  full: 0, partial: 1, video: 2, podcast: 3, paper: 4,
  obsidian_note: 5,  # New
  roam_page: 6       # New
}

# Create a new ingest job or extend IngestArticleJob
class IngestObsidianNoteJob < ApplicationJob
  def perform(note_path)
    # Parse Obsidian markdown
    # Extract backlinks as potential article sources
    # Generate summary and insights
  end
end
```

### 7.2 Adding New AI Agents (Following DKR Pattern)

```ruby
# app/models/concerns/agent_capable.rb
module AgentCapable
  extend ActiveSupport::Concern

  class_methods do
    def agent_prompt(prompt_template)
      @agent_prompt_template = prompt_template
    end
  end

  def run_agent(context = {})
    prompt = build_agent_prompt(context)
    LLM.chat.with_schema(self.class.agent_schema).ask(prompt)
  end
end

# Example DKR Agent
class DkrSynthesisAgent
  include AgentCapable

  agent_prompt <<~PROMPT
    Analyze the following knowledge artifacts and identify:
    - Gaps in coverage
    - Conflicting information
    - Opportunities for synthesis
    - Recommended follow-up research
  PROMPT

  def synthesize(artifacts)
    run_agent(artifacts: artifacts)
  end
end
```

### 7.3 Custom Export Formats

```ruby
# app/models/concerns/exportable.rb
module Exportable
  def to_obsidian_markdown
    <<~MD
      ---
      title: #{title}
      created: #{created_at.iso8601}
      tags: [#{slug}]
      ---

      # #{title}

      #{summary || body}

      ## Sources
      #{source_links}

      ## Related
      #{related_links}
    MD
  end

  def to_roam_edn
    # Roam EDN format
  end
end
```

### 7.4 Webhook Integration Points

```ruby
# app/models/concerns/webhook_notifiable.rb
module WebhookNotifiable
  extend ActiveSupport::Concern

  included do
    after_commit :notify_webhooks, if: :broadcastable?
  end

  def notify_webhooks
    WebhookDeliveryJob.perform_later(self, event: webhook_event)
  end

  def webhook_event
    { type: self.class.name, id: id, changes: previous_changes }
  end
end
```

### 7.5 Multi-User/Workspace Support

```ruby
# Migration to add workspace support
class AddWorkspaceToModels < ActiveRecord::Migration[8.1]
  def change
    create_table :workspaces do |t|
      t.string :name
      t.string :slug
      t.timestamps
    end

    add_reference :articles, :workspace
    add_reference :insights, :workspace
    add_reference :searches, :workspace
  end
end

# Concern for workspace scoping
module WorkspaceScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :workspace
    default_scope { where(workspace: Current.workspace) }
  end
end
```

### 7.6 API Endpoints for External Integration

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :articles, only: [:index, :show, :create]
    resources :insights, only: [:index, :show]
    resources :searches, only: [:index, :show, :create]
    post 'synthesize', to: 'synthesis#create'
    get 'related/:type/:id', to: 'relations#show'
  end
end

# API controller
class Api::V1::SynthesisController < ApplicationController
  def create
    agent = DkrSynthesisAgent.new
    result = agent.synthesize(synthesis_params[:artifacts])
    render json: result
  end
end
```

### 7.7 MCP Server Integration

```ruby
# lib/totem_mcp_server.rb
class TotemMcpServer
  def initialize(workspace)
    @workspace = workspace
  end

  def search_knowledge(query)
    Search.create!(query: query, workspace: @workspace)
           .tap { |s| SearchJob.perform_now(s) }
  end

  def get_related(item_id, item_type)
    item = item_type.constantize.find(item_id)
    SimilarItemsQuery.new(embedding: item.embedding, limit: 10).call
  end

  def synthesize(artifact_ids)
    artifacts = Article.where(id: artifact_ids)
    DkrSynthesisAgent.new.synthesize(artifacts)
  end
end
```

---

## 8. File Reference

### Models
| File | Purpose |
|------|---------|
| [app/models/article.rb](app/models/article.rb) | Core article entity |
| [app/models/insight.rb](app/models/insight.rb) | Extracted insight entity |
| [app/models/search.rb](app/models/search.rb) | Research query & results |
| [app/models/search_article.rb](app/models/search_article.rb) | Junction table |
| [app/models/structured_chat.rb](app/models/structured_chat.rb) | LLM schema wrapper |

### Concerns
| File | Purpose |
|------|---------|
| [app/models/concerns/parentable.rb](app/models/concerns/parentable.rb) | Parent-child clustering |
| [app/models/concerns/embeddable.rb](app/models/concerns/embeddable.rb) | Vector embeddings |
| [app/models/concerns/sluggable.rb](app/models/concerns/sluggable.rb) | URL slugs |
| [app/models/concerns/broadcastable.rb](app/models/concerns/broadcastable.rb) | Real-time updates |
| [app/models/concerns/linkable.rb](app/models/concerns/linkable.rb) | Related insights |
| [app/models/concerns/search_generatable.rb](app/models/concerns/search_generatable.rb) | Research questions |
| [app/models/concerns/normalizes_markup.rb](app/models/concerns/normalizes_markup.rb) | Markup normalization |

### Model Collaborators
| File | Purpose |
|------|---------|
| [app/models/article/parent_synthesizer.rb](app/models/article/parent_synthesizer.rb) | Article cluster synthesis |
| [app/models/article/sameness_check.rb](app/models/article/sameness_check.rb) | Duplicate detection |
| [app/models/insight/parent_synthesizer.rb](app/models/insight/parent_synthesizer.rb) | Insight cluster synthesis |

### Jobs
| File | Purpose |
|------|---------|
| [app/jobs/ingest_article_job.rb](app/jobs/ingest_article_job.rb) | Content scraping & summarization |
| [app/jobs/generate_insights_job.rb](app/jobs/generate_insights_job.rb) | Insight extraction |
| [app/jobs/search_job.rb](app/jobs/search_job.rb) | Neural search via Exa |
| [app/jobs/summarize_search_job.rb](app/jobs/summarize_search_job.rb) | Search result synthesis |
| [app/jobs/add_links_job.rb](app/jobs/add_links_job.rb) | Internal linking |

### Schemas
| File | Purpose |
|------|---------|
| [app/schemas/article_summary_schema.rb](app/schemas/article_summary_schema.rb) | Article summary output |
| [app/schemas/insights_schema.rb](app/schemas/insights_schema.rb) | Insight extraction output |
| [app/schemas/summarize_search_schema.rb](app/schemas/summarize_search_schema.rb) | Search synthesis output |
| [app/schemas/content_evaluation_schema.rb](app/schemas/content_evaluation_schema.rb) | Content classification |

### External Clients
| File | Purpose |
|------|---------|
| [lib/exa_client.rb](lib/exa_client.rb) | Exa neural search API |
| [lib/youtube_client.rb](lib/youtube_client.rb) | YouTube data fetching |
| [lib/crawl4ai_client.rb](lib/crawl4ai_client.rb) | Fallback web crawler |

### Configuration
| File | Purpose |
|------|---------|
| [config/initializers/ruby_llm.rb](config/initializers/ruby_llm.rb) | LLM provider setup |
| [config/cable.yml](config/cable.yml) | ActionCable/Redis config |
| [config/routes.rb](config/routes.rb) | URL routing |
| [db/structure.sql](db/structure.sql) | Database schema |

---

## 9. Totem Protocol Integration

### 9.1 Why Jargon is the Foundation for DKR

Jargon's architecture uniquely enables Doug Engelbart's Dynamic Knowledge Repository vision:

| Capability | How Jargon Enables It |
|------------|----------------------|
| **A-Level Work** | Direct knowledge work via the 5 core functions |
| **B-Level Improvement** | Exposed prompts allow workflow modification |
| **C-Level Meta-Improvement** | Patterns in prompt changes inform system design |
| **Persistent Knowledge** | pgvector embeddings create accumulating knowledge graph |
| **Cross-Session Memory** | Unlike ephemeral chat, artifacts persist and connect |

### 9.2 The Five Functions as Intervention Points

```
┌─────────────────────────────────────────────────────────────────┐
│                    THE DKR PIPELINE                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. INGEST ──► 2. SUMMARIZE ──► 3. EXTRACT ──► 4. CONNECT ──► 5. THREAD
│      │              │               │              │              │
│      ▼              ▼               ▼              ▼              ▼
│  [prompt]       [prompt]        [prompt]       [prompt]       [prompt]
│                                                                  │
│  Each prompt can be:                                             │
│    • Observed (understand AI reasoning)                          │
│    • Modified (change behavior)                                  │
│    • Specialized (per workspace/project)                         │
│    • Automated (via Letta agents)                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 9.3 Comparison: Jargon vs. Perplexity.ai

| Aspect | Perplexity.ai | Jargon DKR |
|--------|---------------|------------|
| **Prompts** | Hidden, vendor-controlled | Exposed, user-modifiable |
| **Persistence** | Session-only | Permanent knowledge graph |
| **Clustering** | None | Automatic via embeddings |
| **Research threads** | Single-level | Recursive, unbounded |
| **Improvement loop** | Vendor improves for you | You improve it yourself |
| **Integration** | Standalone service | Open-source, extensible |

### 9.4 Future: Workspace-Aware Prompt Modification

The architecture supports adding a **Letta agent layer** that observes user context and modifies prompts dynamically:

```ruby
# Future: app/services/prompt_modifier.rb
class PromptModifier
  def initialize(workspace)
    @workspace = workspace
    @context = observe_current_context
  end

  def modify(base_prompt, function)
    case @workspace.mode
    when :academic_research
      inject_academic_rigor(base_prompt)
    when :startup_ideation
      inject_opportunity_lens(base_prompt)
    when :legal_review
      inject_citation_requirements(base_prompt)
    end
  end
end
```

### 9.5 Totem Protocol Multi-Surface Vision

Jargon becomes one surface among many, all connected via Totem Protocol:

```
                    USER IDENTITY (OAuth)
                           │
           ┌───────────────┼───────────────┐
           │               │               │
           ▼               ▼               ▼
    ┌────────────┐  ┌────────────┐  ┌────────────┐
    │ Jargon DKR │  │ GenAI      │  │ Obsidian   │
    │ (Web)      │  │ Studio     │  │ Plugin     │
    └────────────┘  └────────────┘  └────────────┘
           │               │               │
           └───────────────┼───────────────┘
                           │
                           ▼
              ┌─────────────────────────┐
              │   ARTIFACT STORAGE      │
              │   - Knowledge graphs    │
              │   - GenAI assets        │
              │   - Research sessions   │
              │   - Memory artifacts    │
              └─────────────────────────┘
                           │
                           ▼
              ┌─────────────────────────┐
              │   LETTA MEMORY AGENTS   │
              │   Synthesize │ Persist  │
              └─────────────────────────┘
```

### 9.6 Educational Framework: Mental Modelling Agency

Jargon serves as a teaching tool for the Mental Modelling Agency curriculum:

1. **Module: Understanding Feedback Loops** - Map your knowledge workflow
2. **Module: The DKR Pipeline** - Observe how prompts shape output
3. **Module: Second-Order Improvement** - Modify prompts, measure results
4. **Module: Context Engineering** - Design workspace-aware systems
5. **Module: Agent Design** - Build observation and modification agents

See [DKR_FUTURE_SPECIFICATION.md](DKR_FUTURE_SPECIFICATION.md) for detailed roadmap.

---

*Generated for Totem Protocol / Sense Collective*
*December 2024*
