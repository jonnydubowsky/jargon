# Deploying Sense Collective (JargonDKR) to Fly.io

The first public Rails URL for the stack. ShurIQ Report Studio lives on Cloudflare
Pages (React) and can't host Rails, so the Rails apps (Jargon, and later Aethelgard)
get their own host. Fly matches the repo's Docker/Falcon + Postgres/pgvector setup.

These steps need *your* Fly account and API keys, so run them yourself (`fly auth login`
is interactive). `fly.toml` is already committed; adjust `app` / `primary_region` first.

## Prerequisites

- `brew install flyctl` (or `curl -L https://fly.io/install.sh | sh`)
- `fly auth login`

## 1. Create the app (no deploy yet)

```bash
fly apps create sense-collective   # or: fly launch --no-deploy --copy-config
```

## 2. Postgres with pgvector

The app uses `pgvector`. Fly Managed Postgres supports the `vector` extension.

```bash
fly mpg create --name sense-collective-db --region iad
fly mpg attach sense-collective-db --app sense-collective   # sets DATABASE_URL
```

Enable the extension once (migrations also attempt this):

```bash
fly mpg connect sense-collective-db -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

## 3. Redis (for Turbo Streams / async-cable)

```bash
fly redis create --name sense-collective-redis --region iad   # sets/echoes REDIS_URL
fly secrets set REDIS_URL="<the redis:// url from the previous step>" --app sense-collective
```

## 4. Secrets

```bash
fly secrets set --app sense-collective \
  RAILS_MASTER_KEY="$(cat config/master.key)" \
  OPENROUTER_API_KEY="..." \
  OPENAI_API_KEY="..." \
  GEMINI_API_KEY="..." \
  EXA_API_KEY="..." \
  INFRANODUS_API_KEY="..."        # for the Negative Space Lens v2 / shared gap adapter
```

`DATABASE_URL` and `REDIS_URL` are set by the attach/create steps above.
Use `RAILS_MASTER_KEY` *or* `SECRET_KEY_BASE` — not both.

## 5. Deploy

```bash
fly deploy --app sense-collective
```

`release_command = "bin/rails db:prepare"` runs migrations; `bin/docker-entrypoint`
re-runs `db:prepare` as a safety net on boot.

## 6. Verify

```bash
fly open --app sense-collective                 # home
fly open --app sense-collective /negative-space # Experiment A
fly logs --app sense-collective
```

Health check is wired to `/up` in `fly.toml`.

## Notes

- **Memory:** 1 GB to start. crawl4ai (headless browser) during ingestion is the
  memory hog — bump `[[vm]] memory` to `2gb` if you see OOM kills in `fly logs`.
- **Single process:** Falcon is fiber-based and async-job runs in-process, so one
  machine serves web + background jobs + cable. No separate worker process.
- **Custom domain:** `fly certs add lens.sensecollective.xyz` (or your domain), then
  point DNS as instructed.
