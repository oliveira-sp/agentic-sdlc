---
name: chezmoi
description: How to use the chezmoi CLI for dotfiles management: source repo and path mapping, status semantics, add flags, discovery of unmanaged configs, and audit/stage/commit workflows. Use for any chezmoi task, including the /chezmoi/* commands.
---

# Chezmoi

Chezmoi manages dotfiles from a source tree (usually `~/.local/share/chezmoi`)
tracked in Git; deployed files in `$HOME` are rendered from that tree and may
differ from it.

## Source repo and path mapping

    chezmoi source-path

Source files use prefixes that do NOT match deployed paths:

| Prefix / marker | Meaning |
| --------------- | ------- |
| `dot_` | hidden file/dir in `$HOME` (`dot_zshrc` -> `~/.zshrc`) |
| `private_` | restrictive mode 0600 (`private_dot_ssh`) |
| `executable_` | executable mode 0755 |
| `symlink_` | content is the symlink target |
| `run_` | run-once / run-always script |
| `.tmpl` | Go template, never deployed verbatim |
| `.chezmoiignore` etc. | metadata, not deployed |

Map source -> target: `chezmoi target-path <source-relative-path>`
Map target -> source: `chezmoi source-path ~/<target>`

## Status semantics

`chezmoi status` shows target-relative paths, two columns:
- first: difference between the last state written by chezmoi and the deployed file
- second: difference between the deployed file and the target state (`chezmoi apply` would change)

`chezmoi diff` shows what apply would change; run per target if large.

Distinguish:
- **Git-pending**: uncommitted changes in the source repo (would be committed)
- **Deployment-pending**: source differs from deployed; committing does NOT deploy

## Adding files

    chezmoi add <target>

Flags:
- `--recursive` — add directories recursively
- `--exact` — manage a directory exactly (use with `--recursive`)
- `--template` — render as a template; offer when content is machine-specific (paths, hostname)
- `--encrypt` — encrypt the file (for secrets; requires encryption configured)
- `--create` — add files that should exist, irrespective of contents

Never `chezmoi add` suspicious/secret files without `--encrypt` and explicit
user confirmation.

## Discovery of unmanaged files

`chezmoi unmanaged` lists targets in `$HOME` not present in the source state.

Candidate scope:
- dotfiles directly in `$HOME` (entries starting with `.`)
- `~/.config/<app>/...` entries

Noise denylist (skip silently): `.DS_Store`, `.Trash`, `.CFUserTextEncoding`,
caches (`.cache`, `.npm`, `.matplotlib`, `.ccache`, `.lesshst`, `.zcompdump*`),
history/session files (`*_history`, `.bash_sessions`, `.zsh_sessions`,
`.viminfo`, `.zshrc.pre-oh-my-zsh`), tool data (`.docker`, `.vscode`,
`.cursor`, `.copilot`, `.colima`, `.oh-my-zsh`, `.config/chezmoi`, `.local`),
non-config home entries (Desktop, Documents, Downloads, Library, Movies,
Music, Pictures, Public, ...).

Already-versioned: directories containing `.git` (e.g. `.config/nvim`) — skip
with a note; they are managed by their own repo.

Suspicious (flag, never add silently): `.ssh`, `.gitlab`, `.env`, `.env.*`,
`.netrc`, `.pypirc`, `.npmrc`, `id_*`, `*.pem`, `*.p12`, `*.pfx`, `*.key`,
filenames matching `secret|token|credential|password`, or content matching
`BEGIN [A-Z]*PRIVATE KEY`, `ghp_`, `ghs_`, `glpat-`, `sk-`, `AKIA`, `AIza`.
Never print secret values; report filenames and reasons only.

## Git workflows

### Audit
Inspect git state in the source repo:
- `git status --short`, `git diff --stat`, `git diff --cached --stat`, `git log --oneline -10`
- report staged / unstaged / untracked / deletions separately

Group changes by the top-level target application/domain: `dot_config/<app>/...`
-> group `<app>`; `dot_tmux.conf` -> tmux; `dot_zshrc` -> zsh. Chezmoi metadata
(`.chezmoiignore`, `.chezmoiversion`, `.chezmoiremove`, `.chezmoidata.*`,
`.chezmoitemplates/`) -> group `chezmoi meta`. Suspicious files -> own bucket
`Suspicious/unclassified`. Generated/cache files -> `Generated/cache`
(recommend leaving uncommitted). Do not force unrelated files together.

Propose numbered groups; each becomes one logical commit.

### Stage
Stage exactly one group with explicit pathspecs only:

    git add -- <path1> <path2> ...

Never use `git add -A`, `git add .`, or `git add -u`. For deletions use the
path-scoped form `git add -A -- <path>`. Leave pre-existing staged changes and
unrelated files untouched.

### Commit
Commit via the generic `/commit` command. Never push.

## Hard constraints

- NEVER `git push` or any push variant (permission-enforced; reinforced here).
- Never print secret values; report filenames and reasons only.
- Never use `git add -A`, `git add .`, or `git add -u`.
- Never unstage or reorder the user's existing staged changes.
- No destructive git commands (reset, restore, `checkout --`, clean) without explicit approval.
