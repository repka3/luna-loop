#!/usr/bin/env bash
# Read-only luna-loop mode detector.
set -u

MARKER=".luna-loop"
RECEIPT_HEADER="luna-loop-receipt-v2"
COMMON_TARGETS="loop-interview loop-spec loop-plan loop-review loop-execute"
CLAUDE_TARGETS="$COMMON_TARGETS codex"
CODEX_TARGETS="$COMMON_TARGETS opus"
ALL_TARGETS="$COMMON_TARGETS codex opus"

if [ "$#" -ne 0 ]; then
  echo "usage: ./who_is_driving.sh"
  exit 64
fi

path_exists() {
  [ -e "$1" ] || [ -L "$1" ]
}

plain_dir() {
  [ -d "$1" ] && [ ! -L "$1" ]
}

plain_file() {
  [ -f "$1" ] && [ ! -L "$1" ]
}

entry_count() {
  local count_dir="$1"
  local count_value=0
  local count_entry
  for count_entry in "$count_dir"/* "$count_dir"/.[!.]* "$count_dir"/..?*; do
    if path_exists "$count_entry"; then
      count_value=$((count_value + 1))
    fi
  done
  printf '%s\n' "$count_value"
}

receipt_text() {
  printf '%s\nmode=%s\nskill=%s\nlayout=%s\n' \
    "$RECEIPT_HEADER" "$1" "$2" "$3"
}

marker_is_current() {
  local target_dir="$1"
  local mode="$2"
  local skill="$3"
  local layout="$4"
  plain_file "$target_dir/$MARKER" || return 1
  [ "$(cat "$target_dir/$MARKER" 2>/dev/null)" = \
    "$(receipt_text "$mode" "$skill" "$layout")" ]
}

claude_target_is_valid() {
  local target_dir="$1"
  local skill="$2"
  plain_dir "$target_dir" || return 1
  [ "$(entry_count "$target_dir")" = "2" ] || return 1
  plain_file "$target_dir/SKILL.md" || return 1
  plain_file "$target_dir/$MARKER" || return 1
  marker_is_current "$target_dir" claude-main "$skill" claude-v1 \
    || [ ! -s "$target_dir/$MARKER" ]
}

codex_target_is_valid() {
  local target_dir="$1"
  local skill="$2"
  plain_dir "$target_dir" || return 1
  [ "$(entry_count "$target_dir")" = "3" ] || return 1
  plain_file "$target_dir/SKILL.md" || return 1
  plain_file "$target_dir/$MARKER" || return 1
  plain_dir "$target_dir/agents" || return 1
  [ "$(entry_count "$target_dir/agents")" = "1" ] || return 1
  plain_file "$target_dir/agents/openai.yaml" || return 1
  marker_is_current "$target_dir" codex-main "$skill" codex-v1
}

inspect_pack() {
  local pack_kind="$1"
  local skills_root="$2"
  local expected_targets="$3"
  local seen=0
  local valid=0
  local invalid=0
  local skill target_path

  if path_exists "$skills_root" && ! plain_dir "$skills_root"; then
    printf '%s\n' inconsistent
    return
  fi

  for skill in $ALL_TARGETS; do
    target_path="$skills_root/$skill"
    if ! path_exists "$target_path"; then
      continue
    fi
    seen=$((seen + 1))
    case " $expected_targets " in
      *" $skill "*)
        if [ "$pack_kind" = claude ]; then
          claude_target_is_valid "$target_path" "$skill" \
            && valid=$((valid + 1)) || invalid=1
        else
          codex_target_is_valid "$target_path" "$skill" \
            && valid=$((valid + 1)) || invalid=1
        fi
        ;;
      *) invalid=1 ;;
    esac
  done

  if [ "$seen" -eq 0 ]; then
    printf '%s\n' empty
  elif [ "$invalid" -eq 0 ] && [ "$valid" -eq 6 ]; then
    printf '%s\n' complete
  else
    printf '%s\n' inconsistent
  fi
}

if [ -z "${HOME:-}" ]; then
  echo "Unable to determine the driver: HOME is unset." >&2
  exit 2
fi
case "$HOME" in
  /*) ;;
  *) echo "Unable to determine the driver: HOME must be absolute." >&2; exit 2 ;;
esac
plain_dir "$HOME" || {
  echo "Unable to determine the driver: HOME is not an ordinary directory." >&2
  exit 2
}

CLAUDE_ROOT="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
case "$CLAUDE_ROOT" in
  /*) ;;
  *)
    echo "Unable to determine the driver: CLAUDE_CONFIG_DIR must be absolute." >&2
    exit 2
    ;;
esac

CLAUDE_STATE="$(inspect_pack claude "$CLAUDE_ROOT/skills" "$CLAUDE_TARGETS")"
CODEX_STATE="$(inspect_pack codex "$HOME/.agents/skills" "$CODEX_TARGETS")"

if [ "$CLAUDE_STATE" = complete ] && [ "$CODEX_STATE" = empty ]; then
  echo "Claude is driving."
  exit 0
fi
if [ "$CLAUDE_STATE" = empty ] && [ "$CODEX_STATE" = complete ]; then
  echo "Codex is driving."
  exit 0
fi
if [ "$CLAUDE_STATE" = empty ] && [ "$CODEX_STATE" = empty ]; then
  echo "Nobody is driving."
  exit 0
fi

echo "Driving state is inconsistent."
echo "Claude pack: $CLAUDE_STATE; Codex pack: $CODEX_STATE." >&2
exit 1
