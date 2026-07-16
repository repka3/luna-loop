#!/usr/bin/env bash
# luna-loop installer — copies five skills into $CLAUDE_CONFIG_DIR/skills,
# plugin-style. No links, no state files, no network, no codex commands.
# Reads nothing outside this repo and the skills dir.
# Exit codes: 0 ok · 1 conflict (nothing installed) ·
#             2 codex missing or copy failure · 64 bad arg
set -u

REPO="$(cd "$(dirname "$0")" && pwd -P)"
SKILLS_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
TARGETS="loop-interview loop-spec loop-plan loop-review codex"
MARKER=".luna-loop"

[ "$#" -gt 0 ] && { echo "usage: ./install.sh"; exit 64; }

# codex either resolves as a command, or it's game over.
if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI not found on PATH. This pack drives codex; install it and log in first."
  exit 2
fi

# ours = a plain directory carrying the marker this installer drops on success
ours() { [ -d "$1" ] && [ ! -L "$1" ] && [ -f "$1/$MARKER" ]; }

# pre-flight: anything at a target path that is not ours aborts everything
conflicts=0
for t in $TARGETS; do
  dest="$SKILLS_DIR/$t"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if ! ours "$dest"; then
      if [ -L "$dest" ]; then kind="symlink -> $(readlink "$dest")"
      elif [ -d "$dest" ]; then kind="dir"
      else kind="file"; fi
      echo "conflict skills/$t -> $dest (existing: $kind)"
      conflicts=1
    fi
  fi
done
if [ "$conflicts" -eq 1 ]; then
  echo "Nothing installed. Resolve the conflicts above (your files, your call) and rerun."
  exit 1
fi

# install: delete ours, copy fresh, validate, then drop the marker as a receipt
mkdir -p "$SKILLS_DIR"
fail=0
for t in $TARGETS; do
  dest="$SKILLS_DIR/$t"
  ours "$dest" && rm -rf "$dest"
  if cp -R "$REPO/skills/$t" "$dest" 2>/dev/null && [ -f "$dest/SKILL.md" ]; then
    : > "$dest/$MARKER"
    echo "installed skills/$t -> $dest"
  else
    rm -rf "$dest" 2>/dev/null
    echo "failed skills/$t -> $dest"
    fail=1
  fi
done

echo "Of course, codex dispatches follow your machine's own AGENTS.md and codex config — your rules, not this pack's."
[ "$fail" -eq 1 ] && exit 2
exit 0
