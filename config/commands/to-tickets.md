---
description: Break a plan or spec into tracer-bullet tickets with explicit blocking edges and publish them to the issue tracker in dependency order
---

You are executing the `to-tickets` command.

Break a plan or spec into **tracer-bullet tickets** — small, vertically-complete units of work with declared blocking edges — and publish them to this repo's issue tracker in dependency order.

Arguments: $ARGUMENTS

## Source of the plan

`$ARGUMENTS` names the source of the plan to ticket. Support:

- **A spec issue number** (e.g. `42`) — fetch it with `glab issue view <n> --comments`.
- **A file path** (e.g. `docs/specs/checkout.md`) — read it.
- **Nothing** — use the current plan/spec in the conversation.

## Before you start

- All tracker operations go through `glab` — follow the `glab` skill for command syntax and gotchas.
- Read `CONTEXT.md` (if it exists) and any ADRs in `docs/adr/` that touch this area. Use the glossary's vocabulary in ticket titles and descriptions.

## Break into tickets

Each ticket is a **tracer bullet**: small, vertically complete, shippable on its own, with a single named capability. Define:

- **Title** — one line naming the capability.
- **Description** — what the ticket delivers, what "done" means, and any acceptance detail from the spec. Quote the spec where relevant.
- **Blocking edges** — any ticket that cannot start until another ticket lands. These are hard dependencies, not ordering preferences.

Aim for the smallest set of tickets that delivers the spec vertically. Split only where a dependency actually exists; don't fragment one capability into horizontal slices.

## Show the plan

Present the full draft before creating anything:

```
Ticket 1  <title>
Ticket 2  <title>
  1 blocks 2    (2 cannot start until 1)
...
```

Confirm the ticket list and every blocking edge with the user. On their go-ahead, publish.

## Publish, in dependency order

1. Create the tickets in **dependency order**: a ticket is created only after every ticket it depends on has been created, so its blocker numbers already exist. Create each with:

   ```bash
   glab issue create --title "<title>" --description "<description>" --label ready-for-agent
   ```

   Record the number the tracker returns for each ticket.

2. After all tickets exist, express each blocking edge on the tracker:

   ```bash
   glab issue link --link-type blocks <issue> <blocking-issue>
   ```

   If the installed glab has no `glab issue link` subcommand, fall back to a `Blocked by: #<n>, #<n>` line at the top of the blocked ticket's description.

## Done

Report the full dependency graph by number (e.g. `#1 → #2 → #3`, with `#1 blocks #2`), each ticket's `ready-for-agent` label status, and any fallback used.

## Constraints

- Never merge tickets into horizontal slices; each must be a vertical tracer bullet.
- Never create, edit, or commit any file. `to-tickets` only publishes to the tracker.