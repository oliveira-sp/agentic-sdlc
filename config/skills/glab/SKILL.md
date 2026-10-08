---
name: glab
description: Work with GitLab using the glab CLI — projects, issues, merge requests,
  pipelines, releases, and more. Use for any GitLab task.
compatibility: opencode
---

# GitLab via glab

All GitLab interaction goes through `glab`: never raw `curl`/HTTP requests,
GitLab web fetches, or other CLIs — including links the user pastes; resolve
those with `glab` instead of fetching the page.

Discover exact commands instead of guessing: run `glab --help` for command
groups, then `glab <group> --help` and `glab <group> <sub> --help` before
using any command or flag.

Use a dedicated subcommand whenever one exists. `glab api` is a last resort:
use it only when no subcommand covers the task, and state the endpoint and
why no subcommand fit.

## Command map

- Repos and projects: `glab repo` (list, view, search, contributors)
- Issues: `glab issue list|view|create|update|note|close|reopen|link`
- Other work items, incl. epics: `glab work-items` (EXPERIMENTAL)
- Merge requests: `glab mr list|view|diff|note|approve|revoke`
- CI/CD: `glab ci list|status|get|trace`, `glab job`
- Metadata: `glab label`, `glab milestone`, `glab iteration`, `glab user`, `glab todo`
- Releases: `glab release list|view` — Search: `glab search`
- Last resort: `glab api <endpoint>` — only when no subcommand fits (see gotchas)

## Scope of change by intent

- Read-only question: never create, edit, close, delete, trigger, or retry anything.
- MRs are review-and-comment only: inspect, discuss (`glab mr note create`), and
  approve/revoke on explicit request. Never create, update, merge, rebase,
  close, or delete MRs — out of scope for this skill.
- Requested change: for issues and work items, make only the change the user
  asked for, on the confirmed target; verify success before retrying an
  ambiguous failure.
- Deletion and bulk changes: only on an explicit user request; say what will
  be affected before running.

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
