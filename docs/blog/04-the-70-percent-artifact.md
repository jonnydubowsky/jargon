---
title: "The 70% Sure Artifact"
subtitle: "The most trustworthy AI output is the one that tells you how sure it is."
date: 2026-07-04
tags: [dkr, confidence, calibration, negative-space, trust, sense-collective]
status: draft
---

It's a holiday weekend, the grill is going, and I've been staring at a small feature that I think matters more than its size suggests. So here's the thing I'm excited about, in-progress, come look.

Most AI writes every sentence with the same voice. The fact it's certain of and the guess it pulled from thin air arrive in the same confident font, the same clean paragraph, the same tone of a colleague who has never once been wrong. That flatness is the actual trust problem. Not that the machine is sometimes wrong — everything is sometimes wrong — but that it never tells you *which* parts to lean on and which to poke at.

A good scientist doesn't talk like that. A good scientist qualifies. "This is well established." "This is suggestive but the sample is small." "This is a hunch I'd bet a beer on, not my house." The qualifier isn't weakness. It's the most useful part of the sentence, because it tells you how hard you're allowed to push before the claim breaks.

I want AI outputs to carry that same qualifier. Not as a disclaimer buried at the bottom, but as a property of the object itself.

## What a confidence band rests on

"Trust me" is not a number. So the first question is: what could a confidence score actually be made of? A few things, all of them concrete:

**How many independent sources support it.** One document saying something is a lead. Five unrelated documents converging on it is a finding. The count is a signal, and it's countable.

**Whether it's measured or inferred.** Some claims come from a thing you can point at — a structural gap you can measure in a graph, a number you can recompute. Others are the model connecting dots that might not connect. Measured and inferred deserve different bands, and the system knows which is which.

**Whether different models agree.** Run the same question through several models. If they independently land in the same place, that agreement is evidence. If they scatter, the ground is soft. (That one's the subject of the companion post, [Watching the Machine Change Its Mind](05-watching-the-machine-change-its-mind.md).)

None of these is a vibe. Each is something you can compute and show your work on. Stack them and you get an honest band — not a false decimal pretending to precision, but a real "high / medium / low, and here's why."

## Where this is live

We build a tool called the Negative Space Lens. Its job is to find the blind spots in a body of knowledge — the important questions a collection *isn't* asking, the subjects a thoughtful expert would expect to find and can't. (The longer version of that idea is in [Negative Space](02-negative-space.md).)

Finding a gap is one thing. Being honest about the gap is another. A blind spot the machine is genuinely sure about and one it's half-guessing at should not look identical on the page — that's exactly the flat-certainty trap.

So the Lens now labels each gap with a confidence band. "72% sure this is a real gap, not just thin coverage." That number isn't decoration. It rests on how many parts of the knowledge base point at the same hole, whether the gap was measured in the graph's structure or inferred by a model reading the material, and whether different models flag it too. A gap that lights up every way we can check it earns a high band. A gap only one model mentions, once, gets a low one — surfaced, but flagged as soft.

The payoff is what you *do* with it. A high-confidence gap is worth spending real research time to fill. A low-confidence one is worth a glance and a shrug. The band tells you where to spend attention, which is the scarcest thing any of us has.

## The principle under it

This is the whole argument in one line: **raise the integrity of information objects by qualifying confidence.**

An artifact that admits when it isn't sure is more trustworthy than one that's confidently wrong — not despite the admission, because of it. The honesty *is* the integrity. When a tool tells you "I'm 40% on this," and you check, and it turns out to be a 40%-kind-of-thing, you start to trust the 85%s too. Calibration compounds. Flat certainty doesn't; the first time it's confidently wrong, you can't trust any of it.

I'd rather ship a tool that says "I'm not sure" and means it. That's the version I'd want reading my own research back to me.

Okay — the fireworks are starting. If this thread interests you, the companion post is [Watching the Machine Change Its Mind](05-watching-the-machine-change-its-mind.md), which is where the cross-model part gets fun to watch.
