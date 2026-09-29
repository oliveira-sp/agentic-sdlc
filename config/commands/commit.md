---
description: Propose a Conventional Commit and offer commit, edit, or cancel
agent: commit
---

Propose a Conventional Commit message from the rules and snapshot below,
then let the user choose whether to commit, edit the message, or cancel.

Shared commit-message rules:
!`cat "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills/commit/commit-prompt.md"`

Context for the current repo:
!`bash "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills/commit/scripts/commit-context.sh"`

Caller-supplied context (may be empty):
$ARGUMENTS

## Workflow

Do not load any skills. Follow this workflow directly using the embedded rules
and snapshot. Operate on the repository identified by the snapshot's top-level
path; do not stage, unstage, or modify files.

1. If the snapshot reports an error, surface it and stop. If nothing is staged,
   tell the user and stop.
2. Present the proposed commit message for the staged changes.
3. Ask: "Commit this message? (commit / edit / cancel)" and wait for the user.
4. On **edit**, ask for the desired changes, present the revised message, and
   offer commit / edit / cancel again. On **cancel**, stop.
5. On **commit** (or an explicit yes), refresh the snapshot for the same target
   repository and verify that the staged diff still matches the proposal:

       bash "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills/commit/scripts/commit-context.sh" "$DIR"

   If the staged diff changed, revise the proposal and ask for confirmation
   again. Otherwise create the approved commit using a quoted heredoc:

       git -C "$DIR" commit -F - <<'COMMIT_MESSAGE'
       <approved message>
       COMMIT_MESSAGE

6. Report the commit result, or surface the error if it fails.

Never create a commit without explicit user confirmation.
