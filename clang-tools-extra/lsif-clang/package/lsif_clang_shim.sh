#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

export LD_LIBRARY_PATH="$SCRIPT_DIR:${LD_LIBRARY_PATH:-}"

exec -a "$SCRIPT_DIR/lsif-clang" "$SCRIPT_DIR/lsif-clang.bin" "$@"
