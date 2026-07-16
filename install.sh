#!/usr/bin/env bash
# luna-loop installer — copies six skills into $CLAUDE_CONFIG_DIR/skills,
# plugin-style. No links, no state files, no network, no codex commands, and
# no recursive deletion: removal is "the two files we wrote, then rmdir",
# which refuses to touch anything we didn't put there.
# Exit codes: 0 ok · 1 conflict (nothing installed) ·
#             2 codex missing, bad environment, or copy failure · 64 bad arg
set -u

REPO="$(cd "$(dirname "$0")" && pwd -P)"
TARGETS="loop-interview loop-spec loop-plan loop-review loop-execute codex"
MARKER=".luna-loop"

[ "$#" -gt 0 ] && { echo "usage: ./install.sh"; exit 64; }

# --- environment gates: fail loud and early, create nothing -------------------
if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI not found on PATH. This pack drives codex; install it and log in first."
  exit 2
fi
if [ -z "${CLAUDE_CONFIG_DIR:-}" ] && [ -z "${HOME:-}" ]; then
  echo "Neither CLAUDE_CONFIG_DIR nor HOME is set — cannot locate the skills directory."
  exit 2
fi
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME:-}/.claude}"
case "$CLAUDE_DIR" in
  /*) ;;
  *) echo "CLAUDE_CONFIG_DIR must be an absolute path: $CLAUDE_DIR"; exit 2 ;;
esac
if [ ! -d "$CLAUDE_DIR" ]; then
  echo "No Claude config directory at $CLAUDE_DIR — is Claude Code installed here? (Set CLAUDE_CONFIG_DIR if it lives elsewhere.)"
  exit 2
fi
SKILLS_DIR="$CLAUDE_DIR/skills"

# ours = a plain directory carrying the marker this installer drops on success
ours() { [ -d "$1" ] && [ ! -L "$1" ] && [ -f "$1/$MARKER" ]; }

# removes exactly the two files this pack writes, then the empty directory —
# rmdir refuses a non-empty dir, so anything the user put inside survives
remove_ours() {
  rm -f "$1/SKILL.md" "$1/$MARKER" 2>/dev/null
  rmdir "$1" 2>/dev/null
}

# --- pre-flight: any foreign target aborts everything -------------------------
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

# --- install: remove ours, copy fresh, validate, marker last as a receipt -----
mkdir -p "$SKILLS_DIR"
fail=0
for t in $TARGETS; do
  dest="$SKILLS_DIR/$t"
  if [ -L "$dest" ]; then
    echo "failed skills/$t -> $dest (unexpected symlink)"
    fail=1
    continue
  fi
  # pre-flight guaranteed anything still here is ours
  if [ -e "$dest" ]; then remove_ours "$dest"; fi
  if [ -e "$dest" ]; then
    echo "failed skills/$t -> $dest (previous copy not removable — does it contain files that are not ours?)"
    fail=1
    continue
  fi
  if cp -R "$REPO/skills/$t" "$dest" 2>/dev/null \
     && [ -f "$dest/SKILL.md" ] && [ -r "$dest/SKILL.md" ] \
     && : > "$dest/$MARKER" 2>/dev/null; then
    echo "installed skills/$t -> $dest"
  else
    remove_ours "$dest"
    echo "failed skills/$t -> $dest"
    fail=1
  fi
done

echo "Of course, codex dispatches follow your machine's own AGENTS.md and codex config — your rules, not this pack's."
[ "$fail" -eq 1 ] && exit 2
exit 0
