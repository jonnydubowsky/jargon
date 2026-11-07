---
title: "Your July 4 Weekend Guide — Find Your Bearings, Get It Running, Ship the Posts"
date: 2026-07-03
audience: Jonny
---

# Start here

This is your map for the weekend. Three goals, in priority order:

1. **Find your bearings** (10 min read) — so you can explain this to the team cold.
2. **Ship the blog posts** (fast, high value) — the July-4 LinkedIn set.
3. **Get it running live** (stretch) — deploy the Lens to a public URL.

You don't have to do all three. If you only do #1 and #2, the weekend is a win.

---

# Part 0 — 60-second re-orientation

**Where things stand today:**

- The **Negative Space Lens** is built and running **locally right now** at `http://localhost:3000/negative-space`. It reads your research library, names the blind spots, and — as of this session — **labels each with an honest confidence band** ("72% sure"). That's the "70% sure artifact," live.
- Five blog posts are drafted in `docs/blog/`. Two are new and timed for this weekend (the confidence theme).
- The code is on a branch (`experiment/negative-space-lens`), **not yet committed**. Nothing is deployed publicly yet.
- The one-page mission brief is in your Google Drive.

**The one sentence:** We're building the open, honest layer under ShurIQ — a knowledge tool that tells you *what it's missing* and *how sure it is* — and this weekend we show it working.

---

# Part 1 — The story you can tell (team + LinkedIn)

## The through-line

Most AI states everything with the same flat, false confidence. That's the real trust problem — not that the machine is wrong sometimes, but that it never tells you *when*. **The fix is to qualify confidence: attach a calibrated certainty to every information object.** "This insight is 85% supported. This one is a 40% hunch." That single move — raising the integrity of information objects — is what makes a tool trustworthy.

This is exactly what you argued on the panel. You can't repeat the client specifics publicly, but you can **show the method working in a neutral domain** (your own research library), which backs up every supporting insight without naming anyone.

## What confidence rests on (the substance)

- **Sources** — how many independent pieces of the library circle a claim.
- **Measured vs. inferred** — is a gap actually visible in the knowledge graph's structure, or only proposed by a model? (InfraNodus grounding.)
- **Model agreement** — run the same question through Gemini, Claude, GPT. Blind spots that stay put across all of them are solid; ones that flicker are soft ground. **Disagreement is a confidence signal.**

## The 5-bullet version for the team

- ShurIQ is the product; **JargonDKR (Sense Collective)** is the open engine underneath it.
- Its signature move is **Negative Space** — finding what a body of knowledge *isn't* saying.
- We just added **calibrated confidence** to every finding — the "70% sure artifact."
- It's a **glass box**: the prompt is visible, and you can re-run on different models and watch certainty change.
- This weekend we publish the *method* (not any client) so the panel's ideas have public, credible backup.

---

# Part 2 — What's real vs. planned (so you don't oversell)

**Real and working:**
- Negative Space Lens with confidence bands (local).
- Exposed prompt + model selector.
- InfraNodus gap adapter (code done; activates when a key is set).
- 5 blog drafts.

**Prepped, needs your hands:**
- Public deploy (Fly.io config written; needs your login + secrets).

**Planned, not built:**
- Aethelgard convergence on the shared adapter.
- Experiment C (Glass Box Report), Experiment B (Studio = Workspace).

---

# Part 3 — Get it running (sequenced, copy-paste)

> Tip: to run a command *in this chat* so I can see the output and help you troubleshoot, type `!` then the command. Great for the interactive login steps below.

## Step 1 — See it locally (already running)

The server is up. Open **http://localhost:3000/negative-space**, click **Find the blind spots**, and try switching the model dropdown and re-running. If the server isn't up:

```bash
bin/dev          # starts web + tailwind on port 3000
```

Screenshot this page for the blog posts (the confidence badges are the money shot).

## Step 2 — Save the work (commit)

You're on a feature branch. To commit everything:

```bash
git add -A && git commit -m "Negative Space Lens: confidence bands + InfraNodus adapter"
```

(Or just tell me "commit it" and I'll do it.)

## Step 3 — Deploy live (the stretch goal)

Full runbook is in `docs/DEPLOY_FLY.md`. The short version, run each with `!` so I can help:

```bash
brew install flyctl          # once
fly auth login               # interactive — opens browser
fly apps create sense-collective
fly mpg create --name sense-collective-db --region iad
fly mpg attach sense-collective-db --app sense-collective
fly redis create --name sense-collective-redis --region iad
fly secrets set --app sense-collective \
  RAILS_MASTER_KEY="$(cat config/master.key)" \
  OPENROUTER_API_KEY="..." EXA_API_KEY="..."
fly deploy --app sense-collective
fly open --app sense-collective /negative-space
```

If anything errors, paste it here and I'll fix it. Budget ~30–45 min; don't start this if you're not in the mood — the posts matter more.

## Step 4 — Turn on graph-grounded confidence (optional)

Get a token at `infranodus.com/api-access`, then:

```bash
echo 'INFRANODUS_API_KEY=your-token' >> .env
# restart the server
```

Now the Lens grounds its blind spots in the actual graph structure, and the glass-box panel says "grounded by InfraNodus graph analysis" instead of "model only." Higher-integrity confidence — exactly the point of the posts.

---

# Part 4 — The July 4 blog plan

You have **five** posts. For the weekend, lead with the two new confidence ones — they're timely and they back the panel.

**Publish this weekend (the timely pair):**
1. **The 70% Sure Artifact** — the principle: trustworthy AI tells you how sure it is. (`docs/blog/04-…`)
2. **Watching the Machine Change Its Mind** — disagreement as a confidence signal; the live model-switch demo. (`docs/blog/05-…`)

**Hold as the foundation series (publish over following days):**
3. The Glass Box · 4. Negative Space · 5. Studios Are Just Workspaces.

**Why this order:** the two confidence posts stand on their own, feel *in-progress and alive* (right for a holiday scroll), and never mention the client — they demonstrate the method on neutral ground. The board members checking your LinkedIn see the substance behind what you said, presented as your own R&D.

**Suggested LinkedIn intro blurb (adapt):**
> Holiday-weekend build note. Been thinking about why AI feels untrustworthy — and it's not that it's wrong sometimes, it's that it never tells you *when*. So we taught our knowledge tool to say how sure it is. Here's the idea, and a look at it working. 🇺🇸

**Before posting:** read the two drafts (I'll send them), tweak the voice to yours, and drop in a screenshot from Step 1.

---

# Part 5 — Weekend checklist

- [ ] Read Part 1 (bearings) — you can now explain it cold.
- [ ] Open the local Lens, click around, screenshot the confidence badges.
- [ ] Read blog drafts 04 and 05; edit to your voice.
- [ ] (Optional) `commit it`.
- [ ] Publish post 04, then 05 (space them a day apart).
- [ ] (Stretch) Deploy to Fly.io; add the live link to the posts.
- [ ] (Optional) Add the InfraNodus key for graph-grounded confidence.

---

# Part 6 — After the weekend

- Converge **Aethelgard** on the shared InfraNodus adapter (add a `type: :discovery` mode to the Python bridge, or extract a `totem-infranodus` gem).
- Build **Experiment C (Glass Box Report)** — every report claim shows its source *and* its confidence.
- Build **Experiment B (Studio = Workspace)** — the `Workspace`/`PromptRegistry` layer; the Lens becomes the first named Studio.
- **Anchor deadline: July 4 — Totem Framework v0.1 feature-complete.**
