---
description: Synthesize the current conversation into a structured spec and publish it to the issue tracker as a ready-for-agent ticket
---

You are executing the `to-spec` command.

Turn the current conversation into a structured spec and publish it to this repo's issue tracker — without re-interviewing the user. The published spec is what `to-tickets` later breaks into tickets and `code-review`'s Spec axis checks against.

Arguments: $ARGUMENTS

## Before you start

- Read `docs/agents/issue-tracker.md` to learn the exact commands for this repo's tracker. Use them for every tracker operation; do not hardcode tracker calls.
- If `docs/agents/issue-tracker.md` is missing, tell the user to run the `setup-engineering` command first, then stop.
- Read `CONTEXT.md` (if it exists) and any ADRs in `docs/adr/` that touch this area. Use the glossary's vocabulary when naming domain concepts; don't invent synonyms.

## Synthesize the spec

Do not interview. Base the spec on the conversation, `$ARGUMENTS`, and any existing spec/notes it references. Follow the upstream `to-spec` structure:

1. **Problem statement** — what the user is trying to change and why.
2. **Solution** — the agreed approach in plain terms.
3. **User stories** — one per capability, `As a …, I want …, so that …`.
4. **Implementation decisions** — concrete choices made, with the rationale.
5. **Testing decisions** — what makes a good test here and what is under test.
6. **Out of scope** — explicitly deferred work, so tickets don't drift into it.
7. **Further notes** — glossary of shared language for this project, open risks, and a note that this spec was published by `to-spec`.

Keep it concise. Only include what the conversation actually established; where a decision is missing, mark it `TODO` rather than inventing it.

## Publish

Show the user the full spec draft. On their go-ahead, publish it to the tracker as a single issue ready for the agent to pick up:

```bash
glab issue create --title "<concise spec title>" --description "<spec body>" --label ready-for-agent
```

Use a heredoc for the multi-line description. Record the issue number that the tracker returns.

## Done

Report the issue number and URL. `to-tickets` can now break this spec into tickets; `code-review` will look it up when a commit references its number.

## Constraints

- Never interview the user during synthesis; the conversation is the source.
- Never create, edit, or commit any file. `to-spec` only publishes to the tracker.
- If the repo's tracker is not configured (`docs/agents/issue-tracker.md` missing), stop and point the user at `setup-engineering`.