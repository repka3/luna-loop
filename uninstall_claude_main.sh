#!/usr/bin/env bash
# Remove only receipt-backed Claude-main luna-loop skills.
set -u

TARGETS="loop-interview loop-spec loop-plan loop-review loop-execute codex"
MARKER=".luna-loop"

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
  printf 'luna-loop-receipt-v2\nmode=claude-main\nskill=%s\nlayout=claude-v1\n' "$1"
}

owned_target() {
  local dir="$1" skill="$2"
  plain_dir "$dir" || return 1
  [ "$(entry_count "$dir")" = 2 ] || return 1
  plain_file "$dir/SKILL.md" || return 1
  plain_file "$dir/$MARKER" || return 1
  [ ! -s "$dir/$MARKER" ] ||
    [ "$(cat "$dir/$MARKER" 2>/dev/null)" = "$(receipt_text "$skill")" ]
}

if [ "$#" -ne 0 ]; then
  echo "usage: ./uninstall_claude_main.sh" >&2
  exit 64
fi

CLAUDE_ROOT="${CLAUDE_CONFIG_DIR:-${HOME:-}/.claude}"
case "$CLAUDE_ROOT" in
  /*) ;;
  *) echo "luna-loop: Claude config root must be absolute: $CLAUDE_ROOT" >&2; exit 2 ;;
esac
SKILLS_ROOT="$CLAUDE_ROOT/skills"

if ! path_exists "$SKILLS_ROOT"; then
  echo "Claude-main luna-loop pack is not installed."
  exit 0
fi
plain_dir "$SKILLS_ROOT" || { echo "luna-loop: invalid skills root: $SKILLS_ROOT" >&2; exit 2; }

# Refuse the whole uninstall before deleting anything if one managed name is foreign.
found=0
for skill in $TARGETS; do
  target="$SKILLS_ROOT/$skill"
  if path_exists "$target"; then
    found=1
    owned_target "$target" "$skill" || {
      echo "luna-loop: refusing foreign or modified target: $target" >&2
      exit 1
    }
  fi
done

if [ "$found" -eq 0 ]; then
  echo "Claude-main luna-loop pack is not installed."
  exit 0
fi

for skill in $TARGETS; do
  target="$SKILLS_ROOT/$skill"
  if path_exists "$target"; then
    rm "$target/SKILL.md" || exit 2
    rm "$target/$MARKER" || exit 2
    rmdir "$target" || exit 2
  fi
done

echo "Claude-main luna-loop pack uninstalled from $SKILLS_ROOT"
