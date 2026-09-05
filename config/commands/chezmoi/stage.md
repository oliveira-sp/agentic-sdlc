---
description: Stage one logical group of Chezmoi changes for review, e.g. /chezmoi/stage 1
---

You are executing `/chezmoi/stage`.

Arguments: $ARGUMENTS

Load and follow the **chezmoi** skill completely to stage exactly the requested
logical group of Chezmoi source changes:

1. Re-evaluate the current Chezmoi/Git state fresh (do not trust conversation history).
2. Re-derive the logical groups using the skill rules; map $ARGUMENTS to a
   group; if it no longer exists, show the current groups and ask.
3. Show the files to be staged (source + target paths, git status).
4. Run the suspicious-file check; stop and ask before staging anything suspicious.
5. Stage only those files with explicit pathspecs (`git add -- <paths>`).
   Never use `git add -A`, `git add .`, or `git add -u`.
6. Review `git diff --cached` and report what was staged and what remains.
7. Load and follow the **commit** skill to review and commit the staged group.

Constraints: never commit, push, reset, restore, or modify source file
contents. Leave pre-existing staged changes and unrelated files untouched.
