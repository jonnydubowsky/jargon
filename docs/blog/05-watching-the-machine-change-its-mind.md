---
title: "Watching the Machine Change Its Mind"
subtitle: "Disagreement between models isn't noise. It's a confidence signal."
date: 2026-07-04
tags: [dkr, confidence, cross-model, calibration, negative-space, sense-collective]
status: draft
---

Second post of the weekend, same lawn chair. If you read [The 70% Sure Artifact](04-the-70-percent-artifact.md), you know the argument: an AI output should tell you how sure it is. This one's about my favorite way to *earn* that number, and it's genuinely fun to watch.

Here's the move. Take one question. Run it through several different AI models — Gemini, Claude, GPT, a couple of others — and look at what each one puts at the top. Sometimes they all say the same thing. Sometimes they say wildly different things. That difference, the disagreement itself, is information.

When independent models converge on the same answer, that's a strong signal the answer is solid. When they scatter, that's a signal the ground is soft and you should tread carefully. You didn't need a human to grade anything. You just asked several different minds the same question and watched whether they nodded together or shrugged in different directions.

## Stable vs. flickering

We build a tool called the Negative Space Lens. It finds the blind spots in a body of knowledge — the questions a collection isn't asking. (Full idea: [Negative Space](02-negative-space.md).) The prompt that does the finding is exposed on purpose, and here's the part I've been playing with all week: you can re-run the exact same analysis on a different model and watch what changes.

Two things happen, and the contrast is the whole point.

**Stable gaps.** Some blind spots show up no matter which model you run. Gemini flags it, Claude flags it, GPT flags it, DeepSeek flags it. Four independent readers, same hole. That gap is *stable*. You can trust it. It's not an artifact of one model's quirks — it's a real feature of the knowledge base, and it earns a high confidence band.

**Flickering gaps.** Other blind spots show up on one model and vanish on the next. Gemini is sure it matters; Claude never mentions it. That gap *flickers*. It might be real and only one model was sharp enough to catch it — or it might be one model's hallucinated pattern. Either way, you treat it with caution and a low band. The flicker is the warning light.

Watching a list re-sort itself as you swap models is oddly hypnotic. The stable gaps sit still like anchors. The flickering ones jump around the rankings. After a minute you stop reading the list and start reading the *motion* — and the motion tells you exactly which findings have their feet on solid ground.

## Why this is cheap and honest

The usual way to check whether an AI answer is any good is to have a human expert review it, or to build some elaborate scoring rig. Both are expensive and both are slow.

Cross-model agreement is neither. It's basically free — you already have access to several models — and it's honest in a way a single confident answer can never be, because no single model is grading its own homework. You're triangulating. The same trick sailors used with three landmarks and the same trick surveyors use with three fixed points: one reading can lie to you, three readings that agree are hard to fake.

This is one of the ingredients behind the confidence band from the other post. "How many independent sources agree" isn't only about how many documents point at a gap — it's also about how many *models* do. Convergence across models is one of the cleanest, cheapest calibration signals we've got, and it's live in the Lens right now.

## Come watch it flicker

It's a holiday, so I'll keep it short. This is in-progress, it's a little rough, and it's the kind of thing that's more fun to see move than to read about. Pick a body of knowledge you think you understand. Run the Lens on it with one model. Then run it again with another and watch which blind spots hold and which ones flicker out.

The ones that hold are where I'd send the next question. The ones that flicker are where the machine is, honestly, still making up its mind — and I'd rather it show me that than pretend otherwise.

Companion piece, for the principle under all of this: [The 70% Sure Artifact](04-the-70-percent-artifact.md). Now, back to the fireworks.
