#!/bin/bash

set -e

if [[ -f "compile_commands.json" ]]; then
    echo "Removing old compile_commands.json"
    rm compile_commands.json
fi

if [[ -d "build" ]]; then
    echo "Removing old build"
    rm -rf build
fi

cmake -B build .
cd build; make; cd ..;
ln -s ./build/compile_commands.json ./compile_commands.json
