---
description: Generate, review, and create a Conventional Commit from staged changes
---

Create a Conventional Commit for the staged changes.

First inspect:

    git diff --cached

Also inspect recent commits for style:

    git log --oneline -10

Generate a commit message following Conventional Commits.

Requirements:

- Format:

      <type>(<optional scope>): <summary>

      <body>

- Use imperative mood.
- Keep the summary under 72 characters.
- Match existing repository commit style.
- Prefer a concise body.
- Use a short bullet list when multiple meaningful changes exist.
- Use 1-4 bullets maximum.
- Avoid unnecessary implementation details.

Workflow:

1. Present the proposed commit message to the user.
2. Ask:
   "Commit this message? (yes / edit / cancel)"
3. If the user chooses:
   - yes:
       run:

           git commit -m "<message>"

   - edit:
       ask for the corrected commit message, then run `git commit`.
   - cancel:
       stop without committing.

Never commit without explicit user confirmation.

Only use staged changes. Do not include unstaged changes.

