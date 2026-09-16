---
description: Generate, review, and create a Conventional Commit from staged changes
---

You are executing `/commit`. Load and follow the **commit** skill completely.

Context for the current repo:
!`bash ${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills/commit/scripts/commit-context.sh`

Note: this snapshot targets the repo where the command was launched. If the
commit target differs from the current directory (for example a chezmoi
handoff), re-run the script yourself with an explicit `DIR` (e.g.
`$(chezmoi source-path)`) and prefer its output.