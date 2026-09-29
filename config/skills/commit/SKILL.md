---
name: commit
description: Prepare explicitly scoped changes, propose a Conventional Commit, and commit after user confirmation. Use when asked to commit, or when a workflow (e.g. /chezmoi/add) hands off to commit.
compatibility: opencode
---

Prepare and propose a Conventional Commit, then create it after user confirmation.

## Determine scope and stage

- Determine the target repository from the request or workflow handoff. Default
  to the current repo; for chezmoi handoffs, use `chezmoi source-path`.
- Default to changes already staged. Do not stage additional changes unless
  the user or handing-off workflow explicitly identifies the intended files
  or changes. Ask for clarification when that scope is ambiguous.
- Before staging, inspect the target repo's status and existing staged diff.
  Identify unrelated staged changes and ask the user how to handle them before
  proceeding; do not silently include or unstage them.
- Inspect the intended changes, then stage only the identified paths with
  `git -C "$DIR" add -- <paths>`. Never use `git add .`, `git add -A`, or
  `git add -u` to sweep in other changes. If a file mixes intended and unrelated
  changes, or is partially staged, do not stage the whole file; clarify which
  hunks belong in the commit.
- Preserve unrelated working-tree and staged changes.

## Gather context

If a snapshot is already supplied by the caller, reuse it when it is for
the same target and still reflects the current index. Otherwise run the bundled
snapshot script for the target repository after any staging; never reuse a
pre-staging snapshot after changing the index:

    bash "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills/commit/scripts/commit-context.sh" [DIR]

- Omit arguments to target the current repo (cwd).
- Pass an explicit `DIR` for any other target repo (for dotfiles flows, pass
  the chezmoi source path, e.g. `$(chezmoi source-path)`).
- Prefer the script's output over ad-hoc `git` calls. If it errors (`ERROR:
  not a git repository`), stop and surface the error.

The snapshot shows: top-level & branch, `status --short`, recent commit style,
staged diff stat, the full staged diff, and unstaged filenames only.

Inspect the staged diff and verify it matches the intended scope. If nothing is
staged, tell the user and stop.

## Message rules

Use the shared commit-message rules if already included in the prompt.
Otherwise read them before composing the message:

    cat "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills/commit/commit-prompt.md"

## Workflow

1. Summarize the staged scope and propose the commit message to the user.
2. Ask: "Commit this message? (yes / edit / cancel)".
3. On edit, incorporate the corrected message and request confirmation again.
   On cancel, stop.
4. On yes, verify the staged diff still matches the proposal. If it changed,
   refresh the snapshot and proposal and ask for confirmation again. Otherwise
   commit in the target repository via a quoted heredoc so multiline bodies
   render literally:

       git -C "$DIR" commit -F - <<'COMMIT_MESSAGE'
       <approved message>
       COMMIT_MESSAGE

5. Report the result. If the commit fails, surface the error.

Never commit without explicit user confirmation.
