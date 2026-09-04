# Agentic SDLC

A prompt-driven toolkit for weaving AI agents into the software development
lifecycle. Instead of a fixed pipeline of roles, it packages reusable skills
and slash commands on top of an agentic coding tool, with human approval
checkpoints enforced in configuration.

## Philosophy

### Skills-first

Behavior lives in composable skills, not a roster of specialized roles. Each
skill bundles instructions for one capability and the triggers that fire it:

- `code-review` — review changes along two axes (Standards + Spec)
- `tdd` — red-green-refactor and integration-test workflows
- `handoff` — compact a conversation into a handoff document
- `grilling` / `grill-me` — stress-test a plan or decision
- `chezmoi` — dotfiles management via the chezmoi CLI

### Command-driven

Workflows are encoded as reusable slash commands: tools you invoke when useful,
not stages you must pass through. They stay consistent, auditable, and per-repo.

### Minimal, read-only agents

Most work happens in the built-in `build`, `plan`, and `explore` agents. A
small number of purpose-built subagents cover work that is risky-by-adjacency
(scans of git and `$HOME`), and they are read-only.

### Human-controlled

Commits, pushes, and merges remain under explicit developer approval. This is
enforced in configuration — destructive git operations are denied or gated — not
left to convention.

## What's here

| Piece | Contents |
|---|---|
| **Skills** | `chezmoi`, `code-review`, `grill-me`, `grilling`, `handoff`, `tdd` |
| **Commands** | `commit`, `project-discover`, `setup-engineering`, `to-spec`, `to-tickets`, `chezmoi/add`, `chezmoi/audit`, `chezmoi/stage` |
| **Agents** | `chezmoi-commit-prep`, `chezmoi-discover` (read-only subagents) |
| **Config** | `opencode.jsonc` — permission rules gating destructive git ops, glab MCP |
| **Docs** | per-repo issue-tracker and domain-doc guidance (`docs/agents/`), architecture notes |

## Shaped workflows

The commands compose into a few well-worn chains:

- **Ideation to tickets** — `to-spec` publishes a spec as a `ready-for-agent`
  issue; `to-tickets` breaks it into blocking tracer-bullet tickets in
  dependency order.
- **Dotfiles** — `chezmoi/add` (discover + add) → `chezmoi/audit` (propose
  logical commit groups) → `chezmoi/stage N` (stage one group) → `commit`.
- **Review** — the `code-review` skill reviews a fixed point along Standards
  and Spec axes with parallel subagents.

Per-repo tracking setup is bootstrapped by `setup-engineering`, which writes
`docs/agents/issue-tracker.md` and `docs/agents/domain.md` that the commands
and skills read.

## Status

Early development. The skills, commands, and agents above are implemented and
used daily; the framework around them is intentionally light.

## Roadmap

- Multi-context domain docs (beyond single-context)
- Local markdown issue-tracker variant automation
- Optional role prompts (product, planner) as thin command wrappers rather than
  a required agent roster

## License

Apache License 2.0