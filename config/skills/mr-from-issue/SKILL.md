---
name: mr-from-issue
description: Create a GitLab draft merge request and remote source branch from
  an issue before implementation. Use when asked to prepare an MR for an issue
  or create an issue's branch and MR.
compatibility: opencode
---

# Merge request from a GitLab issue

Load the `glab` skill for command discovery and permission handling.
Follow the target repository's instructions, including
`docs/agents/issue-tracker.md` when present.

## Workflow

### 1. Resolve the issue and project

Accept an issue number, `#N`, or GitLab issue URL.

- An explicit project or issue URL determines the host and project.
- A bare number resolves against the current repository.
- Ask when the intended project is ambiguous.
- Resolve work-item URLs by their actual type; continue only for an issue.

Read the issue's title, description, state, labels, and milestone.
Bind subsequent GitLab calls to the resolved host and project.

This workflow creates the branch and MR in the issue's project. Resolve any
request involving a different code project or fork before proceeding.

### 2. Determine the branch, base, and target

Source branch format:

    <type>/<issue-IID>-<title-slug>

Use the repository's exact Gitflow prefix convention. Infer the type from
the issue when clear; ask if the prefix convention or issue type is unclear.

Make the slug lowercase and hyphen-separated, trim it to approximately
50 characters, and validate the complete branch name.

For latest-development work:

- Branch base: `develop`.
- MR target: `develop`.

For another development line, follow explicit repository policy or ask for
the base and target. Do not infer release routing solely from a milestone.

Verify that the base and target exist remotely. If either is missing, ask;
never substitute the repository's default branch automatically.

### 3. Inspect existing state

Check:

- MRs related to the issue, including custom branch names.
- The proposed remote source branch.
- MRs using that source branch.

If a matching open MR already exists, verify it and return its current
state and handoff details.

If only the branch exists, inspect its history and relationship to the
chosen base before proposing reuse. Ask about conflicting or ambiguous
branches and closed or merged MRs.

Do not reset an existing branch or generate a suffixed duplicate merely
to get past a collision.

### 4. Prepare and confirm the setup

Propose:

- Project and issue.
- Source branch, base, and target.
- MR title: `Resolve "<issue title>"`.
- Draft status.
- Assignee: the authenticated user.
- Issue labels and milestone copied when present.
- MR description.

Use the repository's MR template when applicable. Otherwise, write a short
summary of the intended work. Describe planned work accurately.

Include the issue's closed state, if applicable, in the confirmation.
Ask for confirmation before creating resources. Apply requested edits and
repeat any affected checks.

Use project defaults for unspecified MR settings.

### 5. Create the remote branch and draft MR

Always pass an explicit title for non-interactive compatibility.
Do not rely on `--related-issue` to supply it.

For a new branch where base and target are the same, use this command
shape with the resolved values:

```sh
glab mr create \
  --repo "$PROJECT_URL" \
  --head "$PROJECT_URL" \
  --source-branch "$BRANCH" \
  --target-branch "$TARGET" \
  --create-source-branch \
  --title "$TITLE" \
  --description "$DESCRIPTION" \
  --draft \
  --related-issue "$IID" \
  --copy-issue-labels \
  --assignee "$USERNAME" \
  --yes
```

- Add `--milestone` with the issue's milestone global ID when present.
- For a verified existing branch, omit `--create-source-branch`.
- `--create-source-branch` creates from the target branch. If the confirmed
  base differs from the target, create the remote branch separately from
  the base using `glab api`, then create the MR without that flag.
- `--related-issue` appends `Closes #<IID>`. Do not also include that closing
  reference in the supplied description.
- Incorporate template content into the description; do not combine
  `--template` with `--related-issue`.
- Do not use `--fill` or `--push`.

### 6. Verify and hand off

Read the resulting remote branch and MR. Verify the source branch,
base relationship, target, draft status, issue reference, and requested
metadata.

Return:

- Whether resources were created or reused.
- Issue URL and MR URL.
- GitLab host and project.
- Matching local remote name and URL, when available.
- Source branch, base, and target.

These facts are the handoff to a later worktree workflow.

An empty diff is expected before implementation. When the target is not
the project's default branch, do not promise that `Closes #<IID>` will
automatically close the issue on that merge.

## Failure handling

After a failed or ambiguous creation, inspect remote branch and MR state
before retrying. Report partial success explicitly and resume from the
verified state.

If GitLab rejects an empty-diff MR, report the error and any branch already
created. Do not manufacture a placeholder commit or delete resources
automatically.

## Boundaries

- Preparation only: do not implement changes or create commits.
- Do not change the local checkout or index, create local branches or
  worktrees, stash, push, or move sessions. Read-only Git inspection is fine.
- Do not require a clean working tree for remote preparation.
- Do not modify issue metadata or merge, close, or delete issues or MRs.
