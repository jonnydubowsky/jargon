---
title: "Studios Are Just Workspaces"
subtitle: "A Studio sounds like a separate product. Architecturally, it's one graph and a different lens."
date: 2026-06-23
tags: [dkr, architecture, studios, workspaces, shuriq, sense-collective]
status: draft
---

ShurIQ has a Simulation Studio, a Writing Studio, and a Pitch Deck Studio. The word "studio" makes them sound like three products — three engines, three codebases, three things to build and maintain. They're not. Under the surface there's one knowledge graph, and a Studio is a view of it through a swappable, exposed prompt configuration. We call that configuration a Workspace.

Once you see that, the whole architecture gets simpler, and the reason it scales becomes obvious.

## One substrate, many lenses

Start with what doesn't change: the graph. The same insight cards, the same connections, the same accumulated knowledge built by the five-function loop. Every Studio reads from it. None of them owns a private copy.

What changes between Studios is the lens — and a lens is three things:

**Prompt overrides.** Each Studio swaps in its own versions of the pipeline prompts. The Simulation Studio's Extract prompt looks for claims it can stress-test against scenarios. The Writing Studio's looks for material that supports an argument. Same graph, different question asked of it.

**A rubric.** Each Studio scores and ranks against its own published criteria. The Simulation Studio judges robustness under pressure. An Editorial Brief judges whether a claim is sourced and sayable. The rubric is what turns a pile of insights into a ranked, defensible output.

**A frame.** The shape of the deliverable — a simulation, a draft, a one-page brief. This is the thinnest layer, mostly presentation.

Swap those three and the Simulation Studio becomes the Writing Studio. The engine underneath never moved.

## Why this scales

The naive way to build three studios is to build three systems. Each new client workflow is a new engineering project, and your maintenance cost grows linearly with your product surface. Every studio is a thing that can break independently and has to be fixed independently.

The Workspace model breaks that link. You don't rebuild the engine per Studio; you reconfigure the lens. A new Studio is a new prompt set, a new rubric, and a new frame — configuration, not construction. The cost of the next Studio is the cost of writing a good rubric and a few prompt overrides, not the cost of a new pipeline. That's the difference between a product line that gets heavier with each addition and one that gets cheaper, because every Studio shares and reinforces the same substrate.

It also means improvements flow in one direction and benefit everything. Make the Connect step smarter and every Studio that reads the graph gets smarter at once. In a three-engine world that same improvement is three separate ports.

## This only works because the prompts are exposed

The Workspace model depends on something specific: the prompts have to be visible and overridable. A Studio is defined by how it overrides the base configuration, and you can't override what's hidden. If the prompts were buried in the engine, a Studio would have to be a fork — a separate copy with separate edits — and you'd be back to maintaining three systems pretending to be one.

Because JargonDKR exposes every prompt — the glass box from the [first post](01-the-glass-box.md) — a Workspace is just a named set of overrides on top of a shared base. The transparency that makes the system trustworthy and teachable is the same property that makes it composable. One decision pays off three ways.

The Negative Space Lens is itself an example: a Studio in everything but name, a particular set of prompt overrides and a rubric — "find the sparse bridges, rank the missing questions" — applied to the same graph everything else reads from. (That's [the second post](02-negative-space.md).) We didn't build a Negative Space engine. We configured a lens.

## The de-risking payoff

This is also where the architecture and the business case meet. A system where each workflow is a bespoke build concentrates risk: the knowledge of how each one works lives with whoever built it, and the cost of change is high enough that nobody changes anything. It calcifies.

A system where workflows are Workspaces — configuration over a shared, transparent substrate — spreads the risk out. The substrate is one well-understood thing. The Studios are readable configurations on top of it, each one an inspectable set of overrides and a published rubric. A new person can read a Workspace and understand it without reverse-engineering a private codebase. You can hand the whole thing to someone as an SDK: here's the engine, here's how Studios are defined, build your own. That's only possible because a Studio was never a separate product. It was always a lens.

## The reframe

So drop the word "studio" for a second and look at what's actually there: one accumulating knowledge graph, and a set of named, exposed configurations for interrogating it. Simulation, Writing, Pitch Deck, Negative Space, Editorial Brief — each is a Workspace. The product catalog is a list of lenses, not a list of engines.

That's the whole trick, and it's why the architecture holds as the catalog grows. You're not building studios. You're building one substrate worth viewing many ways, and then writing down the ways.
