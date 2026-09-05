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
enforced in the machine-local `opencode.jsonc` (managed by chezmoi) — destructive
git operations are denied or gated — not left to convention.

## What's here

Installable content lives in the `config/` payload folder, which maps 1:1 onto
the global opencode config directory (`~/.config/opencode`).

| Piece | Contents |
|---|---|
| **Skills** | `config/skills/` — `chezmoi`, `code-review`, `grill-me`, `grilling`, `handoff`, `tdd` |
| **Commands** | `config/commands/` — `commit`, `commit-propose`, `project-discover`, `setup-engineering`, `to-spec`, `to-tickets`, `chezmoi/add`, `chezmoi/audit`, `chezmoi/stage` |
| **Agents** | `config/agents/` — `chezmoi-commit-prep`, `chezmoi-discover` (read-only subagents) |
| **Bin** | `config/bin/` — helper scripts (e.g. `gcommit`) |
| **Docs** | `config/docs/` — per-repo issue-tracker and domain-doc guidance (`docs/agents/`), architecture notes |

Machine-specific opencode configuration (`opencode.jsonc` — model selection,
permission rules, MCP servers) is **not** part of this repo; it is managed per
machine via chezmoi so work and personal setups can differ.

## Install / deploy

The `Makefile` syncs the payload into the global opencode config directory:

```sh
make install
```

This runs a single `rsync -a --delete --delete-excluded config/ "$(CONFIG_DIR)/"`,
where `CONFIG_DIR` defaults to `$XDG_CONFIG_HOME/opencode` (falling back to
`~/.config/opencode`). Local-only files that live alongside the installed
content (`cli.json`, `service.json`, `node_modules/`, `package.json`,
`package-lock.json`) are preserved. `opencode.jsonc` is intentionally not
touched — it belongs to chezmoi.

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
`config/docs/agents/issue-tracker.md` and `config/docs/agents/domain.md` that
the commands and skills read.

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