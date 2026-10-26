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
  local file rel installed label status
  local -a added=() modified=()

  while IFS= read -r -d '' file; do
    rel="${file#"$payload"/}"
    installed="$dest/$rel"

    if [[ "$mode" == "status" ]]; then
      if [[ ! -f "$installed" ]]; then
        added+=("$rel")
      elif ! cmp -s "$installed" "$file"; then
        modified+=("$rel")
      fi
      continue
    fi

    if [[ -f "$installed" ]] && cmp -s "$installed" "$file"; then
      continue
    fi

    printf 'diff --git a/%s b/%s\n' "$rel" "$rel"
    label="a/$rel"
    if [[ ! -f "$installed" ]]; then
      installed=/dev/null
      label=/dev/null
      if [[ -x "$file" ]]; then
        printf 'new file mode 100755\n'
      else
        printf 'new file mode 100644\n'
      fi
    fi

    status=0
    diff -u --color="$color" \
      --label "$label" --label "b/$rel" \
      "$installed" "$file" || status=$?
    if (( status > 1 )); then
      return "$status"
    fi
  done < <(find "$payload" -type f -print0 | sort -z)

  if [[ "$mode" == "status" ]]; then
    if (( ${#added[@]} + ${#modified[@]} == 0 )); then
      printf 'Nothing to install (installed files match repository payload).\n'
      return
    fi

    printf 'Changes to be installed:\n'
    printf '  (installed files → repository payload; run "make install" to apply)\n\n'
    for rel in "${added[@]}"; do
      printf '\tnew file:   %s\n' "$rel"
    done
    for rel in "${modified[@]}"; do
      printf '\tmodified:   %s\n' "$rel"
    done
  fi
}

if [[ "$mode" == "diff" && -t 1 ]]; then
  compare_files always | less -FRX || true
else
  compare_files never
fi
