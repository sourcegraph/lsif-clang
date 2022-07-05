#! /bin/bash

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "usage: <binary> <output>"
    exit 1
fi

binary="$1"
output="$2"

for lib in $(ldd "$binary" | cut -d ">" -f 2 | awk '{print $1}' | grep -vE "(linux-vdso\.|ld-linux-x86-64\.|libc\.)"); do
    cp --verbose "$lib" "$output/"
done
