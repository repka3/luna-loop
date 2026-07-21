#!/usr/bin/env bash
# Install or refresh only the Claude-main luna-loop pack.
set -u

TARGETS="loop-interview loop-spec loop-plan loop-review loop-execute codex"
MARKER=".luna-loop"

fail() {
  echo "luna-loop: $*" >&2
  exit 2
}

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
  echo "usage: ./install_claude_main.sh" >&2
  exit 64
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)" || exit 2
SOURCE_ROOT="$SCRIPT_DIR/claude_main_driver/skills"
CLAUDE_ROOT="${CLAUDE_CONFIG_DIR:-${HOME:-}/.claude}"

case "$CLAUDE_ROOT" in
  /*) ;;
  *) fail "Claude config root must be absolute: $CLAUDE_ROOT" ;;
esac
plain_dir "$CLAUDE_ROOT" || fail "Claude config root is not an ordinary directory: $CLAUDE_ROOT"
plain_dir "$SOURCE_ROOT" || fail "Missing source skill directory: $SOURCE_ROOT"

SKILLS_ROOT="$CLAUDE_ROOT/skills"
if path_exists "$SKILLS_ROOT" && ! plain_dir "$SKILLS_ROOT"; then
  fail "Claude skills root is not an ordinary directory: $SKILLS_ROOT"
fi

# Prove every source and destination before changing anything.
for skill in $TARGETS; do
  source_dir="$SOURCE_ROOT/$skill"
  plain_dir "$source_dir" || fail "Missing source skill: $source_dir"
  [ "$(entry_count "$source_dir")" = 1 ] || fail "Unexpected source layout: $source_dir"
  plain_file "$source_dir/SKILL.md" || fail "Missing source SKILL.md: $source_dir"
  grep -Eq "^name:[[:space:]]*$skill[[:space:]]*$" "$source_dir/SKILL.md" \
    || fail "Source skill name does not match directory: $source_dir"

  destination="$SKILLS_ROOT/$skill"
  if path_exists "$destination" && ! owned_target "$destination" "$skill"; then
    echo "luna-loop: refusing foreign or modified destination: $destination" >&2
    exit 1
  fi
done

if [ ! -d "$SKILLS_ROOT" ]; then
  mkdir "$SKILLS_ROOT" || fail "Cannot create Claude skills root: $SKILLS_ROOT"
fi

for skill in $TARGETS; do
  destination="$SKILLS_ROOT/$skill"
  if [ ! -d "$destination" ]; then
    mkdir "$destination" || fail "Cannot create destination: $destination"
  fi
  cp "$SOURCE_ROOT/$skill/SKILL.md" "$destination/SKILL.md" \
    || fail "Cannot install $skill"
  receipt_text "$skill" > "$destination/$MARKER" \
    || fail "Cannot write ownership receipt for $skill"
  owned_target "$destination" "$skill" || fail "Installed skill did not validate: $destination"
done

echo "Claude-main luna-loop pack installed in $SKILLS_ROOT"
echo "This command does not remove the Codex pack."
