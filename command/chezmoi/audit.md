---
description: Audit the Chezmoi source repo and propose logical commit groups (read-only)
---

You are executing `/chezmoi/audit`.

Load and follow the **chezmoi** skill completely.

1. Delegate to the `chezmoi-commit-prep` agent (Task tool) to inspect git and
   deployment state and derive the grouped proposal.
2. Present the numbered groups; separate git-pending from deployment-pending.
3. Flag any suspicious files (names + reasons only, never contents).
4. Hand off to `/chezmoi/stage N` for staging.

Constraints: strictly read-only; never stage, commit, push, reset, restore, or
modify anything. Never print secret values. Do not unstage or reorder the
user's existing staged changes.
