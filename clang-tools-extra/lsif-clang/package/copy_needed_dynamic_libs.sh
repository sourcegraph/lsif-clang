#! /bin/bash

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "usage: <binary> <output>"
    exit 1
fi

BINARY="$1"
OUTPUT="$2"

# Copy the dynamic libraries linked in by the binary,
# except for system(-ish) libraries, like libc,
# librt, and libpthread.
#
# This means that modifying LD_LIBRARY_PATH later
# while linking against different system libraries
# should work so long as:
# 1. We originally linked against "old enough" system libraries:
#    This is ensured by using Ubuntu 18.04 for the build.
# 2. The system libraries maintained backwards compatibility.
#    (It seems OK to roll with this assumption. We've manually
#     verified it for Ubuntu 18.04 -> Ubuntu 20.04)
DYN_LIBS="$(ldd "$BINARY")"
echo "Dynamic libraries linked by lsif-clang:"
echo "$DYN_LIBS"
for LIB in $(echo "$DYN_LIBS" | cut -d ">" -f 2 | awk '{print $1}' | grep -vE "(linux-vdso\.|ld-linux-x86-64\.|libc\.|librt\.|libpthread\.)"); do
    cp --verbose "$LIB" "$OUTPUT/"
done
