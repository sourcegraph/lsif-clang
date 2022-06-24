#! /bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

export LD_LIBRARY_PATH="$script_dir:${LD_LIBRARY_PATH:-}"

exec -a "lsif-clang" "$script_dir/lsif-clang.bin" "$@"
