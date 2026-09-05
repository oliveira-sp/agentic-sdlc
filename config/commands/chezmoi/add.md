---
description: Capture config files into chezmoi source (unmanaged or edited in place) and stage them for /commit
---

You are executing `/chezmoi/add`.

Arguments: $ARGUMENTS

Load and follow the **chezmoi** skill completely.

## Scan

Run the read-only scan to get the current candidates:

!`bash ~/.config/opencode/skills/chezmoi/scripts/chezmoi-scan.sh`

The table columns are: `target | kind | projected source path | add flags | note`.

## Workflow

1. Present the candidates grouped by signal:
   - **edited** (deployment-pending: your `$HOME` copy differs from source) — these
     are the highest-signal "capture my change" items
   - **unmanaged** candidates (with flags: `--recursive` for dirs, etc.)
   - **suspicious** listed separately with reasons (names only, never contents):
     never offer these for silent addition
2. Ask the user which to add (question tool, multi-select). For a directory,
   respect the flag column unless the user prefers `--exact --recursive`.
3. Add each selected target:
   - `chezmoi add <target>` with the flags from the scan table
   - a file edited in place is captured with the same bare `chezmoi add <target>` —
     there is no separate re-add step
   - suspicious items: only with `--encrypt` AND an explicit confirmation prompt
     naming "credentials/keys will be encrypted into the source repo"
4. Stage exactly what was added: map each added target to its source path
   (from the scan table, or `chezmoi source-path ~/<target>`), then in the
   source repo (`$(chezmoi source-path)`):

       git add -- <source-path-1> <source-path-2> ...

   Never `git add -A`, `git add .`, or `git add -u`. Leave pre-existing staged
   changes and unrelated files untouched.
5. Verify: `chezmoi status` on the added targets and
   `git -C "$(chezmoi source-path)" diff --cached --stat`. Summarize what was
   added and staged.

## Hand off

Tell the user to run `/commit` (generic commit skill) to create the commit.
Do not commit, push, reset, restore, or delete anything.

## Constraints

- Never commit, push, reset, restore, or delete anything.
- Never print secret values; report filenames and reasons only.
- Never add `.ssh`, `.gitlab`, tokens, or credentials silently; `--encrypt`
  plus explicit confirmation only.
- Only `chezmoi add` files the user explicitly selected.