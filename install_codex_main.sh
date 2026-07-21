#!/usr/bin/env bash
# Install or refresh only the Codex-main luna-loop pack.
set -u

TARGETS="loop-ledger loop-behavior loop-plan loop-review loop-execute opus"
RETIRED_TARGETS="loop-interview loop-spec"
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
  printf 'luna-loop-receipt-v2\nmode=codex-main\nskill=%s\nlayout=codex-v1\n' "$1"
}

owned_target() {
  local dir="$1" skill="$2"
  plain_dir "$dir" || return 1
  [ "$(entry_count "$dir")" = 3 ] || return 1
  plain_file "$dir/SKILL.md" || return 1
  plain_file "$dir/$MARKER" || return 1
  plain_dir "$dir/agents" || return 1
  [ "$(entry_count "$dir/agents")" = 1 ] || return 1
  plain_file "$dir/agents/openai.yaml" || return 1
  [ "$(cat "$dir/$MARKER" 2>/dev/null)" = "$(receipt_text "$skill")" ]
}

if [ "$#" -ne 0 ]; then
  echo "usage: ./install_codex_main.sh" >&2
  exit 64
fi

[ -n "${HOME:-}" ] || fail "HOME is unset"
case "$HOME" in
  /*) ;;
  *) fail "HOME must be absolute: $HOME" ;;
esac
plain_dir "$HOME" || fail "HOME is not an ordinary directory: $HOME"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)" || exit 2
SOURCE_ROOT="$SCRIPT_DIR/codex_main_driver/skills"
AGENTS_ROOT="$HOME/.agents"
SKILLS_ROOT="$AGENTS_ROOT/skills"
plain_dir "$SOURCE_ROOT" || fail "Missing source skill directory: $SOURCE_ROOT"

for checked in "$AGENTS_ROOT" "$SKILLS_ROOT"; do
  if path_exists "$checked" && ! plain_dir "$checked"; then
    fail "Expected an ordinary directory: $checked"
  fi
done

# The renamed pack is an explicit migration: uninstall the old pack first.
for skill in $RETIRED_TARGETS; do
  destination="$SKILLS_ROOT/$skill"
  if path_exists "$destination"; then
    if owned_target "$destination" "$skill"; then
      echo "luna-loop: retired Codex skill detected: $destination" >&2
      echo "Run ./uninstall_codex_main.sh, then rerun this installer." >&2
      exit 1
    fi
    echo "luna-loop: refusing foreign destination: $destination" >&2
    exit 1
  fi
done

# Prove every source and destination before changing anything.
for skill in $TARGETS; do
  source_dir="$SOURCE_ROOT/$skill"
  plain_dir "$source_dir" || fail "Missing source skill: $source_dir"
  [ "$(entry_count "$source_dir")" = 2 ] || fail "Unexpected source layout: $source_dir"
  plain_file "$source_dir/SKILL.md" || fail "Missing source SKILL.md: $source_dir"
  plain_dir "$source_dir/agents" || fail "Missing source agents directory: $source_dir"
  [ "$(entry_count "$source_dir/agents")" = 1 ] || fail "Unexpected source agents layout: $source_dir"
  plain_file "$source_dir/agents/openai.yaml" || fail "Missing source openai.yaml: $source_dir"
  grep -Eq "^name:[[:space:]]*$skill[[:space:]]*$" "$source_dir/SKILL.md" \
    || fail "Source skill name does not match directory: $source_dir"

  destination="$SKILLS_ROOT/$skill"
  if path_exists "$destination" && ! owned_target "$destination" "$skill"; then
    echo "luna-loop: refusing foreign or modified destination: $destination" >&2
    exit 1
  fi
done

if [ ! -d "$AGENTS_ROOT" ]; then
  mkdir "$AGENTS_ROOT" || fail "Cannot create Codex user-data root: $AGENTS_ROOT"
fi
if [ ! -d "$SKILLS_ROOT" ]; then
  mkdir "$SKILLS_ROOT" || fail "Cannot create Codex skills root: $SKILLS_ROOT"
fi

for skill in $TARGETS; do
  destination="$SKILLS_ROOT/$skill"
  if [ ! -d "$destination" ]; then
    mkdir "$destination" || fail "Cannot create destination: $destination"
    mkdir "$destination/agents" || fail "Cannot create agents directory: $destination/agents"
  fi
  cp "$SOURCE_ROOT/$skill/SKILL.md" "$destination/SKILL.md" \
    || fail "Cannot install $skill"
  cp "$SOURCE_ROOT/$skill/agents/openai.yaml" "$destination/agents/openai.yaml" \
    || fail "Cannot install $skill metadata"
  receipt_text "$skill" > "$destination/$MARKER" \
    || fail "Cannot write ownership receipt for $skill"
  owned_target "$destination" "$skill" || fail "Installed skill did not validate: $destination"
done

echo "Codex-main luna-loop pack installed in $SKILLS_ROOT"
echo "This command does not remove the Claude pack."
