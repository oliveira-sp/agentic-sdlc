#!/usr/bin/env bash
set -euo pipefail

DIR="${1:-.}"

if ! git -C "$DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: not a git repository: $DIR" >&2
  exit 1
fi

GIT_DIR="$(git -C "$DIR" rev-parse --absolute-git-dir)"
in_progress=""
if [[ -f "$GIT_DIR/MERGE_HEAD" ]]; then in_progress="merge"; fi
if [[ -f "$GIT_DIR/CHERRY_PICK_HEAD" ]]; then in_progress="${in_progress:+$in_progress + }cherry-pick"; fi
if [[ -d "$GIT_DIR/rebase-merge" || -d "$GIT_DIR/rebase-apply" ]]; then in_progress="${in_progress:+$in_progress + }rebase"; fi

echo "=== commit context: $DIR ==="
if [[ -n "$in_progress" ]]; then
  echo "WARNING: $in_progress in progress"
fi
echo
echo "--- top-level & branch ---"
git -C "$DIR" rev-parse --show-toplevel
out="$(git -C "$DIR" branch --show-current 2>/dev/null)" || true
[[ -n "$out" ]] && echo "$out" || echo "(detached HEAD or unborn branch)"
echo
echo "--- status --short ---"
out="$(git -C "$DIR" status --short)"
[[ -n "$out" ]] && echo "$out" || echo "(clean)"
echo
echo "--- log --oneline -12 (type/scope vocabulary) ---"
out="$(git -C "$DIR" log --oneline -12 2>/dev/null)" || true
[[ -n "$out" ]] && echo "$out" || echo "(no commits yet)"
echo
echo "--- log -3 full messages (body & trailer style) ---"
out="$(git -C "$DIR" log -3 --format='--- %h%n%B' 2>/dev/null)" || true
[[ -n "$out" ]] && echo "$out" || echo "(no commits yet)"
echo
echo "--- staged diff stat ---"
out="$(git -C "$DIR" diff --cached --stat)"
[[ -n "$out" ]] && echo "$out" || echo "(none)"
echo
echo "--- staged diff (full) ---"
out="$(git -C "$DIR" diff --cached)"
[[ -n "$out" ]] && echo "$out" || echo "(none)"
echo
echo "--- unstaged diff (names only) ---"
out="$(git -C "$DIR" diff --name-status)"
[[ -n "$out" ]] && echo "$out" || echo "(none)"