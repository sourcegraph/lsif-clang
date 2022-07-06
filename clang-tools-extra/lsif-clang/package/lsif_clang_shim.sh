#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(pwd)"

export LD_LIBRARY_PATH="$SCRIPT_DIR:${LD_LIBRARY_PATH:-}"

exec -a "lsif-clang" "$SCRIPT_DIR/lsif-clang.bin" "$@"

