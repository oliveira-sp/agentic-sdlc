---
description: Configure this repo for the engineering skills: set up its issue tracker and domain doc layout. Run once before first use of the other engineering commands/skills.
---

You are executing the `setup-engineering` command.

Scaffold the per-repo configuration that the engineering skills assume:

- **Issue tracker**: where issues live — **GitLab** by default (via `glab`).
- **Domain docs**: where `CONTEXT.md` and ADRs live, and the consumer rules for reading them.

This is a prompt-driven command, not a deterministic script. Explore, present what you found, confirm with the user, then write.

Arguments: $ARGUMENTS

## Process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `git remote -v` and `.git/config`: is this a GitLab repo? Which one?
- `AGENTS.md` at the repo root: does it exist? Is there already an `## Agent skills` section?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/`: does this command's prior output already exist?
- `.scratch/`: a sign that a local-markdown issue tracker convention is already in use

### 2. Present findings and ask

Summarise what's present and what's missing. Then take the sections in order. One section, one answer, then the next.

Lead each section with the recommended answer so the user can accept it in a word.

**Section A: Issue tracker.**

> Explainer: The "issue tracker" is where issues live for this repo. Commands like `to-tickets` and `to-spec` read from and write to it. They need to know whether to call `glab issue create`, write a markdown file under `.scratch/`, or follow some other workflow you describe. Pick the place you actually track work for this repo.

Default posture: **GitLab**. If a `git remote` points at GitLab (`gitlab.com` or a self-hosted host), propose that. Otherwise (or if the user prefers), offer:

- **GitLab**: issues live in the repo's GitLab Issues (uses the [`glab`](https://gitlab.com/gitlab-org/cli) CLI) — recommended
- **Local markdown**: issues live as files under `.scratch/<feature>/` in this repo (good for solo projects or repos without a remote)
- **Other** (Jira, Linear, etc.): ask the user to describe the workflow in one paragraph; the command will record it as freeform prose

Record the choice in `docs/agents/issue-tracker.md`. The GitLab template carries a "PRs as a request surface" flag, defaulted **off**. Leave it off and don't raise it: a user who wants external MRs in the triage queue can flip the flag in the file later.

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to `AGENTS.md` (see step 4)
- The contents of `docs/agents/issue-tracker.md` and `docs/agents/domain.md`

Let them edit before writing.

### 4. Write

**Pick the file to edit:**

- If `AGENTS.md` exists, edit it.
- If it doesn't exist, ask the user before creating it.

Never create `CLAUDE.md`.

If an `## Agent skills` block already exists in `AGENTS.md`, update its contents in-place rather than appending a duplicate. Don't overwrite user edits to the surrounding sections.

The block:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked]. See `docs/agents/issue-tracker.md`.

### Domain docs

[one-line summary of layout: "single-context" or "multi-context"]. See `docs/agents/domain.md`.
```

Then write the docs files using the seed templates as a starting point:

- [docs/agents/templates/issue-tracker-gitlab.md](docs/agents/templates/issue-tracker-gitlab.md): GitLab issue tracker
- [docs/agents/templates/domain.md](docs/agents/templates/domain.md): domain doc consumer rules + layout

For "other" issue trackers, write `docs/agents/issue-tracker.md` from scratch using the user's description.

### 5. Done

Tell the user the setup is complete and which engineering commands will now read from these files. Mention they can edit `docs/agents/*.md` directly later; re-running this command is only necessary if they want to switch issue trackers or restart from scratch.

## Constraints

- Never create `CLAUDE.md`; only edit/create `AGENTS.md`.
- Write `docs/agents/issue-tracker.md` (GitLab seed) and `docs/agents/domain.md`.
- Never commit, push, or modify anything outside `AGENTS.md` and `docs/agents/`.
