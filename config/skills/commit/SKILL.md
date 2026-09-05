---
name: commit
description: Create a Conventional Commit from staged changes. Use when asked to commit, or when a workflow (e.g. /chezmoi/stage) hands off to commit.
compatibility: opencode
---

Create a Conventional Commit for the staged changes.

## Gather context

Run the bundled snapshot script:

    bash ~/.config/opencode/skills/commit/scripts/commit-context.sh [--chezmoi | DIR]

- Omit arguments to target the current repo (cwd).
- Use `--chezmoi` for dotfiles flows (resolves `chezmoi source-path`).
- Pass an explicit `DIR` for any other target repo.
- Prefer the script's output over ad-hoc `git` calls. If it errors (`ERROR:
  not a git repository` / `--chezmoi` unavailable), stop and surface the error.

The snapshot shows: top-level & branch, `status --short`, recent commit style,
staged diff stat, the full staged diff, and unstaged filenames only.

## Rules

- Format: `<type>(<optional scope>): <summary>` with a body.
- Use imperative mood.
- Keep the summary under 72 characters.
- Match the repository's existing commit style (from the snapshot).
- Prefer a concise body. Use a short bullet list (1-4) for multiple meaningful
  changes.
- Avoid unnecessary implementation details.
- Only use staged changes. Never include unstaged changes.

## Workflow

1. Propose the commit message to the user.
2. Ask: "Commit this message? (yes / edit / cancel)".
3. On yes, commit via a heredoc so multiline bodies render correctly:

       git commit -F -

   On edit, take the corrected message, then commit the same way. On cancel,
   stop.

Never commit without explicit user confirmation.