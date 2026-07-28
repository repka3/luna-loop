#!/usr/bin/env bash
# Best-effort, read-only inspection of installed Luna Loop packs.
set -u

MARKER=".luna-loop"
CLAUDE_TARGETS="luna-loop loop-spec loop-plan loop-review loop-execute codex"
RETIRED_CLAUDE_TARGETS="loop-interview loop-spec loop-plan loop-review loop-execute codex"
CLAUDE_MANAGED_TARGETS="luna-loop loop-interview loop-spec loop-plan loop-review loop-execute codex"
CODEX_TARGETS="luna-loop opus"
RETIRED_ADAPTIVE_CODEX_TARGETS="loop opus"
PREVIOUS_CODEX_TARGETS="loop-ledger loop-behavior loop-plan loop-review loop-execute opus"
LEGACY_CODEX_TARGETS="loop-interview loop-spec loop-plan loop-review loop-execute opus"
CODEX_MANAGED_TARGETS="luna-loop loop loop-ledger loop-behavior loop-interview loop-spec loop-plan loop-review loop-execute opus"

if [ "$#" -ne 0 ]; then
  echo "usage: ./whats_installed.sh" >&2
  exit 64
fi

path_exists() { [ -e "$1" ] || [ -L "$1" ]; }
plain_dir() { [ -d "$1" ] && [ ! -L "$1" ]; }
plain_file() { [ -f "$1" ] && [ ! -L "$1" ]; }

entry_count() {
  local dir="$1" count=0 entry
  for entry in "$dir"/* "$dir"/.[!.]* "$dir"/..?*; do
    path_exists "$entry" && count=$((count + 1))
  done
  printf '%s\n' "$count"
}

receipt_text() {
  local mode="$1" skill="$2" layout="$3"
  printf 'luna-loop-receipt-v2\nmode=%s\nskill=%s\nlayout=%s\n' "$mode" "$skill" "$layout"
}

claude_target_valid() {
  local dir="$1" skill="$2"
  plain_dir "$dir" || return 1
  [ "$(entry_count "$dir")" = 2 ] || return 1
  plain_file "$dir/SKILL.md" || return 1
  plain_file "$dir/$MARKER" || return 1
  [ ! -s "$dir/$MARKER" ] ||
    [ "$(cat "$dir/$MARKER" 2>/dev/null)" = "$(receipt_text claude-main "$skill" claude-v1)" ]
}

codex_target_valid() {
  local dir="$1" skill="$2" layout="$3"
  plain_dir "$dir" || return 1
  [ "$(entry_count "$dir")" = 3 ] || return 1
  plain_file "$dir/SKILL.md" || return 1
  plain_file "$dir/$MARKER" || return 1
  plain_dir "$dir/agents" || return 1
  [ "$(entry_count "$dir/agents")" = 1 ] || return 1
  plain_file "$dir/agents/openai.yaml" || return 1
  [ "$(cat "$dir/$MARKER" 2>/dev/null)" = "$(receipt_text codex-main "$skill" "$layout")" ]
}

claude_set_complete() {
  local root="$1" targets="$2" skill
  for skill in $targets; do
    claude_target_valid "$root/$skill" "$skill" || return 1
  done
}

claude_state() {
  local root="$1" seen=0 skill target
  if path_exists "$root" && ! plain_dir "$root"; then
    printf '%s\n' inconsistent
    return
  fi
  for skill in $CLAUDE_MANAGED_TARGETS; do
    target="$root/$skill"
    path_exists "$target" && seen=$((seen + 1))
  done
  if [ "$seen" -eq 0 ]; then
    printf '%s\n' empty
  elif [ "$seen" -eq 6 ] && claude_set_complete "$root" "$CLAUDE_TARGETS"; then
    printf '%s\n' complete
  elif [ "$seen" -eq 6 ] && claude_set_complete "$root" "$RETIRED_CLAUDE_TARGETS"; then
    printf '%s\n' retired
  else
    printf '%s\n' inconsistent
  fi
}

codex_set_complete() {
  local root="$1" targets="$2" layout="$3" skill
  for skill in $targets; do
    codex_target_valid "$root/$skill" "$skill" "$layout" || return 1
  done
}

codex_state() {
  local root="$1" seen=0 skill target
  if path_exists "$root" && ! plain_dir "$root"; then
    printf '%s\n' inconsistent
    return
  fi
  for skill in $CODEX_MANAGED_TARGETS; do
    target="$root/$skill"
    path_exists "$target" && seen=$((seen + 1))
  done
  if [ "$seen" -eq 0 ]; then
    printf '%s\n' empty
  elif [ "$seen" -eq 2 ] && codex_set_complete "$root" "$CODEX_TARGETS" codex-v2; then
    printf '%s\n' complete
  elif [ "$seen" -eq 2 ] &&
       codex_set_complete "$root" "$RETIRED_ADAPTIVE_CODEX_TARGETS" codex-v1; then
    printf '%s\n' retired
  elif [ "$seen" -eq 6 ] &&
       codex_set_complete "$root" "$PREVIOUS_CODEX_TARGETS" codex-v1; then
    printf '%s\n' retired
  elif [ "$seen" -eq 6 ] &&
       codex_set_complete "$root" "$LEGACY_CODEX_TARGETS" codex-v1; then
    printf '%s\n' retired
  else
    printf '%s\n' inconsistent
  fi
}

[ -n "${HOME:-}" ] || { echo "Unable to inspect luna-loop: HOME is unset." >&2; exit 2; }
case "$HOME" in
  /*) ;;
  *) echo "Unable to inspect luna-loop: HOME must be absolute." >&2; exit 2 ;;
esac

CLAUDE_ROOT="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
CODEX_ROOT="$HOME/.agents/skills"
CLAUDE_STATE="$(claude_state "$CLAUDE_ROOT")"
CODEX_STATE="$(codex_state "$CODEX_ROOT")"

report_pack() {
  local label="$1" state="$2"
  case "$state" in
    complete)
      printf 'Luna Loop %s pack: installed.\n' "$label"
      ;;
    retired)
      printf 'Luna Loop %s pack: retired; reinstall recommended.\n' "$label"
      ;;
    empty)
      printf 'Luna Loop %s pack: not installed.\n' "$label"
      ;;
    inconsistent)
      printf 'Luna Loop %s pack: incomplete or modified.\n' "$label"
      ;;
  esac
}

report_pack Claude "$CLAUDE_STATE"
report_pack Codex "$CODEX_STATE"

if [ "$CLAUDE_STATE" = inconsistent ] || [ "$CODEX_STATE" = inconsistent ]; then
  exit 1
fi
exit 0
