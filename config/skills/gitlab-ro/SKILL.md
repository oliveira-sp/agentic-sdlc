---
name: gitlab-ro
description: Read GitLab projects, repositories, epics, issues, work items, milestones, labels, releases, users, and pipelines with glab. Use for GitLab lookup, search, metadata, or status questions without changing GitLab state.
compatibility: opencode
---

# GitLab read-only

Use `glab` to answer GitLab questions without changing GitLab state.

- Projects and repositories: `glab repo` (list, search, view, contributors).
- Epics and other work items: `glab work-items list` (filter by type); issues:
  `glab issue list` and `glab issue view`. `glab work-items` is experimental.
- Planning and metadata: `glab label` (list, get), `glab milestone` (list,
  get), `glab iteration list`, `glab user events`, `glab todo list`.
- Releases and CI: `glab release list/view`, `glab ci list/status/get/trace`.
  Use `glab mr list` or `glab mr view` for MR lookup; use `gitlab-mr` for reviews.

Before running a command, consult `glab <command> --help` for its exact flags,
output format, pagination, and project/group selector. Prefer the current
repository unless the user specifies another. If a dedicated read command is
missing, consult `glab api --help` and use an explicit GET with no fields,
forms, or input (those can change the default method to POST).

Never create, edit, close, delete, trigger, or otherwise mutate GitLab state.
Load `gitlab-wr` for requested work-item changes or `gitlab-mr` for MR review.
`glab ci view` can run/retry/cancel jobs interactively; use non-interactive
read commands instead. Never request secrets or credentials: avoid
`glab ci get --with-variables` and `glab auth status --show-token`.
