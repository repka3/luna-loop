#!/usr/bin/env bash
# Remove receipt-backed current or retired Codex-main luna-loop skills.
set -u

TARGETS="loop-ledger loop-behavior loop-interview loop-spec loop-plan loop-review loop-execute opus"
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
  echo "usage: ./uninstall_codex_main.sh" >&2
  exit 64
fi
[ -n "${HOME:-}" ] || { echo "luna-loop: HOME is unset" >&2; exit 2; }
case "$HOME" in
  /*) ;;
  *) echo "luna-loop: HOME must be absolute: $HOME" >&2; exit 2 ;;
esac
SKILLS_ROOT="$HOME/.agents/skills"

if ! path_exists "$SKILLS_ROOT"; then
  echo "Codex-main luna-loop pack is not installed."
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
  echo "Codex-main luna-loop pack is not installed."
  exit 0
fi

for skill in $TARGETS; do
  target="$SKILLS_ROOT/$skill"
  if path_exists "$target"; then
    rm "$target/SKILL.md" || exit 2
    rm "$target/agents/openai.yaml" || exit 2
    rmdir "$target/agents" || exit 2
    rm "$target/$MARKER" || exit 2
    rmdir "$target" || exit 2
  fi
done

echo "Codex-main luna-loop pack uninstalled from $SKILLS_ROOT"
