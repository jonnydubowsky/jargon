---
title: "Why We Build This in Ruby"
subtitle: "An expressive, transparent language for an expressive, transparent system."
date: 2026-07-04
tags: [dkr, ruby, rails, architecture, async, concept-space, sense-collective]
status: draft
---

People are surprised we build AI infrastructure in Ruby. The reflex says Python, or a TypeScript orchestration layer, or whatever the framework of the month is. So this is the reasoned position — our concept space — for why the whole stack, from JargonDKR to our signal-ingestion app Aethelgard, is Ruby on Rails.

There's a nice meta-note before we start. Every claim below exists as a card in our own knowledge base. The system we built to reason about a body of work has, as one of its bodies of work, the argument for why it's built the way it is. The knowledge base makes its own case. That's the kind of thing we like.

## Start with the one fact that decides everything

An LLM call is I/O-bound and slow. You send a request, then you wait — hundreds of milliseconds to many seconds — while a model somewhere else does the thinking. Your process isn't computing anything during that wait. It's holding a connection open and doing nothing.

That single fact drives the architecture. If your app's core operation is "make a call and wait," the question that matters is: how cheaply can you wait, and how many waits can you run at once?

Ruby's answer, in its modern async form, is fibers. A fiber is a lightweight unit of concurrency — far cheaper to create than a thread (on the order of twenty times cheaper) and far lighter to hold open. Run the app under a fiber-based server — we use Falcon — and each in-flight LLM call parks on its own fiber while it waits. A hundred simultaneous chats become a hundred fibers, all waiting concurrently, sipping resources. No bloated database connection pool held hostage by slow requests. No thread-per-request tax. The concurrency model fits the workload exactly, instead of fighting it.

This isn't Ruby straining to keep up with async languages. Ruby's fibers hold their own against Python's async — and they do it without coloring every function `async`/`await` up and down the call stack. The async gem underneath (the same one powering Falcon and our `async-job` background processing) makes ordinary-looking Ruby run concurrently. Plain `Net::HTTP` becomes transparently async just by running under the reactor. The code reads synchronous and behaves concurrent. You don't rewrite your mental model to get the performance.

For the workload that defines an LLM application — many long, idle waits — this is close to the ideal shape.

## RubyLLM, not a framework port

The other worry is the ecosystem: surely the good LLM tooling is all in Python?

We use RubyLLM, and it's deliberately not a heavyweight framework port. It's a clean, idiomatic abstraction over models — not a re-creation of LangChain's chain-of-abstractions in Ruby clothing. Switching models is one line. Structured output comes through a small Ruby DSL (`ruby_llm-schema`): you declare the shape you want and the model is made to return it. Our Negative Space schema — the gaps, each with a title, a rationale, and a research question — is a dozen readable lines that look like the thing they describe.

That last point is the whole reason Ruby earns its place here, so it's worth dwelling on.

## Expressiveness is not a luxury

Ruby optimizes for developer happiness — that's Matz's stated design goal — and for a small team, developer happiness cashes out as velocity. But there's a deeper payoff than speed of typing: the domain model can read like the concept.

Our models compose small concerns — `Parentable`, `Embeddable`, `Broadcastable` — each a tidy DSL that says what it does in its name. An insight card is embeddable because it can be turned into a vector; broadcastable because it can push itself to the UI; parentable because it hangs in a hierarchy. The code reads like the idea. When the prompt, the pipeline, and the schema all read like plain intent, the system is legible — and legibility is not decoration. It's the same commitment we made in [The Glass Box](01-the-glass-box.md): expose the reasoning so a person can grab it and change it. An expressive language makes an exposed system readable instead of merely visible. You can't invite people to edit machinery they can't parse.

That through-line matters for the confidence work too. When a gap is labeled "72% sure" ([The 70% Sure Artifact](04-the-70-percent-artifact.md)) and you can re-run it across models to see which findings hold ([Watching the Machine Change Its Mind](05-watching-the-machine-change-its-mind.md)), the value is honesty you can inspect. A stack where the code hides its reasoning would undercut a product whose whole pitch is that it shows its reasoning. The language and the ethos have to match.

## Rails does the unglamorous work

Around RubyLLM sits Rails, and Rails earns its keep by making a small team punch above its weight.

Convention over configuration means we're not re-litigating project structure; we're building features. Hotwire and Turbo let us ship real-time UI — gaps streaming in as they're found, via Turbo Streams — without standing up and maintaining a separate JavaScript framework. And `pgvector`, reached through the `neighbor` gem, puts vector search inside the same Postgres database that holds everything else. One source of truth. No separate vector store to sync, secure, and reconcile. The embeddings live next to the records they embed.

For a team our size, every one of these is a decision *not* to build and babysit a second system. That's the real Rails advantage: less stack to defend.

## The honest counterpoint

Now the part that keeps this from being a sales pitch: the Ruby LLM ecosystem is young. Python has more libraries, more examples, more people who've hit your bug before you. Pretending otherwise would be exactly the flat overconfidence we build tools to fight.

So we don't do Ruby-maximalism. The mature position is Ruby for the knowledge and application layer — where expressiveness, cost, iteration speed, and that async fit pay off — and Python or TypeScript sidecars wherever they're clearly better. Concretely: Aethelgard calls a small Python InfraNodus bridge to do the graph analysis, because that's where the specialized tooling lives. Right tool per layer, not one language forced across all of them. Ruby is the substrate and the connective tissue; a sidecar is a phone call to a specialist. MCP and RAG both fit this shape cleanly, and both are perfectly buildable in Ruby for the parts that should live in Ruby.

## The through-line

Strip it down and the argument is simple. The core operation is a long, idle wait, and fibers wait cheaply. The tooling is idiomatic instead of ported. The framework spares a small team a second and third system. And the language lets the code read like the concept — which is the same reason we expose our prompts and qualify our confidence in the first place.

An expressive, transparent language for an expressive, transparent system. The stack isn't a compromise we're defending. It's the argument, written in the medium it describes.
