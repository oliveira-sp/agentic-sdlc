---
name: gitlab-wr
description: Manage GitLab issues and work items with glab: create, update, assign, label, comment, change milestones, close, and reopen. Use when a user requests a GitLab work-item change; use gitlab-ro for read-only lookup.
compatibility: opencode
---

# GitLab work items

Use this skill when the user asks to change an issue, epic, or other GitLab
work item. For lookup alone, load `gitlab-ro` instead.

- Find the correct project and item first with `glab issue list`,
  `glab issue view`, or `glab work-items list`; inspect its current state.
- Use `glab issue create` and `glab issue update` for issue creation and edits.
  Update covers assignment/unassignment, labels, milestones, title, and
  description. Use `glab issue note` for comments, and `glab issue close` or
  `glab issue reopen` for state.
- `glab work-items create`, `glab work-items update`, and `glab work-items list`
  cover other work-item types, including epics. This command group is
  experimental and supports fewer edits than `glab issue`.
  Check the supported operations before selecting a command.

Run `glab <command> --help` for exact arguments and flags (including output,
scope, and pagination); do not assume issue flags work for work items. Only
make the change the user requested. Confirm the target before posting a note,
and check whether a write succeeded before retrying an ambiguous failure.

Deletion, bulk changes, and administrative changes to project labels or
milestones are outside this skill. Do not handle credentials, tokens,
variables, or secrets. Respect skill and bash permission prompts; never use
shell wrappers, aliases, or API calls to bypass them.
