#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--chezmoi" ]]; then
  if ! command -v chezmoi >/dev/null 2>&1; then
    echo "ERROR: --chezmoi requested but chezmoi is not on PATH" >&2
    exit 1
  fi
  DIR="$(chezmoi source-path)"
else
  DIR="${1:-.}"
fi

if ! git -C "$DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: not a git repository: $DIR" >&2
  exit 1
fi

echo "=== commit context: $DIR ==="
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
echo "--- log --oneline -12 (style) ---"
out="$(git -C "$DIR" log --oneline -12 2>/dev/null)" || true
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