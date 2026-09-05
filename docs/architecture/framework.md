# Agentic SDLC Framework Architecture

## Overview

The Agentic SDLC Framework integrates AI agents into the software development
lifecycle through a prompt-driven toolkit rather than a fixed pipeline of
roles. Capabilities are packaged as reusable skills and slash commands on top
of an agentic coding tool, and safety-critical actions stay under human
approval, enforced in configuration.

The framework rests on four ideas:

- **Skills** — composable units of behavior, each with instructions and the
  triggers that fire it.
- **Commands** — slash commands that encode a workflow as a prompt, so it stays
  consistent and reproducible across sessions.
- **Agents** — mostly the built-in `build`, `plan`, and `explore` agents, plus
  a small set of purpose-built read-only subagents for risky scans.
- **Human control** — approval checkpoints for commits, pushes, and merges,
  backed by permission rules rather than convention.

There is no workflow state machine and no required artifact pipeline. Workflows
emerge from chaining commands; artifacts are the byproducts of those commands,
not a contract between phases.

## Skills

A skill is a directory of instructions that opens one capability. It names
what it does and when to trigger it:

- `code-review` — reviews changes since a fixed point along two axes:
  *Standards* (repo coding standards) and *Spec* (the originating issue/spec).
  Runs both axes in parallel subagents and reports side by side.
- `tdd` — red-green-refactor, plus integration tests.
- `handoff` — compacts the current conversation into a handoff document.
- `grilling` / `grill-me` — stress-test a plan or decision with relentless
  questioning.
- `chezmoi` — the chezmoi CLI for dotfiles: path mapping, status semantics, add
  flags, and audit/stage/commit workflows.

Skills are the primitive; commands are how they get invoked in a workflow.

## Commands

A command encodes a workflow as a prompt with `$ARGUMENTS` for input. Commands
are tools to invoke when useful, not stages that must be passed through.

| Command | Purpose |
|---|---|
| `commit` | Generate, review, and create a Conventional Commit from staged changes |
| `project-discover` | Generate/refresh `docs/project-context.md` for a repository |
| `setup-engineering` | Bootstrap per-repo `docs/agents/` tracker and domain docs |
| `to-spec` | Synthesize the conversation into a spec and publish as a `ready-for-agent` issue |
| `to-tickets` | Break a plan/spec into blocking tracer-bullet tickets, published in dependency order |
| `chezmoi/add` | Discover unmanaged config and add the selected files |
| `chezmoi/audit` | Audit the source repo and propose logical commit groups |
| `chezmoi/stage N` | Stage exactly one logical group of changes with explicit pathspecs |

### Shaped workflows

- **Ideation to tickets** — `to-spec` → `to-tickets`. Both read
  `docs/agents/issue-tracker.md`; if it is missing they stop and point the user
  at `setup-engineering`.
- **Dotfiles** — `chezmoi/add` → `chezmoi/audit` → `chezmoi/stage N` →
  `commit`. The scan stages are delegated to read-only subagents
  (`chezmoi-discover`, `chezmoi-commit-prep`).
- **Review** — the `code-review` skill, run against a branch, PR, or tag.

## Agents

Most work uses the built-in `build`, `plan`, and `explore` agents. The only
custom agents are two read-only subagents in `agents/chezmoi/`:

- `chezmoi-commit-prep` — inspects git and deployment state, classifies files,
  and proposes logical commit groups. Edit and push are denied.
- `chezmoi-discover` — scans `$HOME` for unmanaged config and classifies it
  (candidate / noise / suspicious / already-versioned). Edit and push are
  denied; secret values are never printed.

Read-only subagents are the rule whenever the scope of a scan is broad or
close to sensitive data. Write work is left to the primary agent under user
confirmation.

## Human Control

The framework preserves human control over important decisions. In the
machine-local `opencode.jsonc` (managed per machine via chezmoi, not shipped
from this repo), permission rules gate the dangerous surface:

- `git push*`, `git reset --hard*`, `git restore*`, `git checkout --*`, and
  `git clean*` are **denied** — the agent cannot discard or push work.
- `git commit*` and `rm -rf*` are **ask** — require explicit per-action
  approval.
- The `commit` command itself always confirms before committing.

The framework may stage, propose commit messages, and prepare change sets, but
committing and pushing are human decisions.

## Per-repo configuration

The `config/` payload ships the machinery (installed via `make install` into
the global opencode config dir); each repository carries its own working
agreements, seeded by `setup-engineering`:

- `docs/agents/issue-tracker.md` — where issues live and the exact commands to
  read/write them (GitLab via `glab` by default, with fallbacks for local
  markdown trackers).
- `docs/agents/domain.md` — the domain-doc layout and consumer rules.

Commands and skills read these files at runtime, so they adapt to each repo's
tracker and conventions instead of hardcoding them.

## Architectural Decisions

1. **Capabilities over roles.** Skills and commands, not a roster of
   specialized agents. Keeps the toolkit small and avoids agent
   interchangeability machinery.
2. **Prompts, not state machines.** Workflows are command chains; there is no
   workflow state or execution directory to persist.
3. **Safety in configuration.** Approval is enforced by `opencode.jsonc`
   permission rules (machine-local, chezmoi-managed) and read-only subagents,
   not by convention.
4. **Per-repo knowledge delegated.** Tracker and domain conventions live in
   `docs/agents/*.md`, generated by `setup-engineering`.
5. **Human-in-the-loop by default.** No commits, pushes, or merges happen
   without explicit approval.