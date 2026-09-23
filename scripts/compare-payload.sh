#!/usr/bin/env bash
set -euo pipefail

mode="${1:?expected diff or status}"
payload="${2:?expected payload directory}"
dest="${3:?expected destination directory}"

case "$mode" in
  diff | status) ;;
  *)
    printf 'unknown mode: %s\n' "$mode" >&2
    exit 2
    ;;
esac

compare_files() {
  local color="$1"
  local file rel installed label

  while IFS= read -r -d '' file; do
    rel="${file#"$payload"/}"
    installed="$dest/$rel"

    if [[ "$mode" == "status" ]]; then
      if [[ ! -f "$installed" ]]; then
        printf 'not installed: %s\n' "$rel"
      elif ! cmp -s "$installed" "$file"; then
        printf 'differ: %s\n' "$rel"
      fi
      continue
    fi

    label="installed: $rel"
    if [[ ! -f "$installed" ]]; then
      installed=/dev/null
      label=/dev/null
    fi

    diff -u --color="$color" \
      --label "$label" --label "repo: $rel" \
      "$installed" "$file" || true
  done < <(find "$payload" -type f -print0 | sort -z)
}

if [[ "$mode" == "diff" && -t 1 ]]; then
  compare_files always | less -FRX || true
else
  compare_files never
fi
