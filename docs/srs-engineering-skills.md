# SRS: Porting mattpocock/skills to opencode

**Source SDR:** `docs/sdr-engineering-skills.md` (repo docs/)
**Status:** Draft requirements spec — derived from the agreed SDR, not yet implemented.
**Date:** 2026-08-28
**Author:** synthesized from SDR + upstream `to-spec` template

This spec follows the upstream `to-spec` template. No interview was conducted; it
synthesizes the already-agreed SDR. Domain vocabulary from the SDR is used throughout.

## Problem Statement

The engineer wants to adopt Matt Pocock's real-engineering skills (TDD loop, two-axis code
review, a tracker-wired plan→spec→ticket flow) inside their local **opencode** environment, but
the upstream skills assume Claude Code / Codex primitives (`/slash` commands, a
`disable-model-invocation` flag, and GitHub/Linear/local trackers). As shipped they do not load
or behave correctly under opencode, and they carry `matt-pocock` branding the engineer does not
want. The engineer needs a minimal, adapted subset that actually works here and is wired to the
GitLab tracker they already have (`glab` MCP).

## Solution

Port a minimal, tracker-wired subset of the upstream engineering skills into opencode's native
primitives:

- **Disciplines as skills** (description-driven, both user- and model-invokable): `tdd`,
  `code-review`.
- **User-triggered flows as commands** (`/name`): `setup-engineering`, `to-spec`, `to-tickets`.
- All directories migrated to the **plural** canonical layout (`skills/`, `commands/`,
  `agents/`), including the existing chezmoi files.
- The tracker abstraction targets **GitLab via `glab`**, with per-project config in
  `docs/agents/issue-tracker.md` + `AGENTS.md`.

This gives the engineer a working align → spec → tickets → implement loop (the implement step
deferred) without the upstream branding or its unsupported primitives.

## User Stories

1. As an engineer, I want to run `/tdd` so that the agent builds features/fixes bugs one
   vertical slice at a time with a red-green-refactor loop.
2. As an engineer, I want the model to auto-invoke `tdd` while coding so that tests drive the
   implementation without me prompting each time.
3. As an engineer, I want to run `/code-review` so that the diff since a fixed point is reviewed
   on two axes (Standards and Spec) before I commit.
4. As an engineer, I want the model to reach for `code-review` by description so that reviews
   happen without an explicit command.
5. As an engineer, I want `code-review` to run Standards and Spec as parallel sub-agents so that
   neither axis pollutes the other and the review is fast.
6. As an engineer, I want to run `/setup-engineering` so that the project is configured for the
   engineering skills (tracker backend, triage labels, domain-doc layout) once per repo.
7. As an engineer, I want `setup-engineering` to default to **GitLab** so that it wires to the
   `glab` tracker I already use.
8. As an engineer, I want `setup-engineering` to write `docs/agents/issue-tracker.md` and edit
   `AGENTS.md` so that the tracker config is the single source of truth for the other flows.
9. As an engineer, I want to run `/to-spec` so that the current conversation becomes a structured
   spec published to GitLab without re-interviewing me.
10. As an engineer, I want `/to-spec` to create a GitLab issue labeled `ready-for-agent` so that
    the ticket is immediately actionable by the agent.
11. As an engineer, I want to run `/to-tickets` so that a plan/spec becomes tracer-bullet tickets
    with explicit blocking edges.
12. As an engineer, I want `/to-tickets` to publish tickets to GitLab in dependency order and
    express blocking via `glab issue link --link-type blocks` so that the work order is explicit.
13. As an engineer, I want `/to-tickets` to apply the `ready-for-agent` label so tickets are
    ready for the agent to pick up.
14. As the model, I want `tdd` and `code-review` advertised by description so that I can invoke
    them when the task fits, without a user command.
15. As an engineer, I want the existing chezmoi skill/commands/agents to keep working after the
    directory migration so that nothing regresses.
16. As an engineer, I want skills to read `docs/agents/issue-tracker.md` for exact `glab`
    commands so that `to-spec`/`to-tickets` stay tracker-correct without hardcoded calls.
17. As an engineer, I want the ported skills to drop `matt-pocock` branding so that my setup is
    my own.

## Implementation Decisions

- **Module layout (plural dirs):** `skills/<name>/SKILL.md`, `commands/<name>.md`,
  `agents/<name>.md`. Migrate existing `skill/`→`skills/`, `command/`→`commands/`,
  `agent/`→`agents/`, merging chezmoi's `add/audit/stage` under `commands/chezmoi/` and its
  agents under `agents/chezmoi/`.
- **Skill frontmatter:** `name`, `description` required; `metadata.opencode/autoinvoke` is the
  only invocation lever. `tdd` and `code-review` are left as normal skills (no `autoinvoke:"false"`)
  so they are both user- and model-invokable.
- **Command frontmatter:** opencode supports `description`, `agent`, `model`. Input is passed
  via `$ARGUMENTS` / `$1` (Anthropic `argument-hint` is ignored and must not be used).
- **tracker abstraction:** a single file `docs/agents/issue-tracker.md` (per project root) is the
  source of truth. `setup-engineering` seeds it from the upstream `issue-tracker-gitlab.md`
  template (the `glab` command set) and edits `AGENTS.md` (never creates `CLAUDE.md`).
- **API contracts (GitLab via `glab`):**
  - Create issue: `glab issue create --label ready-for-agent` (used by `to-spec` and `to-tickets`).
  - Blocking edge: `glab issue link --link-type blocks <issue> <blocking-issue>` (used by
    `to-tickets` for each declared blocking edge, published in dependency order).
- **code-review parallelism:** implemented by instructing the model to spawn parallel sub-agents
  via the built-in subagent tool using `general`/`explore` agents. No dedicated `agents/` files
  are created (keeps the port minimal).
- **Upstream quirk translations:**
  - `disable-model-invocation: true` (Anthropic) is dropped for `tdd`/`code-review` (we want both
    invocation modes); not applicable to commands.
  - `/slash-name` cross-references become "call the `<name>` skill" or the `/<name>` command.
  - `to-spec`/`to-tickets` are prompt-driven upstream (no hardcoded `gh` calls); only their
    example names and the blocking description are rewritten to mention `glab`.
- **tdd loop:** red-green-refactor, one vertical slice at a time; no test-first specifics beyond
  the loop contract.
- **code-review axes:** Standards (repo coding standards + Fowler smell baseline) and Spec
  (faithful implementation of the originating issue/spec), run as parallel sub-agents.

## Testing Decisions

- **What makes a good test here:** verify *external behavior* of the port — that skills/commands
  load in opencode and produce the right tracker side-effects — not internal prose. Avoid
  asserting on SKILL.md wording.
- **Modules under test:**
  - Directory migration: after rename, confirm `skills/chezmoi`, `commands/chezmoi/*`,
    `agents/chezmoi/*` still load (prior art: chezmoi already works under the singular layout).
  - `setup-engineering`: run in a scratch repo; assert `docs/agents/issue-tracker.md` exists and
    `AGENTS.md` gained the agent-skills block; tracker type recorded as `gitlab`.
  - `to-spec`: run on a conversation; assert a GitLab issue is created with label `ready-for-agent`
    (via `glab` or the GitLab MCP).
  - `to-tickets`: run on a plan; assert N GitLab issues created in dependency order, each with
    `ready-for-agent`, and blocking links present via `glab issue link --link-type blocks`.
  - `tdd`: in a small repo, assert the agent writes a failing test first, then makes it pass
    (red→green).
  - `code-review`: assert two parallel sub-agents are launched (Standards + Spec) and a combined
    review is returned.
- **Prior art:** the existing chezmoi skill/command/agent load path is the reference for "does it
  load under this opencode version."

## Out of Scope

- The deferred upstream skills: `triage`, `implement`, `wayfinder`, `grill-with-docs`, `ask-matt`,
  and the rest of Productivity (`teach`, `to-questionnaire`, `wait-what`, `writing-for-agents`).
- `triage-labels.md` generation (only produced if `triage` is later added).
- GitHub / Linear / local-file tracker backends (GitLab only).
- Any change to the upstream `tdd`/`code-review` methodology beyond opencode adaptation.
- Auto-commit or auto-merge behavior (out of scope per `opencode.jsonc` permission rules).

## Further Notes

- **Glossary (shared language for this project):**
  - *skill* — description-driven guidance the model can auto-invoke; also user-invokable.
  - *command* — user-triggered `/name` action (`commands/*.md`).
  - *agent / subagent* — child session spawned via the subagent tool.
  - *tracker* — the issue tracker (GitLab); configured in `docs/agents/issue-tracker.md`.
  - *ready-for-agent* — triage label marking a ticket actionable by the agent.
  - *tracer-bullet ticket* — a small, vertically-complete unit of work with declared blocking edges.
  - *blocking edge* — dependency where ticket B cannot start until ticket A lands; expressed in
    GitLab via `glab issue link --link-type blocks`.
- **Open risk:** the current opencode version loads *singular* dirs (proven by chezmoi). Plural is
  docs-canonical but version-dependent. After migration, verify `skills/`/`commands/`/`agents/`
  load; if not, fall back to singular.
- **Optional cleanup (not in this spec):** `handoff` skill uses Anthropic `argument-hint` (ignored
  by opencode) — could switch to `$ARGUMENTS`.
- This SRS is published as a GitLab issue labeled `ready-for-agent` when the engineer runs
  `/to-spec` on the SDR conversation.
