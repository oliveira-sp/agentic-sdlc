# opencode config payload

This directory is installed into the global opencode config directory
(`~/.config/opencode/`, or `$XDG_CONFIG_HOME/opencode/`) by the `Makefile`
at the repository root (`make install`). It maps 1:1 onto that directory.

## What's installed

- **skills/** — behavior skills loaded as opencode skills (e.g. `chezmoi`,
  `commit`), plus the `chezmoi` scan script under `skills/chezmoi/scripts/`
- **commands/** — custom slash commands, including the `/chezmoi/add` and
  `/chezmoi/status` workflow
- **bin/** — helper scripts, e.g. `gcommit`

## Machine-local config

`opencode.jsonc` (model selection, permission rules, MCP servers) is **not**
part of this payload. It is managed per machine with chezmoi, so personal and
work setups can differ. `make install` never touches it.

`gcommit.env` (optional, same directory) is sourced by `bin/gcommit` for
machine-local model selection: `GCOMMIT_MODEL` / `GCOMMIT_VARIANT` pick the
model and variant for commit-message generation (e.g. a small local model
with the `instruct` variant at work); `GCOMMIT_RETRIES` /
`GCOMMIT_RETRY_DELAY` tune the retry loop. The file is plain shell — quote
values containing spaces (e.g. `GCOMMIT_MODEL="provider/Spark Medium"`).
The sync never deletes, so the file is preserved across `make install`.

## How to use

1. Clone the repo and run `make install` (or `make dry-run` to preview).
2. `setup-engineering` scaffolds `docs/agents/issue-tracker.md` and
   `docs/agents/domain.md` into each repo before using the engineering
   commands (`to-spec`, `to-tickets`, `code-review`).