# Dynamic Knowledge Repository (DKR) Future Specification

## Totem Protocol Integration Roadmap

---

## Executive Summary

This specification outlines the evolution of Jargon into a **Dynamic Knowledge Repository (DKR)** prototype, implementing Doug Engelbart's methodology for continuous improvement through **second-order feedback loops** in knowledge work. Unlike closed systems like Perplexity.ai, Jargon's open architecture exposes the prompts governing AI behavior, enabling users and developers to observe, modify, and improve the knowledge synthesis process itself.

This capability positions Totem Protocol as a **meta-layer for knowledge work**—providing users with the mental models and viewport exposition necessary to establish feedback loops across all surfaces where they engage in intellectual work.

---

## 1. The Jargon Differentiator

### 1.1 What Makes Jargon Unique

Most AI application templates treat LLM integration as a black box:

| Typical AI Apps | Jargon/DKR Approach |
|-----------------|---------------------|
| Fixed, hidden prompts | Exposed, modifiable prompts |
| Single-purpose agents | Composable 5-function pipeline |
| No feedback mechanism | Second-order improvement loop |
| Ephemeral sessions | Persistent knowledge graph |
| Framework-locked | Ruby-native, concern-based |

### 1.2 The Five Core Functions

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     JARGON DKR PIPELINE                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌────────┐│
│  │ 1.INGEST │──▶│2.SUMMAR- │──▶│3.EXTRACT │──▶│4.CONNECT │──▶│5.THREAD││
│  │          │   │   IZE    │   │          │   │          │   │        ││
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘   └────────┘│
│       │              │              │              │              │     │
│       ▼              ▼              ▼              ▼              ▼     │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌────────┐│
│  │ Content  │   │   AI     │   │ Insights │   │ Similar  │   │Research││
│  │ scraped  │   │ distills │   │ become   │   │ content  │   │questions│
│  │ & parsed │   │key points│   │linked    │   │ clusters │   │find    ││
│  │          │   │          │   │ cards    │   │          │   │ more   ││
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘   └────────┘│
│                                                                          │
│  Each function has an EXPOSED PROMPT that can be:                       │
│    • Observed (understand AI reasoning)                                  │
│    • Modified (change behavior)                                          │
│    • Specialized (per workspace/project)                                 │
│    • Learned from (meta-improvement)                                     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.3 Prompt Locations (Current Implementation)

| Function | File | Prompt Location |
|----------|------|-----------------|
| **Ingest** | `ingest_article_job.rb` | `CONTENT_EVALUATION_INSTRUCTIONS` (line 16) |
| **Summarize** | `ingest_article_job.rb` | `SUMMARY_INSTRUCTIONS` (line 4) |
| **Extract** | `generate_insights_job.rb` | `build_prompt()` (line 40) |
| **Connect** | `article/sameness_check.rb` | LLM comparison prompt (line 34) |
| **Thread** | `search_generatable.rb` | `QUERIES_PROMPT` (line 8) |

---

## 2. Second-Order Feedback Loop

### 2.1 Engelbart's DKR Vision

Doug Engelbart's Dynamic Knowledge Repository concept describes a system where:

1. **A-Level Activity**: Direct knowledge work (reading, writing, synthesizing)
2. **B-Level Activity**: Improving how we do A-Level work
3. **C-Level Activity**: Improving how we improve (meta-improvement)

Jargon's architecture enables all three levels:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    ENGELBART'S DKR LEVELS                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ C-LEVEL: Improving How We Improve                                │   │
│  │                                                                   │   │
│  │  • Analyzing patterns in prompt modifications                    │   │
│  │  • Discovering what makes knowledge synthesis effective          │   │
│  │  • Building reusable improvement templates                       │   │
│  │  • Training others on meta-cognitive skills                      │   │
│  │                                                                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              │                                           │
│                              ▼                                           │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ B-LEVEL: Improving How We Work                                   │   │
│  │                                                                   │   │
│  │  • Modifying prompts in the 5 functions                          │   │
│  │  • Observing how changes affect outputs                          │   │
│  │  • Specializing workflows for different contexts                 │   │
│  │  • Tuning clustering thresholds and matching criteria            │   │
│  │                                                                   │   │
│  │  THIS IS WHERE JARGON'S EXPOSED PROMPTS ENABLE INTERVENTION      │   │
│  │                                                                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              │                                           │
│                              ▼                                           │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ A-LEVEL: Direct Knowledge Work                                   │   │
│  │                                                                   │   │
│  │  • Ingesting articles, papers, videos                            │   │
│  │  • Reading summaries and insights                                │   │
│  │  • Following research threads                                    │   │
│  │  • Exploring connections                                         │   │
│  │                                                                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 2.2 The Intervention Point

The critical architectural insight is that Jargon's concern-based design creates natural **intervention points** where agents can observe and modify behavior:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      INTERVENTION ARCHITECTURE                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│                         USER CONTEXT                                     │
│                              │                                           │
│                              ▼                                           │
│                    ┌──────────────────┐                                  │
│                    │ Workspace Signal │                                  │
│                    │ (Obsidian vault, │                                  │
│                    │  project, mode)  │                                  │
│                    └────────┬─────────┘                                  │
│                             │                                            │
│                             ▼                                            │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    LETTA AGENT LAYER                              │   │
│  │                    (Scheduled via cron)                           │   │
│  │                                                                   │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐               │   │
│  │  │  Context    │  │  Prompt     │  │  Quality    │               │   │
│  │  │  Observer   │  │  Modifier   │  │  Assessor   │               │   │
│  │  │  Agent      │  │  Agent      │  │  Agent      │               │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘               │   │
│  │                                                                   │   │
│  └────────────────────────────┬─────────────────────────────────────┘   │
│                               │                                          │
│                               ▼                                          │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                 JARGON DKR PIPELINE                               │   │
│  │                                                                   │   │
│  │  INGEST ──▶ SUMMARIZE ──▶ EXTRACT ──▶ CONNECT ──▶ THREAD         │   │
│  │    │           │            │           │           │            │   │
│  │    ▼           ▼            ▼           ▼           ▼            │   │
│  │  [prompt]   [prompt]     [prompt]    [prompt]    [prompt]        │   │
│  │    ▲           ▲            ▲           ▲           ▲            │   │
│  │    │           │            │           │           │            │   │
│  │    └───────────┴────────────┴───────────┴───────────┘            │   │
│  │                         │                                         │   │
│  │              DYNAMIC PROMPT INJECTION                             │   │
│  │              (based on workspace context)                         │   │
│  │                                                                   │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Totem Protocol Meta-Layer Vision

### 3.1 The Knowledge Work Viewport

Totem Protocol provides users with a **meta-level view across all knowledge work activities**:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                TOTEM PROTOCOL: META-LEVEL VIEWPORT                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│                        USER'S KNOWLEDGE WORK                             │
│                                                                          │
│   ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐           │
│   │  Chat     │  │  Research │  │  Design   │  │  Writing  │           │
│   │  Sessions │  │  Sessions │  │  Sessions │  │  Sessions │           │
│   └─────┬─────┘  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘           │
│         │              │              │              │                   │
│         └──────────────┴──────────────┴──────────────┘                   │
│                              │                                           │
│                              ▼                                           │
│  ╔══════════════════════════════════════════════════════════════════╗   │
│  ║                    TOTEM PROTOCOL LAYER                          ║   │
│  ║                                                                   ║   │
│  ║   ┌─────────────────────────────────────────────────────────┐   ║   │
│  ║   │              PERSISTENT IDENTITY                         │   ║   │
│  ║   │   Google OAuth / Social Login / API Keys                 │   ║   │
│  ║   └─────────────────────────────────────────────────────────┘   ║   │
│  ║                              │                                   ║   │
│  ║                              ▼                                   ║   │
│  ║   ┌─────────────────────────────────────────────────────────┐   ║   │
│  ║   │              KNOWLEDGE ARTIFACTS                         │   ║   │
│  ║   │                                                          │   ║   │
│  ║   │   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐   │   ║   │
│  ║   │   │ GenAI   │  │ Insight │  │ Research│  │ Memory  │   │   ║   │
│  ║   │   │ Gallery │  │ Gallery │  │ Threads │  │Artifacts│   │   ║   │
│  ║   │   └─────────┘  └─────────┘  └─────────┘  └─────────┘   │   ║   │
│  ║   │                                                          │   ║   │
│  ║   └─────────────────────────────────────────────────────────┘   ║   │
│  ║                              │                                   ║   │
│  ║                              ▼                                   ║   │
│  ║   ┌─────────────────────────────────────────────────────────┐   ║   │
│  ║   │              LETTA MEMORY AGENTS                         │   ║   │
│  ║   │   Synthesize │ Transform │ Persist │ Retrieve            │   ║   │
│  ║   └─────────────────────────────────────────────────────────┘   ║   │
│  ║                                                                   ║   │
│  ╚══════════════════════════════════════════════════════════════════╝   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Multi-Surface Integration

Users interact with Totem Protocol through multiple surfaces, all connected to the same persistent identity and artifact store:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                   TOTEM PROTOCOL SURFACES                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐          │
│  │  WEB APPS       │  │  IDE PLUGINS    │  │  AGENT RECIPES  │          │
│  │                 │  │                 │  │                 │          │
│  │  • Jargon DKR   │  │  • Obsidian     │  │  • Goose Recipe │          │
│  │  • GenAI Studio │  │  • VS Code      │  │  • Claude Code  │          │
│  │  • Neg. Space   │  │  • Cursor       │  │  • GitHub Copilot│         │
│  │                 │  │                 │  │                 │          │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘          │
│           │                    │                    │                    │
│           └────────────────────┼────────────────────┘                    │
│                                │                                         │
│                                ▼                                         │
│           ┌────────────────────────────────────────┐                    │
│           │         TOTEM PROTOCOL CORE            │                    │
│           │                                        │                    │
│           │   • JSON Translation Layer             │                    │
│           │   • Persistent Identity (OAuth)        │                    │
│           │   • Artifact Storage                   │                    │
│           │   • Cross-session Memory (Letta)       │                    │
│           │   • Context Engineering                │                    │
│           │                                        │                    │
│           └────────────────────────────────────────┘                    │
│                                                                          │
│  SAME USER ──▶ SAME IDENTITY ──▶ SAME ARTIFACTS ──▶ ANY SURFACE        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Use Case: GenAI Design Studio

### 4.1 The Problem with Off-the-Shelf Tools

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    OFF-THE-SHELF NANO BANANA                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   Session 1                    Session 2                    Session 3   │
│   ─────────                    ─────────                    ─────────   │
│   Create character ──▶ LOST    Create character ──▶ LOST    Start over │
│   Set lighting    ──▶ LOST    Set lighting    ──▶ LOST    ...         │
│   Design scene    ──▶ LOST    Design scene    ──▶ LOST                 │
│                                                                          │
│   NO PERSISTENCE │ NO LIBRARY │ NO BRAND CONSISTENCY                    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 4.2 The Totem Solution

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    TOTEM GENAI DESIGN STUDIO                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                    USER LOGS IN (OAuth)                          │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                │                                         │
│                                ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                    ARTIFACT GALLERY                              │   │
│   │                                                                  │   │
│   │   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐           │   │
│   │   │Character│  │Character│  │ Scene   │  │ Brand   │           │   │
│   │   │ "Luna"  │  │ "Max"   │  │"Studio" │  │ Assets  │           │   │
│   │   │         │  │         │  │         │  │         │           │   │
│   │   │ Camera: │  │ Camera: │  │Lighting:│  │ Colors: │           │   │
│   │   │ closeup │  │ wide    │  │ golden  │  │ #FF0000 │           │   │
│   │   │ Pose:   │  │ Pose:   │  │Location:│  │ Fonts:  │           │   │
│   │   │ sitting │  │ running │  │ beach   │  │ Roboto  │           │   │
│   │   └─────────┘  └─────────┘  └─────────┘  └─────────┘           │   │
│   │                                                                  │   │
│   │   PERSISTENT │ REUSABLE │ BRAND CONSISTENT                      │   │
│   │                                                                  │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                │                                         │
│                                ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                    ACCESS FROM ANY SURFACE                       │   │
│   │                                                                  │   │
│   │   [Goose Recipe]  [Claude Code]  [Web App]  [Obsidian Plugin]   │   │
│   │                                                                  │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Use Case: Negative Space GPT Integration

### 5.1 The Problem

```
┌─────────────────────────────────────────────────────────────────────────┐
│                OFF-THE-SHELF CUSTOM GPT SESSIONS                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   Session 1: Gap Analysis on Topic A                                     │
│       │                                                                  │
│       └──▶ Valuable insights generated ──▶ LOST when session ends       │
│                                                                          │
│   Session 2: Gap Analysis on Topic B                                     │
│       │                                                                  │
│       └──▶ Connections to Topic A possible ──▶ BUT NOT VISIBLE          │
│                                                                          │
│   NO CROSS-SESSION MEMORY │ NO SYNTHESIS │ NO ACCUMULATION              │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 5.2 The Totem Solution

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    TOTEM NEGATIVE SPACE INTEGRATION                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   User logs in ──▶ Totem Plugin activates ──▶ Letta agents start        │
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                 BACKGROUND WORKFLOWS                             │   │
│   │                                                                  │   │
│   │   ┌─────────────┐      ┌─────────────┐      ┌─────────────┐    │   │
│   │   │ InfraNodus  │ ──▶  │ Gap Analysis│ ──▶  │  Synthesis  │    │   │
│   │   │ Integration │      │   Agent     │      │    Agent    │    │   │
│   │   └─────────────┘      └─────────────┘      └─────────────┘    │   │
│   │                                                                  │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                │                                         │
│                                ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                 INSIGHT GALLERY                                  │   │
│   │                                                                  │   │
│   │   Session 1 insights ──┐                                        │   │
│   │   Session 2 insights ──┼──▶ CONNECTED │ ACCUMULATED │ SEARCHABLE│   │
│   │   Session N insights ──┘                                        │   │
│   │                                                                  │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                │                                         │
│                                ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                 LETTA MEMORY AGENTS                              │   │
│   │                                                                  │   │
│   │   • Synthesize session outputs into memory artifacts            │   │
│   │   • Transform into various formats (Obsidian, Roam, etc.)       │   │
│   │   • Persist across providers and models                          │   │
│   │   • Surface relevant context in future sessions                  │   │
│   │                                                                  │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Future Architecture: Workspace-Aware Agents

### 6.1 The Intervention Point Design

```
┌─────────────────────────────────────────────────────────────────────────┐
│              WORKSPACE-AWARE PROMPT MODIFICATION                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   USER SELECTS WORKSPACE IN OBSIDIAN                                     │
│         │                                                                │
│         ▼                                                                │
│   ┌───────────────────────────────────────────────────────────────┐     │
│   │                    WORKSPACE DEFINITION                        │     │
│   │                                                                │     │
│   │   Workspace: "Academic Research"                               │     │
│   │   ├── Focus: peer-reviewed sources                            │     │
│   │   ├── Tone: formal, citation-heavy                            │     │
│   │   ├── Clustering: strict (0.15 threshold)                     │     │
│   │   └── Threading: deep, methodological                          │     │
│   │                                                                │     │
│   │   Workspace: "Startup Ideation"                                │     │
│   │   ├── Focus: market trends, competitor analysis               │     │
│   │   ├── Tone: actionable, concise                               │     │
│   │   ├── Clustering: loose (0.4 threshold)                       │     │
│   │   └── Threading: broad, opportunity-finding                    │     │
│   │                                                                │     │
│   └───────────────────────────────────────────────────────────────┘     │
│         │                                                                │
│         ▼                                                                │
│   ┌───────────────────────────────────────────────────────────────┐     │
│   │              LETTA AGENT: PROMPT MODIFIER                      │     │
│   │                                                                │     │
│   │   Observes: Current workspace context                          │     │
│   │   Modifies: Prompts for all 5 DKR functions                    │     │
│   │   Scheduled: via cron-job, continuous observation              │     │
│   │                                                                │     │
│   │   function modify_prompts(workspace_context):                  │     │
│   │       for function in [INGEST, SUMMARIZE, EXTRACT,            │     │
│   │                        CONNECT, THREAD]:                       │     │
│   │           base_prompt = get_base_prompt(function)              │     │
│   │           modified = inject_context(base_prompt,               │     │
│   │                                     workspace_context)         │     │
│   │           set_active_prompt(function, modified)                │     │
│   │                                                                │     │
│   └───────────────────────────────────────────────────────────────┘     │
│         │                                                                │
│         ▼                                                                │
│   ┌───────────────────────────────────────────────────────────────┐     │
│   │              MODIFIED DKR PIPELINE                             │     │
│   │                                                                │     │
│   │   INGEST ──▶ SUMMARIZE ──▶ EXTRACT ──▶ CONNECT ──▶ THREAD     │     │
│   │   [mod]      [mod]        [mod]       [mod]       [mod]        │     │
│   │                                                                │     │
│   │   Behavior now reflects workspace context                       │     │
│   │                                                                │     │
│   └───────────────────────────────────────────────────────────────┘     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Implementation Roadmap

```
PHASE 1: Foundation (Current)
├── ✅ Jargon fork operational
├── ✅ 5 functions identified and documented
├── ✅ Prompt locations mapped
└── ✅ Architecture documented

PHASE 2: Intervention Points
├── 🔲 Create PromptRegistry concern
├── 🔲 Extract prompts to configurable layer
├── 🔲 Add workspace model
├── 🔲 Implement prompt injection mechanism
└── 🔲 Build workspace selection UI

PHASE 3: Agent Integration
├── 🔲 Letta Bridge integration
├── 🔲 Context Observer agent
├── 🔲 Prompt Modifier agent
├── 🔲 Cron-based scheduling
└── 🔲 Obsidian plugin workspace sync

PHASE 4: Multi-Surface
├── 🔲 OAuth persistent identity
├── 🔲 Artifact gallery API
├── 🔲 Cross-surface synchronization
└── 🔲 Memory agent deployment
```

---

## 7. Educational Framework: Mental Modelling Agency

### 7.1 Core Concept

The **Mental Modelling Agency** is a Totem Protocol framework component that teaches users to:

1. **Observe** their knowledge work patterns
2. **Model** the feedback loops in their workflows
3. **Intervene** at strategic points to improve outcomes
4. **Iterate** on their meta-cognitive processes

### 7.2 Curriculum Structure

```
┌─────────────────────────────────────────────────────────────────────────┐
│               SENSE COLLECTIVE EDUCATIONAL PROGRAMMING                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   MODULE 1: Understanding Feedback Loops                                 │
│   ├── What is a knowledge work feedback loop?                           │
│   ├── Identifying loops in your daily work                              │
│   └── Lab: Map your personal knowledge workflow                          │
│                                                                          │
│   MODULE 2: The DKR Pipeline                                             │
│   ├── The 5 functions (Ingest, Summarize, Extract, Connect, Thread)     │
│   ├── How prompts shape AI behavior                                      │
│   └── Lab: Modify a prompt, observe the change                           │
│                                                                          │
│   MODULE 3: Second-Order Improvement                                     │
│   ├── Engelbart's A/B/C levels                                          │
│   ├── Meta-cognition in practice                                         │
│   └── Lab: Design a B-level intervention                                 │
│                                                                          │
│   MODULE 4: Context Engineering                                          │
│   ├── What is context? How do agents use it?                            │
│   ├── Workspace-aware systems                                            │
│   └── Lab: Configure workspace-specific prompts                          │
│                                                                          │
│   MODULE 5: Agent Design                                                 │
│   ├── System-agnostic agent architecture                                │
│   ├── Letta memory patterns                                              │
│   └── Lab: Build a custom observation agent                              │
│                                                                          │
│   MODULE 6: Integration Patterns                                         │
│   ├── Multi-surface deployment                                           │
│   ├── Persistent identity across tools                                   │
│   └── Lab: Connect your Obsidian vault to Totem                          │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Technical Specifications

### 8.1 Prompt Registry Interface

```ruby
# Future: app/models/concerns/prompt_registry.rb

module PromptRegistry
  extend ActiveSupport::Concern

  class_methods do
    def register_prompt(name, &block)
      prompt_registry[name] = block
    end

    def prompt_for(name, context = {})
      base_prompt = prompt_registry[name].call
      PromptModifier.apply(base_prompt, context)
    end

    def prompt_registry
      @prompt_registry ||= {}
    end
  end
end

# Usage in jobs:
class IngestArticleJob < ApplicationJob
  include PromptRegistry

  register_prompt :summary do
    <<~PROMPT
      Distill the article's key idea into a summary.
      Voice: State the finding directly.
      Length: 200-300 characters.
    PROMPT
  end

  def perform(article)
    prompt = prompt_for(:summary, workspace: article.workspace)
    # ... use modified prompt
  end
end
```

### 8.2 Workspace Model

```ruby
# Future: app/models/workspace.rb

class Workspace < ApplicationRecord
  has_many :articles
  has_many :insights
  has_many :searches

  # Prompt modification rules
  jsonb :prompt_overrides, default: {}

  # Clustering configuration
  attribute :article_threshold, :float, default: 0.3
  attribute :insight_threshold, :float, default: 0.25

  # Context signals
  attribute :focus_areas, :string, array: true, default: []
  attribute :tone, :string, default: 'neutral'
end
```

### 8.3 Letta Integration Interface

```ruby
# Future: app/services/letta_bridge.rb

class LettaBridge
  def initialize(workspace)
    @workspace = workspace
    @client = Letta::Client.new(api_key: ENV['LETTA_API_KEY'])
  end

  def observe_context
    @client.memory.read(
      agent_id: context_observer_agent_id,
      query: "current workspace state"
    )
  end

  def modify_prompts(context)
    PromptModifier.new(@workspace, context).apply_all
  end

  def schedule_observation(cron: "*/5 * * * *")
    @client.schedule.create(
      agent_id: context_observer_agent_id,
      cron: cron,
      action: :observe_and_modify
    )
  end
end
```

---

## 9. Success Metrics

| Metric | Baseline | Target |
|--------|----------|--------|
| Time to modify workflow | N/A (not possible) | < 5 minutes |
| Cross-session artifact retention | 0% | 100% |
| Workspace context accuracy | N/A | > 90% |
| User B-level interventions/week | 0 | > 3 |
| Knowledge artifact accumulation | Session-bound | Unbounded |

---

## 10. Appendix: Comparison with Perplexity.ai

| Aspect | Perplexity.ai | Jargon DKR |
|--------|---------------|------------|
| **Prompts** | Hidden, fixed | Exposed, modifiable |
| **Persistence** | Session-only | Permanent knowledge graph |
| **Clustering** | None | Automatic via embeddings |
| **Research threads** | Single-level | Recursive, unbounded |
| **Improvement** | Vendor-controlled | User-controlled (B-level) |
| **Integration** | Standalone | Multi-surface via Totem |
| **Framework** | Proprietary | Open Ruby/Rails |

---

*This specification is a living document for Totem Protocol / Sense Collective development.*

*Version: 1.0*
*Date: December 2024*
