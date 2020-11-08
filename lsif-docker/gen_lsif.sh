#!/bin/bash

set -eux
cd /source

if [ -f ./compile_commands.json ]; then
    lsif-clang compile_commands.json
else
    echo 'compile_commands.json not found (maybe it was written to a different directory?)'
    exit 1
fi
