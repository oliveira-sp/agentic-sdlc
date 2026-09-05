# opencode config payload

This directory is installed into the global opencode config directory
(`~/.config/opencode/`, or `$XDG_CONFIG_HOME/opencode/`) by the `Makefile`
at the repository root (`make install`). It maps 1:1 onto that directory.

## What's installed

- **skills/** — behavior skills loaded as opencode skills
- **commands/** — custom slash commands
- **agents/** — custom read-only subagents, plus `templates/` seed docs read by
  the `setup-engineering` command
- **bin/** — helper scripts, e.g. `gcommit`

## Machine-local config

`opencode.jsonc` (model selection, permission rules, MCP servers) is **not**
part of this payload. It is managed per machine with chezmoi, so personal and
work setups can differ. `make install` never touches it.

## How to use

1. Clone the repo and run `make install` (or `make dry-run` to preview).
2. `setup-engineering` scaffolds `docs/agents/issue-tracker.md` and
   `docs/agents/domain.md` into each repo before using the engineering
   commands (`to-spec`, `to-tickets`, `code-review`).