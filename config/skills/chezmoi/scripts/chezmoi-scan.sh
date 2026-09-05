#!/usr/bin/env bash
# Read-only scan of chezmoi state. No modifications, ever.
#
# Emits a pipe-separated table on stdout:
#   target|kind|projected source path|add flags|note
# kind: unmanaged | edited | suspicious | versioned
#
# Never prints file contents or secret values.

set -uo pipefail

SRC="$(chezmoi source-path 2>/dev/null)"
HOME_DIR="$HOME"

# ---- classification helpers -------------------------------------------------

noise() {
  case "$1" in
    .DS_Store|.Trash|.CFUserTextEncoding)                return 0 ;;
    .cache|.npm|.matplotlib|.ccache|.lesshst)            return 0 ;;
    .docker|.vscode|.cursor|.copilot|.colima|.oh-my-zsh) return 0 ;;
    .local|.config/chezmoi)                              return 0 ;;
    .zcompdump*|*_history|*node_modules)                 return 0 ;;
    .bash_sessions|.zsh_sessions|.viminfo)               return 0 ;;
    .zshrc.pre-oh-my-zsh)                                return 0 ;;
    Desktop|Documents|Downloads|Library|Movies|Music|Pictures|Public) return 0 ;;
  esac
  return 1
}

# Prints a one-word reason on stdout and returns 0 if the path is suspicious.
suspicious_reason() {
  local p="$1" base="$2"
  case "$p" in
    .ssh|.gitlab|.netrc|.pypirc|.npmrc) echo "credential store"; return 0 ;;
    .env|.env.*)                        echo "env secrets";      return 0 ;;
    *.pem|*.p12|*.pfx|*.key)            echo "private key";      return 0 ;;
    id_*)                               echo "ssh key";          return 0 ;;
  esac
  case "$base" in
    *secret*|*token*|*credential*|*password*) echo "credential filename"; return 0 ;;
  esac
  return 1
}

# Projected source path for a not-yet-managed target (dot_ rule).
derive_source() {
  local t="$1" out="" seg="" first=1
  local IFS='/'
  for seg in $t; do
    [ -z "$seg" ] && continue
    if [ "$first" -eq 1 ]; then
      case "$seg" in
        .*) out="dot_${seg#.}" ;;
        *)  out="$seg" ;;
      esac
      first=0
    else
      case "$seg" in
        .*) out="$out/dot_${seg#.}" ;;
        *)  out="$out/$seg" ;;
      esac
    fi
  done
  printf '%s' "$out"
}

# ---- unmanaged candidates ---------------------------------------------------

while IFS= read -r t || [ -n "$t" ]; do
  [ -z "$t" ] && continue
  # candidate scope: hidden entries (leading .) or ~/.config/<app>/... only
  case "$t" in
    .config/*|.*) : ;;
    *) continue ;;
  esac
  noise "$t" && continue

  abs="$HOME_DIR/$t"
  base="$(basename "$t")"

  # already-versioned directory (own git repo) -> note and skip as candidate
  if [ -d "$abs" ] && [ -d "$abs/.git" ]; then
    printf '%s|%s|%s|%s|%s\n' "$t" versioned "$(derive_source "$t")" "" "own git repo"
    continue
  fi

  # suspicious filenames -> flag, never add silently
  if reason="$(suspicious_reason "$t" "$base")"; then
    printf '%s|%s|%s|%s|%s\n' "$t" suspicious "$(derive_source "$t")" "--encrypt" "$reason"
    continue
  fi

  # content scan for credential-like patterns on regular files; name only
  note=""
  flags=""
  if [ -f "$abs" ] && grep -IlE 'BEGIN [A-Z ]*PRIVATE KEY|ghp_|ghs_|glpat-|sk-[A-Za-z0-9]|AKIA|AIza' "$abs" >/dev/null 2>&1; then
    note="contains credential-like content"
    flags="--encrypt"
  fi
  if [ -d "$abs" ]; then
    flags="${flags:+$flags }--recursive"
    note="${note:+$note }directory"
  fi

  printf '%s|%s|%s|%s|%s\n' "$t" unmanaged "$(derive_source "$t")" "$flags" "$note"
done < <(chezmoi unmanaged 2>/dev/null)

# ---- managed but edited (deployment-pending) ---------------------------------

while IFS= read -r line; do
  [ -z "$line" ] && continue
  st="${line%% *}"
  t="${line#* }"
  case "$st" in
    '??'|'..'|"") continue ;;
  esac
  abs="$HOME_DIR/$t"
  base="$(basename "$t")"

  # edited files are already managed; get the real source path
  sp="$(chezmoi source-path "$abs" 2>/dev/null)"
  [ -z "$sp" ] && sp="$(derive_source "$t")"
  # relativize against the source repo for readability
  case "$sp" in
    "$SRC/"*) sp="${sp#"$SRC"/}" ;;
  esac

  if reason="$(suspicious_reason "$t" "$base")"; then
    printf '%s|%s|%s|%s|%s\n' "$t" suspicious "$sp" "--encrypt" "$reason"
    continue
  fi
  printf '%s|%s|%s|%s|%s\n' "$t" edited "$sp" "" "re-capture via chezmoi add"
done < <(chezmoi status 2>/dev/null)