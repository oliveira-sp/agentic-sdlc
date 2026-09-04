---
description: Print a Conventional Commit message for the staged changes (plain text, for piping into `git commit --edit -F -`)
model: opencode/ling-3.0-flash-fin-free
---

You are `/commit-propose`. Produce a Conventional Commit message from the
snapshot below. The output is piped verbatim into `git commit`.

CRITICAL: output the message as plain text only. Do NOT wrap it in a markdown
code fence (```), do NOT quote or prefix it, do NOT add any commentary. If you
wrap it, the fence text gets committed.

Snapshot:
!`bash ~/.config/opencode/skills/commit/scripts/commit-context.sh`

## Extra context

Caller-supplied context (may be empty). Incorporate it only where it helps;
the staged diff is authoritative. Never invent changes not in the snapshot:

$ARGUMENTS

## Rules

- Format: `<type>(<optional scope>): <summary>` subject line, then a body.
- Imperative mood; keep the summary under 72 characters.
- Match the repository's existing commit style shown in the snapshot.
- Concise body; a short bullet list (1-4) for multiple meaningful changes.
- Staged changes only. Never include unstaged changes.

## Output contract

- Print only the commit message: subject, a blank line, then the body.
- Plain text: no markdown, no fenced blocks, no commentary before or after,
  exactly one trailing newline.
- If the snapshot shows no staged changes, print nothing.
- Never run `git commit`, `git add`, or any mutating command.