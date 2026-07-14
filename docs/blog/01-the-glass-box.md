---
title: "The Glass Box: Why We Expose Our Prompts"
subtitle: "Most AI tools hide how they reason. We made it the first thing you can change."
date: 2026-06-23
tags: [dkr, transparency, engelbart, prompts, sense-collective]
status: draft
---

Open a typical AI product and you get an answer. You don't get the reasoning that produced it. You can't see the instructions the model followed, you can't change them, and when the answer is wrong you have no handle to grab. The machine is a black box. You feed it a question and trust the box.

JargonDKR — the Sense Collective Dynamic Knowledge Ecosystem — is built the other way around. Every prompt in the pipeline is visible and editable. Not in a config file an engineer maintains. In the interface, where you work. We call it the glass box.

## The five-function loop, and the prompts inside it

The system runs sources — articles, PDFs, YouTube transcripts — through five steps: Ingest, Summarize, Extract, Connect, Thread. Each step is driven by a prompt. The Summarize prompt decides what counts as the gist. The Extract prompt decides what becomes an insight card. The Connect prompt decides when two cards are related enough to link in the graph.

In most tools those decisions are buried. Here they're surfaces. Open the Connect prompt and you see the actual text the model receives, including the similarity threshold it uses to decide whether two insights belong to the same cluster. Lower the threshold and the graph links more loosely; raise it and the clusters tighten. Change it and watch the graph re-cluster in front of you. The behavior of the system is something you can reach into, not something you petition an engineer to adjust.

This is a small example. The point it demonstrates is large: the reasoning is data, and the data is yours.

## Why transparency is a trust mechanism

You can't trust what you can't inspect. When a black box tells you two documents contradict each other, you have to take it on faith. When a glass box tells you the same thing, you can open the prompt that made the judgment, read the criteria, and decide whether you agree with the criteria. Trust stops being a feeling about the vendor and becomes a property you can verify.

This matters more as the output gets more consequential. A summary you can eyeball. A knowledge graph that's quietly shaping which connections you see — and which you never see — needs to be auditable, because its errors are invisible by construction. A glass box makes the invisible legible. (The sharpest version of this is finding what the graph *isn't* connecting — the subject of [Negative Space](02-negative-space.md).)

## Why transparency is a teaching mechanism

There's a second payoff, and it's the one we care about most. When the prompts are visible, the system teaches you how it thinks. You read the Extract prompt and you learn what a good insight extraction looks like. You tweak it, run it, compare the results, and you've just learned something about your own material that no opaque tool could have taught you. The interface is a worked example you can edit.

This inverts the usual relationship with AI tools. Normally the tool gets better and you stay the same. Here, using the tool makes *you* better at the underlying task — better at framing questions, spotting weak connections, knowing what a strong summary requires. The tool is a tutor that happens to also do the work.

## Engelbart's three levels

Doug Engelbart had a framework for this. He divided work into levels. A-level work is doing the thing — writing the report, building the graph, answering the question. B-level work is improving how you do the thing — better tools, better process, faster iteration. C-level work is improving how you improve: getting better at getting better.

Most software stops at A. Some good software reaches B. Engelbart's whole argument was that the leverage lives at C, and almost nobody works there, because almost no system lets you.

Exposed prompts are a C-level move. When you can see and change how the machine reasons, your improvements compound. You don't just get a better answer (A). You get a better Connect prompt (B). And because the prompt is visible and shareable, you get better at the practice of designing prompts that find real connections (C) — and so does the next person who reads what you changed. The glass box turns private tweaks into shared, inspectable craft.

## The de-risking angle

There's a practical reason this isn't just philosophy. A system whose intelligence lives in one expert's head is fragile. When the expert leaves, the capability leaves. Most AI deployments have this problem in a subtle form: the prompts are written once, by one person, and then frozen into the product where no one can read them.

Exposed prompts are how you get the expertise out of the head and into the system, where it can be inspected, taught, versioned, and improved by people who weren't there when it was written. That's the foundation for treating the whole thing as an SDK — a substrate other people can build on without reverse-engineering your judgment. You can't build on what you can't see. The glass box is the precondition for everything reusable on top of it.

This is the same substrate that ShurIQ, our client-facing brand-intelligence instrument, runs on. ShurIQ's reports are "observations against a published rubric" — defensible precisely because the rubric is published and the reasoning is exposed. That defensibility starts here, with the decision to make the box transparent. The studios built on top of it are, structurally, just different views of the same glass box — which is the subject of [Studios Are Just Workspaces](03-studios-are-workspaces.md).

## Open the prompt

The test of all this is concrete and you can run it. Open the Connect prompt. Read how it decides two insights are related. Change the similarity threshold. Watch the graph re-cluster. You just did B-level work on a system that most tools would never have let you see.

That's the whole idea. Not "trust our AI." See how it reasons, and change it.
