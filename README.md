<div align="center">
  <img width="100" src="app/assets/images/sense-collective-icon.png" />
  <h1>Sense Collective</h1>
  <p><strong>D</strong>ynamic <strong>K</strong>nowledge <strong>E</strong>cosystem</p>
</div>

Sense Collective is an AI-managed knowledge system that parses articles, papers, and videos into interconnected insight cards. It summarizes sources, extracts key ideas, links related concepts, and automatically clusters duplicates using semantic embeddings.

Each source is parsed in context of existing cards, generating new insights that link back to the original material. The result is a knowledge base of interlinked ideas that can be explored directly or used as a RAG to answer questions. Questions also pull results from the web, which flow through the same extract/summarize/link pipeline before being synthesized with library content.

## Attribution

This project is a fork of [Jargon](https://github.com/jargon-io/jargon) by [@schoblaska](https://github.com/schoblaska). The original Jargon project provides the core architecture for content ingestion, insight extraction, and semantic linking. We are grateful for their work in making this foundation available under GPL-3.0.

## Core Loop

1. **Ingest** — Articles, PDFs, and YouTube videos are scraped and parsed
2. **Summarize** — LLM distills each source into a concise summary
3. **Extract** — Key ideas become standalone insight cards with source links
4. **Connect** — Embeddings find related insights; duplicates collapse automatically
5. **Thread** — Each node gets research questions that search the web for more sources

## Features

### PDF Full-Text Extraction

Academic papers and PDFs are automatically downloaded and converted to text using `pdftotext`. Follows "full text" and DOI links from abstracts.

### YouTube Transcripts

YouTube URLs are detected and transcripts are fetched directly from YouTube's API. Speakers are extracted from video titles when available.

### Insight Extraction

Key findings are extracted as standalone insights with titles, explanations, and source snippets. Insights are independently searchable and linkable.

### Semantic Embeddings

Articles and insights are embedded using OpenAI's text-embedding-3-small model. Embeddings power similarity search and automatic clustering.

### Automatic Clustering

Similar articles (syndicated content, republished pieces) are automatically grouped using vector similarity and title matching. Similar insights cluster into themes.

### Research Threads

Each insight can spawn research threads—questions that trigger web searches via Exa to find related articles. Discovered articles are automatically ingested and indexed.

### Library Search

Ask a question or enter a topic to search your library. Finds relevant insights using semantic similarity and displays them alongside the source articles.

### Web Search

Augment library results with fresh content from the web. Results are fetched via Exa's neural search and automatically ingested into your library.

## Tech Stack

- **[Rails](https://rubyonrails.org/)** and **[Hotwire](https://hotwired.dev/)**
- **[Falcon](https://github.com/socketry/falcon)** - Async Ruby application server with fiber-based concurrency
- **[async-job](https://github.com/socketry/async-job)** - Background job processing without a separate worker process
- **[RubyLLM](https://github.com/contextco/ruby_llm)** - Unified interface to OpenAI, Anthropic, Gemini, and OpenRouter
- **[ruby_llm-schema](https://github.com/schoblaska/ruby_llm-schema)** - Structured JSON output from LLMs via schema definitions
- **[pgvector](https://github.com/pgvector/pgvector)** - Vector similarity search in PostgreSQL
- **[Exa](https://exa.ai)** - Neural search API for finding related content
- **[crawl4ai](https://github.com/unclecode/crawl4ai)** - Fallback web scraper with browser rendering
- **[pdftotext](https://manpages.debian.org/testing/poppler-utils/pdftotext.1.en.html)** - Text extractor for PDF content

## Configuration

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

### LLM Providers

Set API keys for the providers you want to use. RubyLLM supports OpenRouter, OpenAI, Anthropic, and Google Gemini:

```bash
OPENROUTER_API_KEY=your-key    # OpenRouter (default, proxies all providers)
OPENAI_API_KEY=your-key        # Direct OpenAI access
ANTHROPIC_API_KEY=your-key     # Direct Anthropic access
GEMINI_API_KEY=your-key        # Direct Google Gemini access
```

### Model and Provider Selection

Override default models and providers via environment variables:

```bash
LLM_MODEL=google/gemini-2.5-flash              # Chat model (default)
LLM_PROVIDER=openrouter                        # Chat provider (default)
EMBEDDING_MODEL=openai/text-embedding-3-small  # Embedding model (default)
EMBEDDING_PROVIDER=openrouter                  # Embedding provider (default)
```

Provider must match the API key you're using. OpenRouter model names use `provider/model` format.

### Rails Master Key

Set `SECRET_KEY_BASE` instead of using `config/master.key`:

```bash
SECRET_KEY_BASE=secret-key-base
```

## Dependencies

### crawl4ai

Fallback crawler when Exa is unavailable. Install via pip:

```bash
pip install crawl4ai
crawl4ai-setup  # Downloads browser dependencies
```

### pdftotext

Used for extracting text from PDF documents (academic papers, etc.). Install via poppler:

```bash
# macOS
brew install poppler

# Ubuntu/Debian
apt-get install poppler-utils
```

## Docker Deployment

Run with Docker Compose using the published image from GitHub Container Registry.

Create a `docker-compose.yml`:

```yaml
services:
  app:
    image: ghcr.io/your-username/sense-collective:latest
    ports:
      - "3000:80"
    env_file: .env
    environment:
      DATABASE_URL: postgres://postgres:postgres@db:5432/sense_collective
      REDIS_URL: redis://redis:6379/0
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started

  db:
    image: pgvector/pgvector:pg17
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: sense_collective
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

Create a `.env` file with your secrets:

```bash
SECRET_KEY_BASE=secret-key-base
OPENROUTER_API_KEY=your-openrouter-key
EXA_API_KEY=your-exa-key
```

Start the stack:

```bash
docker compose up -d
```

The app will be available at http://localhost:3000.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE.md), the same license as the original [Jargon](https://github.com/jargon-io/jargon) project.
