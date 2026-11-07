# Jargon Architecture Diagrams

Visual diagrams for understanding the Jargon/Sense Collective system architecture.

---

## 1. Entity Relationship Diagram

```mermaid
erDiagram
    Article ||--o{ Insight : "has many"
    Article ||--o{ SearchArticle : "has many"
    Article ||--o| Article : "parent/children"
    Insight ||--o| Insight : "parent/children"
    Insight ||--o| Article : "belongs to"
    Search ||--o{ SearchArticle : "has many"
    Search ||--o| Search : "source (recursive)"
    Search ||--o| Article : "source (polymorphic)"
    Search ||--o| Insight : "source (polymorphic)"

    Article {
        bigint id PK
        string title
        string url UK
        string author
        timestamp published_at
        text summary
        text text
        string image_url
        int status
        int content_type
        int origin
        vector embedding
        string slug UK
        string nanoid UK
        bigint parent_id FK
        text last_error
    }

    Insight {
        bigint id PK
        bigint article_id FK
        string title
        text body
        text snippet
        int status
        vector embedding
        string slug UK
        string nanoid UK
        bigint parent_id FK
    }

    Search {
        bigint id PK
        text query
        text search_query
        vector search_query_embedding
        text summary
        text snippet
        vector embedding
        int status
        string source_type
        bigint source_id
        string slug UK
        string nanoid UK
    }

    SearchArticle {
        bigint id PK
        bigint search_id FK
        bigint article_id FK
    }
```

---

## 2. System Architecture Overview

```mermaid
flowchart TB
    subgraph Client["Browser Client"]
        UI[Web UI]
        WS[WebSocket Client]
    end

    subgraph Server["Rails Server (Falcon)"]
        Controllers[Controllers]
        Models[Models]
        Jobs[Background Jobs]
        Cable[ActionCable]
    end

    subgraph Storage["Data Storage"]
        PG[(PostgreSQL + pgvector)]
        Redis[(Redis)]
    end

    subgraph External["External Services"]
        Exa[Exa API]
        OpenRouter[OpenRouter/OpenAI]
        YouTube[YouTube API]
        Crawl4AI[crawl4ai]
    end

    UI -->|HTTP| Controllers
    Controllers --> Models
    Models --> Jobs
    Jobs --> Models

    Models <-->|Read/Write| PG
    Cable <-->|Pub/Sub| Redis
    WS <-->|WebSocket| Cable

    Jobs -->|Search| Exa
    Jobs -->|LLM/Embed| OpenRouter
    Jobs -->|Transcripts| YouTube
    Jobs -->|Fallback| Crawl4AI

    Models -->|Broadcast| Cable
    Cable -->|Turbo Stream| WS
    WS -->|DOM Update| UI
```

---

## 3. Article Ingestion Pipeline

```mermaid
flowchart TD
    subgraph Input["User Input"]
        URL[URL Submitted]
    end

    subgraph Controller["QueriesController"]
        Create[Article.find_or_create_by!]
    end

    subgraph IngestJob["IngestArticleJob"]
        Detect{URL Type?}

        subgraph YouTube["YouTube Path"]
            YT[YoutubeClient.fetch]
            YTMeta[VideoMetadataSchema]
        end

        subgraph Web["Web Path"]
            Exa[ExaClient.crawl]
            Crawl4AI[crawl4ai fallback]
            Eval[ContentEvaluationSchema]
            PDF{Is PDF?}
            PDFExtract[pdftotext]
        end

        Meta[ArticleMetadataSchema]
        Summary[ArticleSummarySchema]
    end

    subgraph Finalize["Finalization"]
        Embed[generate_embedding!]
        Cluster[find_similar_and_absorb!]
        Research[generate_searches!]
        InsightJob[GenerateInsightsJob]
    end

    subgraph Broadcast["Real-time Update"]
        BC[broadcast_self]
    end

    URL --> Create
    Create -->|after_create_commit| Detect

    Detect -->|youtube.com| YT
    YT --> YTMeta
    YTMeta --> Summary

    Detect -->|other URL| Exa
    Exa -->|failed| Crawl4AI
    Exa --> Eval
    Crawl4AI --> Eval

    Eval -->|abstract| PDF
    PDF -->|yes| PDFExtract
    PDFExtract --> Meta
    PDF -->|no| Meta
    Eval -->|full| Meta

    Meta --> Summary
    Summary --> Embed
    Embed --> Cluster
    Cluster --> Research
    Research --> InsightJob

    Embed --> BC
    Cluster --> BC
```

---

## 4. Insight Extraction Flow

```mermaid
flowchart TD
    subgraph Input["Input"]
        Article[Article with text]
    end

    subgraph Job["GenerateInsightsJob"]
        PromptSelect{Content Type?}

        FullPrompt[Full Article Prompt]
        VideoPrompt[Video/Podcast Prompt]
        PartialPrompt[Partial Content Prompt]

        LLM[LLM with InsightsSchema]

        subgraph Loop["For Each Insight"]
            CreateInsight[Create Insight Record]
            EmbedInsight[generate_embedding!]
            ClusterInsight[find_similar_and_absorb!]
            SearchInsight[generate_searches!]
        end

        LinkJob[AddLinksJob +30s delay]
    end

    subgraph Clustering["Parentable Concern"]
        FindMatch{Find Similar?}
        HasChildren{Match has children?}
        HasParent{Match has parent?}
        BecomeChild[become_child_of!]
        CreateParent[create_parent_with!]
        Synthesize[ParentSynthesizer]
    end

    Article --> PromptSelect
    PromptSelect -->|full/paper| FullPrompt
    PromptSelect -->|video/podcast| VideoPrompt
    PromptSelect -->|partial| PartialPrompt

    FullPrompt --> LLM
    VideoPrompt --> LLM
    PartialPrompt --> LLM

    LLM --> CreateInsight
    CreateInsight --> EmbedInsight
    EmbedInsight --> ClusterInsight

    ClusterInsight --> FindMatch
    FindMatch -->|yes| HasChildren
    FindMatch -->|no| SearchInsight

    HasChildren -->|yes| BecomeChild
    HasChildren -->|no| HasParent
    HasParent -->|yes| BecomeChild
    HasParent -->|no| CreateParent

    BecomeChild --> Synthesize
    CreateParent --> Synthesize
    Synthesize --> SearchInsight

    SearchInsight --> LinkJob
```

---

## 5. Search & Research Thread Flow

```mermaid
flowchart TD
    subgraph Input["User Input"]
        Query[Question Submitted]
    end

    subgraph Controller["QueriesController"]
        CreateSearch[Search.create!]
        QueueJob[SearchJob.perform_later]
    end

    subgraph SearchJob["SearchJob"]
        OptimizeQuery[generate_search_query_and_embedding!]
        ExaSearch[ExaClient.search]
        FilterResults[SelectedArticlesSchema]
        CreateArticles[Article.find_or_create_by!]
        LinkArticles[SearchArticle junction]
        CheckReady{ready_to_summarize?}
    end

    subgraph SummarizeJob["SummarizeSearchJob"]
        Aggregate[aggregate_content]

        subgraph Context["Aggregated Context"]
            OrigQuery[Original Query]
            OptQuery[Optimized Query]
            ArticleSummaries[Article Summaries]
            Insights[Top 5 Insights per Article]
            Library[Related Library Items]
        end

        Synthesize[LLM with SummarizeSearchSchema]
        UpdateSearch[Update summary, snippet]
        EmbedSearch[generate_embedding!]
        FollowUp[Create follow-up Searches]
        AddLinks[AddLinksJob]
    end

    subgraph Recursive["Recursive Research"]
        NewSearch1[Follow-up Search 1]
        NewSearch2[Follow-up Search 2]
    end

    Query --> CreateSearch
    CreateSearch --> QueueJob
    QueueJob --> OptimizeQuery
    OptimizeQuery --> ExaSearch
    ExaSearch --> FilterResults
    FilterResults --> CreateArticles
    CreateArticles --> LinkArticles
    LinkArticles --> CheckReady

    CheckReady -->|yes| Aggregate
    CheckReady -->|no, wait| CheckReady

    Aggregate --> OrigQuery
    Aggregate --> OptQuery
    Aggregate --> ArticleSummaries
    Aggregate --> Insights
    Aggregate --> Library

    Context --> Synthesize
    Synthesize --> UpdateSearch
    UpdateSearch --> EmbedSearch
    EmbedSearch --> FollowUp
    FollowUp --> AddLinks

    FollowUp --> NewSearch1
    FollowUp --> NewSearch2
    NewSearch1 -.->|recursive| OptimizeQuery
    NewSearch2 -.->|recursive| OptimizeQuery
```

---

## 6. Auto-Clustering (Parentable) Flow

```mermaid
flowchart TD
    subgraph Trigger["Trigger"]
        NewRecord[New Article/Insight with embedding]
    end

    subgraph FindMatch["find_similar_and_absorb!"]
        CheckParent{Has parent already?}
        CheckEmbed{Has embedding?}

        subgraph ParentSearch["find_parent_match"]
            QueryParents[Query parents_only scope]
            NearestParent[nearest_neighbors cosine]
            CheckThreshold1{distance < threshold?}
            CustomCheck1{Custom matching check?}
        end

        subgraph PeerSearch["find_peer_match"]
            QueryPeers[Query roots scope]
            ApplyPeerScope[Apply peer_scope filter]
            NearestPeer[nearest_neighbors cosine]
            CheckThreshold2{distance < threshold?}
            CustomCheck2{Custom matching check?}
        end
    end

    subgraph Actions["Clustering Actions"]
        MatchType{Match type?}
        BecomeChild[become_child_of!]
        CreateParent[create_parent_with!]
        NoMatch[Continue without clustering]
    end

    subgraph Finalize["Post-Clustering"]
        Reparent[reparent_references]
        Regenerate[regenerate_metadata!]
        Synthesizer[ParentSynthesizer]
        Broadcast[broadcast_self]
    end

    NewRecord --> CheckParent
    CheckParent -->|yes| NoMatch
    CheckParent -->|no| CheckEmbed
    CheckEmbed -->|no| NoMatch
    CheckEmbed -->|yes| QueryParents

    QueryParents --> NearestParent
    NearestParent --> CheckThreshold1
    CheckThreshold1 -->|no| QueryPeers
    CheckThreshold1 -->|yes| CustomCheck1
    CustomCheck1 -->|pass| MatchType
    CustomCheck1 -->|fail| QueryPeers

    QueryPeers --> ApplyPeerScope
    ApplyPeerScope --> NearestPeer
    NearestPeer --> CheckThreshold2
    CheckThreshold2 -->|no| NoMatch
    CheckThreshold2 -->|yes| CustomCheck2
    CustomCheck2 -->|pass| MatchType
    CustomCheck2 -->|fail| NoMatch

    MatchType -->|has_children| BecomeChild
    MatchType -->|has_parent| BecomeChild
    MatchType -->|neither| CreateParent

    BecomeChild --> Reparent
    CreateParent --> Reparent
    Reparent --> Regenerate
    Regenerate --> Synthesizer
    Synthesizer --> Broadcast
```

---

## 7. Real-Time Broadcast Flow

```mermaid
sequenceDiagram
    participant Browser
    participant ActionCable
    participant Redis
    participant Model
    participant Job

    Browser->>ActionCable: subscribe_to(@article)
    ActionCable->>Redis: SUBSCRIBE article_123

    Note over Job: Background processing completes

    Job->>Model: update!(summary: "...")
    Model->>Model: after_commit callback
    Model->>Model: broadcast_self

    Model->>ActionCable: broadcast_replace_later_to
    ActionCable->>Redis: PUBLISH article_123
    Redis->>ActionCable: Message received
    ActionCable->>Browser: Turbo Stream HTML

    Note over Browser: DOM element replaced
    Browser->>Browser: UI updates without reload

    Model->>Model: broadcast_to_parents
    Model->>Model: containing_searches.each(&:broadcast_self)
```

---

## 8. Concerns Architecture (Trait Composition)

```mermaid
classDiagram
    class Article {
        +title: String
        +url: String
        +summary: Text
        +embedding: Vector
        +status: Enum
        +rolled_up_insights()
        +find_related_items()
        +regenerate_metadata!()
    }

    class Insight {
        +title: String
        +body: Text
        +snippet: Text
        +embedding: Vector
        +sibling_insights()
        +regenerate_metadata!()
    }

    class Search {
        +query: Text
        +search_query: Text
        +summary: Text
        +embedding: Vector
        +find_related_items()
        +ready_to_summarize?()
    }

    class Sluggable {
        <<concern>>
        +slug: String
        +nanoid: String
        +to_param()
        +resolve_identifier!()
        -generate_slug()
    }

    class Parentable {
        <<concern>>
        +parent_id: FK
        +has_parent?()
        +has_children?()
        +find_similar_and_absorb!()
        +become_child_of!()
        +create_parent_with!()
    }

    class Embeddable {
        <<concern>>
        +embedding: Vector
        +generate_embedding!()
    }

    class Broadcastable {
        <<concern>>
        +broadcast_self()
        +broadcast_page()
        +broadcast_card()
        +broadcast_to_parents()
    }

    class Linkable {
        <<concern>>
        +linkable_insights()
    }

    class SearchGeneratable {
        <<concern>>
        +generate_searches!()
        -generate_search_queries()
    }

    class NormalizesMarkup {
        <<concern>>
        -normalize_markup_fields()
    }

    Article --|> Sluggable
    Article --|> Parentable
    Article --|> Embeddable
    Article --|> Broadcastable
    Article --|> Linkable
    Article --|> SearchGeneratable
    Article --|> NormalizesMarkup

    Insight --|> Sluggable
    Insight --|> Parentable
    Insight --|> Embeddable
    Insight --|> Broadcastable
    Insight --|> Linkable
    Insight --|> SearchGeneratable
    Insight --|> NormalizesMarkup

    Search --|> Sluggable
    Search --|> Embeddable
    Search --|> Broadcastable
    Search --|> Linkable
    Search --|> SearchGeneratable
    Search --|> NormalizesMarkup
```

---

## 9. Job Pipeline Orchestration

```mermaid
flowchart LR
    subgraph Trigger["User Action"]
        SubmitURL[Submit URL]
        SubmitQuery[Submit Question]
    end

    subgraph Pipeline1["Article Pipeline"]
        Ingest[IngestArticleJob]
        GenInsights[GenerateInsightsJob]
        AddLinks1[AddLinksJob]
    end

    subgraph Pipeline2["Search Pipeline"]
        SearchJob[SearchJob]
        SummarizeJob[SummarizeSearchJob]
        AddLinks2[AddLinksJob]
    end

    subgraph Cleanup["Maintenance"]
        CleanupLinks[CleanupDeadLinksJob]
    end

    SubmitURL -->|after_create| Ingest
    Ingest -->|perform_later| GenInsights
    GenInsights -->|set wait: 30s| AddLinks1

    SubmitQuery -->|perform_later| SearchJob
    SearchJob -->|when ready| SummarizeJob
    SummarizeJob -->|perform_now| AddLinks2
    SummarizeJob -->|recursive| SearchJob

    GenInsights -.->|notify| SummarizeJob

    AddLinks1 -.->|on destroy| CleanupLinks
```

---

## 10. LLM Integration Points Map

```mermaid
flowchart TB
    subgraph Jobs["Background Jobs"]
        subgraph IngestJob["IngestArticleJob"]
            Eval[ContentEvaluationSchema<br/>Classify content type]
            VideoMeta[VideoMetadataSchema<br/>Extract speaker, title]
            ArticleMeta[ArticleMetadataSchema<br/>Extract author, date]
            ArticleSummary[ArticleSummarySchema<br/>200-300 char summary]
        end

        subgraph InsightsJob["GenerateInsightsJob"]
            InsightsExtract[InsightsSchema<br/>Extract key ideas]
        end

        subgraph SearchJobBox["SearchJob"]
            SelectArticles[SelectedArticlesSchema<br/>Choose 1-3 best results]
        end

        subgraph SummarizeJobBox["SummarizeSearchJob"]
            SynthesizeResults[SummarizeSearchSchema<br/>2-4 sentence synthesis]
        end

        subgraph LinksJob["AddLinksJob"]
            AddInternalLinks[Free-form prompt<br/>Add insight links]
        end
    end

    subgraph Models["Model Collaborators"]
        subgraph ArticleModel["Article"]
            SamenessCheck[SamenessCheck Schema<br/>Are articles identical?]
            ArticleSynth[ParentSynthesizer Schema<br/>Canonical cluster title]
        end

        subgraph InsightModel["Insight"]
            InsightSynth[ParentSynthesizer Schema<br/>Synthesize insights]
        end

        subgraph SearchModel["Search"]
            OptimizeQuery[Free-form prompt<br/>Optimize search query]
        end
    end

    subgraph Concerns["Concerns"]
        SearchGen[SearchGeneratable<br/>SearchQueriesSchema<br/>Generate research Qs]
    end

    subgraph LLM["LLM Provider"]
        Chat[LLM.chat<br/>Gemini 2.5 Flash]
        Embed[LLM.embed<br/>text-embedding-3-small]
    end

    Eval --> Chat
    VideoMeta --> Chat
    ArticleMeta --> Chat
    ArticleSummary --> Chat
    InsightsExtract --> Chat
    SelectArticles --> Chat
    SynthesizeResults --> Chat
    AddInternalLinks --> Chat
    SamenessCheck --> Chat
    ArticleSynth --> Chat
    InsightSynth --> Chat
    OptimizeQuery --> Chat
    SearchGen --> Chat

    ArticleSummary -.-> Embed
    InsightsExtract -.-> Embed
    SynthesizeResults -.-> Embed
```

---

## 11. User Experience Flow

```mermaid
flowchart TD
    subgraph Home["Home Page"]
        Empty{Library Empty?}
        Intro[Show intro + input]
        Feed[Show recent feed]
    end

    subgraph Input["User Input"]
        InputField[URL or Question field]
        IsURL{Is URL?}
    end

    subgraph ArticleView["Article View"]
        ArticlePending[Loading placeholder]
        ArticleFailed[Error message]
        ArticleComplete[Full article view]
        ArticleInsights[Insights list]
        ArticleExplore[Research threads]
        ArticleRelated[Related items]
    end

    subgraph InsightView["Insight View"]
        InsightBody[Insight body + snippet]
        InsightSources[Source articles]
        InsightSiblings[Sibling insights]
        InsightRelated[Related items]
    end

    subgraph SearchView["Search View"]
        SearchPending[Generating query...]
        SearchSearching[Searching...]
        SearchComplete[Summary + results]
        SearchExplore[Follow-up questions]
    end

    Empty -->|yes| Intro
    Empty -->|no| Feed

    Intro --> InputField
    Feed --> InputField

    InputField --> IsURL
    IsURL -->|yes| ArticlePending
    IsURL -->|no| SearchPending

    ArticlePending -->|success| ArticleComplete
    ArticlePending -->|failure| ArticleFailed
    ArticleComplete --> ArticleInsights
    ArticleInsights --> ArticleExplore
    ArticleExplore --> ArticleRelated

    ArticleInsights -->|click| InsightBody
    InsightBody --> InsightSources
    InsightSources --> InsightSiblings
    InsightSiblings --> InsightRelated

    SearchPending --> SearchSearching
    SearchSearching --> SearchComplete
    SearchComplete --> SearchExplore
    SearchExplore -->|click| SearchPending
```

---

## 12. Data Storage Architecture

```mermaid
flowchart TB
    subgraph Application["Rails Application"]
        Models[ActiveRecord Models]
        Jobs[Background Jobs]
        Cable[ActionCable]
    end

    subgraph PostgreSQL["PostgreSQL Database"]
        subgraph Tables["Tables"]
            Articles[(articles)]
            Insights[(insights)]
            Searches[(searches)]
            SearchArticles[(search_articles)]
        end

        subgraph Extensions["Extensions"]
            PGVector[pgvector<br/>Vector similarity]
            PGCrypto[pgcrypto<br/>Random IDs]
        end

        subgraph Functions["Custom Functions"]
            NanoID[nanoid()<br/>Generate identifiers]
        end
    end

    subgraph Redis["Redis"]
        PubSub[Pub/Sub Channels]
        Cache[Application Cache]
    end

    Models <-->|CRUD| Tables
    Models <-->|Vector ops| PGVector
    Models -->|Generate ID| NanoID

    Jobs --> Models
    Models -->|Broadcast| Cable
    Cable <-->|Subscribe/Publish| PubSub

    Models <-.->|Cache| Cache
```

---

## 13. Extension Points for DKR

```mermaid
flowchart TB
    subgraph Current["Current Jargon"]
        Articles[Articles]
        Insights[Insights]
        Searches[Searches]
        Embeddings[Vector Embeddings]
    end

    subgraph Extensions["DKR Extensions"]
        subgraph NewSources["New Content Sources"]
            Obsidian[Obsidian Notes]
            Roam[Roam Pages]
            Notion[Notion Docs]
        end

        subgraph Agents["AI Agents"]
            DKRAgent[DKR Synthesis Agent]
            MatchAgent[Matchmaking Agent]
            GapAgent[Gap Analysis Agent]
        end

        subgraph Export["Export Formats"]
            ObsidianMD[Obsidian Markdown]
            RoamEDN[Roam EDN]
            GraphML[GraphML]
        end

        subgraph Integration["External Integration"]
            API[REST API]
            MCP[MCP Server]
            Webhooks[Webhooks]
        end

        subgraph MultiUser["Multi-User"]
            Workspaces[Workspaces]
            Projects[Projects]
            Sharing[Cross-vault sharing]
        end
    end

    Articles --> NewSources
    Insights --> Agents
    Searches --> Export
    Embeddings --> Integration

    NewSources --> Agents
    Agents --> Export
    Export --> Integration
    Integration --> MultiUser
```

---

## 14. Totem Protocol Meta-Level View

```mermaid
flowchart TB
    subgraph UserWork["User Knowledge Work Activities"]
        Chat[Chat Sessions<br/>GPT, Claude, etc.]
        Research[Research Sessions<br/>Jargon DKR]
        Design[Design Sessions<br/>GenAI Studio]
        Writing[Writing Sessions<br/>Docs, Notes]
    end

    subgraph Problem["The Problem: Ephemeral Work"]
        Lost1[Session ends → Lost]
        Lost2[No connections]
        Lost3[Start over each time]
    end

    subgraph Totem["Totem Protocol Layer"]
        Identity[Persistent Identity<br/>OAuth / API Keys]

        subgraph Artifacts["Artifact Galleries"]
            GenAI[GenAI Gallery<br/>Characters, Scenes]
            Insights[Insight Gallery<br/>Synthesized Knowledge]
            Research2[Research Threads<br/>Connected Queries]
            Memory[Memory Artifacts<br/>Cross-session Context]
        end

        subgraph Agents["Letta Memory Agents"]
            Synthesize[Synthesize Agent]
            Transform[Transform Agent]
            Persist[Persist Agent]
            Retrieve[Retrieve Agent]
        end
    end

    subgraph Surfaces["Access Surfaces"]
        Web[Web Apps]
        Obsidian[Obsidian Plugin]
        Claude[Claude Code]
        Goose[Goose Recipe]
    end

    Chat --> Lost1
    Research --> Lost2
    Design --> Lost3

    UserWork -->|with Totem| Identity
    Identity --> Artifacts
    Artifacts <--> Agents

    Surfaces --> Identity
    Identity --> Surfaces

    style Problem fill:#ffcccc
    style Totem fill:#ccffcc
```

---

## 15. Second-Order Feedback Loop (Engelbart DKR)

```mermaid
flowchart TB
    subgraph CLevel["C-Level: Improving How We Improve"]
        C1[Analyze prompt modification patterns]
        C2[Discover what makes synthesis effective]
        C3[Build reusable improvement templates]
        C4[Train others on meta-cognitive skills]
    end

    subgraph BLevel["B-Level: Improving How We Work"]
        B1[Modify prompts in 5 functions]
        B2[Observe how changes affect outputs]
        B3[Specialize workflows per context]
        B4[Tune clustering thresholds]

        Intervention["⬅️ JARGON'S EXPOSED PROMPTS<br/>ENABLE INTERVENTION HERE"]
    end

    subgraph ALevel["A-Level: Direct Knowledge Work"]
        A1[Ingest articles, papers, videos]
        A2[Read summaries and insights]
        A3[Follow research threads]
        A4[Explore connections]
    end

    CLevel -->|informs| BLevel
    BLevel -->|improves| ALevel
    ALevel -->|reveals patterns| BLevel
    BLevel -->|generates insights| CLevel

    style BLevel fill:#ffffcc
    style Intervention fill:#ffff00
```

---

## 16. Workspace-Aware Agent Architecture

```mermaid
flowchart TD
    subgraph User["User Context"]
        Workspace[Workspace Selection<br/>in Obsidian]
    end

    subgraph Definitions["Workspace Definitions"]
        Academic["Academic Research<br/>• Peer-reviewed focus<br/>• Formal tone<br/>• Strict clustering (0.15)"]
        Startup["Startup Ideation<br/>• Market trends focus<br/>• Actionable tone<br/>• Loose clustering (0.4)"]
        Legal["Legal Review<br/>• Citation required<br/>• Precise language<br/>• Conservative clustering"]
    end

    subgraph LettaLayer["Letta Agent Layer (cron-scheduled)"]
        Observer[Context Observer Agent]
        Modifier[Prompt Modifier Agent]
        Quality[Quality Assessor Agent]
    end

    subgraph Pipeline["Jargon DKR Pipeline"]
        direction LR
        P1[INGEST]
        P2[SUMMARIZE]
        P3[EXTRACT]
        P4[CONNECT]
        P5[THREAD]

        PR1[prompt]
        PR2[prompt]
        PR3[prompt]
        PR4[prompt]
        PR5[prompt]
    end

    Workspace --> Definitions
    Definitions --> Observer
    Observer --> Modifier
    Modifier -->|inject context| PR1
    Modifier -->|inject context| PR2
    Modifier -->|inject context| PR3
    Modifier -->|inject context| PR4
    Modifier -->|inject context| PR5

    P1 --- PR1
    P2 --- PR2
    P3 --- PR3
    P4 --- PR4
    P5 --- PR5

    Quality -->|assess output| Observer
```

---

## 17. Mental Modelling Agency Curriculum

```mermaid
flowchart LR
    subgraph Module1["Module 1"]
        M1[Understanding<br/>Feedback Loops]
    end

    subgraph Module2["Module 2"]
        M2[The DKR<br/>Pipeline]
    end

    subgraph Module3["Module 3"]
        M3[Second-Order<br/>Improvement]
    end

    subgraph Module4["Module 4"]
        M4[Context<br/>Engineering]
    end

    subgraph Module5["Module 5"]
        M5[Agent<br/>Design]
    end

    subgraph Module6["Module 6"]
        M6[Integration<br/>Patterns]
    end

    Module1 --> Module2
    Module2 --> Module3
    Module3 --> Module4
    Module4 --> Module5
    Module5 --> Module6

    subgraph Labs["Hands-On Labs"]
        L1[Map your workflow]
        L2[Modify a prompt]
        L3[Design intervention]
        L4[Configure workspace]
        L5[Build observer agent]
        L6[Connect to Totem]
    end

    M1 --> L1
    M2 --> L2
    M3 --> L3
    M4 --> L4
    M5 --> L5
    M6 --> L6
```

---

## 18. Jargon vs Perplexity Comparison

```mermaid
flowchart LR
    subgraph Perplexity["Perplexity.ai"]
        P_Input[User Question]
        P_Hidden["🔒 Hidden Prompts"]
        P_Output[Answer]
        P_Lost[Session Ends → Lost]

        P_Input --> P_Hidden
        P_Hidden --> P_Output
        P_Output --> P_Lost
    end

    subgraph Jargon["Jargon DKR"]
        J_Input[User Question]
        J_Visible["🔓 Exposed Prompts<br/>You can modify!"]
        J_Output[Answer + Insights]
        J_Persist[Persistent Graph]
        J_Connect[Auto-Connected]
        J_Thread[Recursive Threads]

        J_Input --> J_Visible
        J_Visible --> J_Output
        J_Output --> J_Persist
        J_Persist --> J_Connect
        J_Connect --> J_Thread
        J_Thread -.->|spawns more| J_Input
    end

    style P_Hidden fill:#ffcccc
    style J_Visible fill:#ccffcc
    style P_Lost fill:#ffcccc
    style J_Persist fill:#ccffcc
```

---

## Rendering These Diagrams

These diagrams use [Mermaid](https://mermaid.js.org/) syntax and can be rendered in:

1. **GitHub** - Renders automatically in markdown files
2. **VS Code** - Install "Markdown Preview Mermaid Support" extension
3. **Obsidian** - Built-in Mermaid support
4. **Online** - [Mermaid Live Editor](https://mermaid.live/)

To export as images:
```bash
# Install mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# Convert to PNG
mmdc -i DIAGRAMS.md -o diagrams/ -e png
```

---

*Generated for Totem Protocol / DKR Prototype Development*
