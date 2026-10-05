---
name: glab
description: Work with GitLab using the glab CLI — read projects, issues, work items,
  pipelines, and releases; review merge requests (diffs, discussions, comments,
  approvals); and manage issues and work items (create, update, label, comment, close).
  Use for any GitLab task.
compatibility: opencode
---

# GitLab via glab

`glab` covers all GitLab interaction. Discover exact commands instead of guessing:
run `glab --help` for command groups, then `glab <group> --help` and
`glab <group> <sub> --help` before using any command or flag.

## Command map

- Repos and projects: `glab repo` (list, view, search, contributors)
- Issues: `glab issue list|view|create|update|note|close|reopen|link`
- Other work items, incl. epics: `glab work-items` (EXPERIMENTAL)
- Merge requests: `glab mr list|view|diff|note|approve|revoke`
- CI/CD: `glab ci list|status|get|trace`, `glab job`
- Metadata: `glab label`, `glab milestone`, `glab iteration`, `glab user`, `glab todo`
- Releases: `glab release list|view` — Search: `glab search`
- Anything else: `glab api <endpoint>` (see gotchas)

## Scope of change by intent

- Read-only question: never create, edit, close, delete, trigger, or retry anything.
- MR review: inspect and comment (`glab mr note create`); approve/revoke only on
  explicit request; never merge, create, edit, rebase, close, or delete MRs.
- Requested change: make only that change on the confirmed target; verify success
  before retrying an ambiguous failure.

## Gotchas

- `glab api` reads must be plain GETs: no fields, forms, or `--input` — they can
  flip the method to POST and mutate state.
- Never request secrets: avoid `glab auth status --show-token` and
  `glab ci get --with-variables`.
- Avoid `glab ci view`: it mutates jobs interactively; use non-interactive reads.
- `glab work-items` supports fewer edits than `glab issue`; check its help first.
- glab 1.113.0 has no `glab mr commits`; use local git history or an API GET.

Prefer the current repository unless the user specifies another. Honor bash
permission prompts; never use wrappers or API calls to bypass them.
