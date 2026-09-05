---
description: Read-only overview of chezmoi state: unmanaged configs, edited-in-place files, and source repo git status
---

You are executing `/chezmoi/status`.

Load and follow the **chezmoi** skill completely. Read-only: never add, stage,
commit, push, apply, or modify anything.

## Scan

Run the read-only scan to get the current state:

!`bash ~/.config/opencode/skills/chezmoi/scripts/chezmoi-scan.sh`

Also inspect the source repo git state (read-only):

    SRC="$(chezmoi source-path)"; git -C "$SRC" status --short; git -C "$SRC" log --oneline -5

## Present

Summarize concisely:

- **edited** (deployment-pending) — your `$HOME` copy differs from source;
  ready to capture with `/chezmoi/add`
- **unmanaged** candidates — config files not yet in source
- **suspicious** — flagged names + reasons only, never contents
- **git-pending** — uncommitted source-repo changes (staged/unstaged split)

Then offer to open `/chezmoi/add` to capture a batch.

## Constraints

- No writes, no `chezmoi add`, no staging, no commits, no push.
- Never print secret values; report filenames and reasons only.