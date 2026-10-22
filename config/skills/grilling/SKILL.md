---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea, one question at a time. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrase such as "grill me".
compatibility: opencode
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree **one question at a time**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Each turn, ask exactly one frontier question — the one that unblocks the most downstream decisions — with your recommended answer. Then stop and wait for the user's reply before asking anything else.

Format each question like so:

```
**Q<n>** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

<your recommended answer>
```

Number questions consecutively across the whole session, not per round.

Each answer reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next single question. A question whose answer depends on another question still open belongs to a _later_ turn, not this one.

Finding _facts_ is your job, never the user's. When the next question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: while the sub-agent runs, ask the next-best frontier question instead; only wait when the blocked one is the only question left. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
