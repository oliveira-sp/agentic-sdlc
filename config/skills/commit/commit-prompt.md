# Commit-message rules

Write a Conventional Commit message from the staged-change snapshot.

- Format: `<type>(<optional scope>): <summary>` subject line.
- Use imperative mood; keep the summary under 72 characters; no trailing period.
- Match the repository's existing commit style shown in the snapshot.
- Add a concise body only when it adds value. Use a short bullet list (1-4)
  for multiple meaningful changes; omit the body for trivial single changes.
- Avoid unnecessary implementation details.
- Describe staged changes only. Never include unstaged changes or invent
  changes not present in the staged diff.
- Use caller-supplied context only where it helps; the staged diff is
  authoritative.
- Never add trailers (Co-Authored-By, Generated with, etc.) unless the
  repository's recent log shows them.

## Example message

    fix(auth): reject expired tokens

    - Validate expiry before signature check
    - Return 401 with a `token_expired` error code
