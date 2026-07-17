#!/usr/bin/env bash
# Deliberately non-mutating: choosing the main driver is required.
set -u

if [ "$#" -ne 0 ]; then
  echo "usage: ./install.sh"
  exit 64
fi

cat <<'EOF'
luna-loop now supports two mutually exclusive driver modes.

Choose one explicitly:
  ./install_claude_main.sh  # Claude drives; Codex reviews/executes
  ./install_codex_main.sh   # Codex drives; Opus reviews/researches

Nothing was changed.
EOF
exit 64
