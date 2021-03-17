#!/bin/bash

# Probably should install stuff...

set -e

if [[ ! -f "compile_commands.json" ]]; then
    if [[ -d "neovim/build" ]]; then
        echo "Removing old build"
        rm -rf neovim/build
    fi

    cd neovim/; make; cd ..;

    # TODO: What is the difference between -s
    ln ./neovim/build/compile_commands.json ./compile_commands.json
fi

