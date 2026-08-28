---
description: Discover config files not yet managed by chezmoi and add the ones you pick
---

You are executing `/chezmoi/add`.

Arguments: $ARGUMENTS

Load and follow the **chezmoi** skill completely.

## Workflow

1. Delegate discovery to the `chezmoi-discover` agent (Task tool). It returns
   the classified candidate list.
2. Present the candidates (source path -> target path) and ask the user which
   to add using the question tool (multi-select).
3. For each selected candidate, run `chezmoi add <target>` with the flags from
   the skill:
   - directories -> `--recursive` (full dir: `--exact --recursive`)
   - machine-specific content -> offer `--template`
   - suspicious/secret files -> ONLY with `--encrypt` and explicit confirmation
   Never add `.ssh`, `.gitlab`, tokens, or credentials silently.
4. Verify with `chezmoi status` and summarize what was added.

## Hand off

After adding, run `/chezmoi/audit` to review and propose commit groups, then
`/chezmoi/stage N`, then `/commit`.

## Constraints

- Never commit, push, reset, restore, or delete anything.
- Never print secret values.
- Only `chezmoi add` files the user explicitly selected.
