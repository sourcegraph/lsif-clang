#!/bin/sh

# Grab backwards-cpp and update
git submodule update --init --recursive

cmake -B build -S . \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
      -DPATH_TO_LLVM=$PATH_TO_LLVM
