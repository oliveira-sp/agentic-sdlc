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
- `grilling` — stress-test a plan or decision, one question at a time
- `chezmoi` — dotfiles management via the chezmoi CLI

### Command-driven

Workflows are encoded as reusable slash commands: tools you invoke when useful,
not stages you must pass through. They stay consistent, auditable, and per-repo.

### Minimal, read-only agents

Most work happens in the `build`, `plan`, and `explore` agents. The shipped
`build` override makes the implementation agent work like a human developer:
TDD-preferred, organized in logical units, with one small commit per unit
instead of one big commit at the end. A small number of purpose-built
subagents cover work that is risky-by-adjacency (scans of git, `$HOME`, or the
issue tracker), and they are read-only.

### Human-controlled

Commits, pushes, and merges remain under explicit developer approval. This is
enforced in the machine-local `opencode.jsonc` (managed by chezmoi) — destructive
git operations are denied or gated — not left to convention.

## What's here

Installable content lives in the `config/` payload folder, which maps 1:1 onto
the global opencode config directory (`~/.config/opencode`).

| Piece | Contents |
|---|---|
| **Skills** | `config/skills/` — `commit`, `chezmoi`, `code-review`, `glab`, `grilling`, `handoff`, `tdd` |
| **Commands** | `config/commands/` — `commit`, `project-discover`, `to-spec`, `to-tickets`, `chezmoi/add`, `chezmoi/status` |
| **Agents** | `config/agents/` — `build` (override: human-style implementation — TDD-preferred, one commit per logical unit), `gitlab-context` (read-only subagent that fetches GitLab context via `glab`) |
| **Bin** | `config/bin/` — helper scripts (`gcommit`) |

Repo documentation (not installed) lives at the top-level `docs/`:
architecture notes (`docs/architecture/`).

Machine-specific opencode configuration (`opencode.jsonc` — model selection,
permission rules, MCP servers) is **not** part of this repo; it is managed per
machine via chezmoi so work and personal setups can differ.

## Install / deploy

The `Makefile` syncs the payload into the global opencode config directory:

```sh
make install     # apply the sync
make dry-run     # show what would change, without touching anything
make status      # list payload files that differ or are not installed
make diff        # show line-by-line differences for payload files
```

This runs `rsync -a config/ "$(CONFIG_DIR)/"`, where `CONFIG_DIR`
defaults to `$XDG_CONFIG_HOME/opencode` (falling back to `~/.config/opencode`).
The sync is additive: it copies and overwrites payload files but never
deletes, so machine-local files that live alongside the installed content
(`opencode.jsonc`, `cli.json`, `service.json`, `node_modules/`,
`package.json`, `package-lock.json`, `gcommit.env`) are left untouched.
`opencode.jsonc` belongs to chezmoi. Files removed from `config/` remain in
the installed directory until deleted manually.

`status` and `diff` are read-only viewers that compare files in the repository
payload against their installed counterparts. `diff` pages interactive output
through `less`, preserving colors and quitting automatically when it fits on
screen. Destination-only, machine-local files are intentionally not reported;
both commands exit successfully when differences are found.

Output follows Git conventions: `status` groups `new file:` and `modified:`
entries (or reports that there is nothing to install), and `diff` shows patches
with `diff --git` headers and `a/` / `b/` paths. The installed files are the
baseline (`a/`); repository payload files are the proposed result (`b/`), so
added lines show what `make install` would apply.

## Shaped workflows

The commands compose into a few well-worn chains:

- **Ideation to tickets** — `to-spec` publishes a spec as a `ready-for-agent`
  issue; `to-tickets` breaks it into blocking tracer-bullet tickets in
  dependency order.
- **Dotfiles** — `chezmoi/status` (read-only overview of edited, unmanaged,
  and git-pending files) → `chezmoi/add` (capture the selected files) →
  `commit`.
- **Review** — the `code-review` skill reviews a fixed point along Standards
  and Spec axes with parallel subagents.

GitLab-backed commands and skills talk to the tracker directly through
`glab`, following the `glab` skill.

## Status

Early development. The skills, commands, and agents above are implemented and
used daily; the framework around them is intentionally light.

## Roadmap

- Multi-context domain docs (beyond single-context)
- Optional role prompts (product, planner) as thin command wrappers rather than
  a required agent roster

## License

Apache License 2.0
