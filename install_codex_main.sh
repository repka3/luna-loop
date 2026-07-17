#!/usr/bin/env bash
set -u

if [ "$#" -ne 0 ]; then
  echo "usage: ./install_codex_main.sh"
  exit 64
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)" || exit 2
exec bash "$SCRIPT_DIR/installer/install_driver.sh" codex-main
