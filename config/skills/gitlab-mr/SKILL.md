---
name: gitlab-mr
description: Review GitLab merge requests with glab: find MRs, inspect metadata, diffs, commits, pipelines and discussions, comment, and approve. Use for GitLab MR reviews; excludes merging and general MR management.
compatibility: opencode
---

# GitLab MR review

Use `glab mr list`, `glab mr view`, and `glab mr diff` to find the correct MR
and inspect its metadata and changes. Read discussions with `glab mr note list`
(or `glab mr view` comments), and check eligible approvers with
`glab mr approvers`. For its **head** pipeline,
use `glab ci get` with its MR selector; a branch pipeline may differ. For MR
commits, inspect local Git history when available or consult `glab api --help`
for a GET-only request; glab 1.113.0 has no `glab mr commits` subcommand.

When the user asks for review feedback, use `glab mr note create` to comment
or reply to a discussion; `glab mr note resolve` and `glab mr note reopen`
change discussion state. Use `glab mr approve` or `glab mr revoke` only on
explicit request. Inspect the MR, discussion, and diff line before posting;
check for an existing comment before retrying an ambiguous failure.

Use `glab <command> --help` before choosing flags (including scope, output,
and pagination); use only GET without fields/forms/input for API reads. Do not
merge, create, edit, rebase, close, or delete MRs as part of a review. Avoid
`glab ci view` (interactive job mutations), pipeline variables, tokens, and
credentials. Honor bash permission prompts for comments and approvals.
