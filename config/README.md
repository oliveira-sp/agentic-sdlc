# opencode config payload

This directory is installed into the global opencode config directory
(`~/.config/opencode/`, or `$XDG_CONFIG_HOME/opencode/`) by the `Makefile`
at the repository root (`make install`). It maps 1:1 onto that directory.

## What's installed

- **skills/** — behavior skills loaded as opencode skills (e.g. `chezmoi`,
  `commit`), plus the `chezmoi` scan script under `skills/chezmoi/scripts/`
- **commands/** — custom slash commands, including the `/chezmoi/add` and
  `/chezmoi/status` workflow
- **bin/** — helper scripts: `gcommit`

## Machine-local config

`opencode.jsonc` (model selection, permission rules, MCP servers) is **not**
part of this payload. It is managed per machine with chezmoi, so personal and
work setups can differ. `make install` never touches it.

`gcommit.env` (optional, same directory) is sourced by `bin/gcommit` for
machine-local model selection. `GCOMMIT_AGENT` selects the agent (defaults to
`commit`). The script uses OpenCode's API and `jq` to resolve that agent's model
in the current directory, then explicitly passes the full `provider/model#variant`
reference to `opencode run`. This preserves variants such as `instruct` that
can be lost when selecting only the agent. If the agent has no model, OpenCode's
default applies.

`GCOMMIT_MODEL` overrides the agent model (e.g.
`GCOMMIT_MODEL="provider/model#instruct"`) and skips the API lookup.
`GCOMMIT_VARIANT`, when set, overrides the variant on that model reference;
it requires either an explicit model or one configured on the agent.
`GCOMMIT_RETRIES` / `GCOMMIT_RETRY_DELAY` tune the generation retry loop.
Failed commands, empty responses, and invalid messages all consume an attempt.
The script requires a Conventional Commit subject and rejects tool-call or
reasoning markup, fenced blocks, control characters, and malformed body
separation. If no valid response is produced, it exits without running Git's
commit command; it never tries to salvage a message by stripping markup.
`GCOMMIT_DEBUG=1` (or `gcommit --debug`) prints the resolved model and the
whole prompt to stderr before sending it, preserves OpenCode's stderr, and
prints rejected responses. Debug output may contain sensitive repository data.
Flags are consumed by the script;
pass `--` to forward arguments that look like flags.
The file is plain shell — quote values containing spaces.
The sync never deletes, so the file is preserved across `make install`.

## How to use

1. Clone the repo and run `make install` (or `make dry-run` to preview).
2. Tracker-wired commands and skills (`to-spec`, `to-tickets`, `code-review`)
   read `docs/agents/issue-tracker.md` and `docs/agents/domain.md` from the
   consuming repo and stop with guidance when those files are missing. Seed
   them per repo, following the reference copies in this repo's `docs/agents/`.

## Commit workflows

- **`/commit`** selects the `commit` agent and its configured model/variant,
  inserts `skills/commit/commit-prompt.md` directly into its prompt with a shell
  `cat` block, and runs `commit-context.sh` in another shell block to embed the
  current repo's snapshot. Its self-contained workflow proposes a message and
  offers **commit / edit / cancel**. After confirmation, it verifies the staged
  diff and creates the commit. It does not load skills or stage changes.
- **Commit skill** supports conversational requests and agentic handoffs. It
  defaults to the current staged changes, stages additional changes only when
  explicitly scoped, and proposes a message. It reuses the supplied snapshot
  when current, or gathers one after staging or switching target repositories.
  It creates the commit only after user confirmation. Direct skill invocation
  reads the same shared message rules.
- **`gcommit [context...]`** reads the shared prompt file directly, adds the
  staged snapshot and optional context, and asks the model for only a message.
  It does not invoke a slash command or load the skill. The script then runs
  `git commit --edit -F -` so the user reviews the message in Git's editor.

The shared prompt has no YAML frontmatter. Message-writing rules live there.
`/commit` owns its staged-only confirmation workflow; the skill also supports
explicitly scoped staging for agentic workflows. `gcommit` supplies a
message-only output contract and leaves review to Git's editor.

Both entry points use the same machine-local `commit` agent by default. Configure
it as a primary agent with the desired `provider/model#variant` in
`opencode.jsonc`. `/commit` needs shell permission to refresh the snapshot and
execute the approved Git commit; a blanket deny-all agent rule blocks those
steps. Neither entry point loads skills. Use the commit skill from a
tool-capable agent for conversational staging-and-confirmation workflows.

For a message-only `gcommit` agent, configure a dedicated formatter `system`
prompt and deny all tools. A non-empty `system` replaces OpenCode's default
coding-agent prompt; permission denial alone does not do that. Such an agent
is not suitable for `/commit`'s tool-based workflow. Use `GCOMMIT_AGENT` to
select a separate formatter when both workflows are needed.

Run the isolated script tests from the repository root with
`python3 scripts/test-gcommit.py`. They mock OpenCode and Git, including the
commit command, and do not contact a provider or create real commits.

`/commit-propose` has been retired. Because `make install` is additive, remove
any old installed command file once after updating:

```sh
rm -- "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/commands/commit-propose.md"
```
