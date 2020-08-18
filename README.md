# lsif-clang indexer ![](https://img.shields.io/badge/status-development-yellow?style=flat)

This project is a fork of [clangd](https://clangd.llvm.org/) with patches to add support for outputting [LSIF indexes](https://microsoft.github.io/language-server-protocol/specifications/lsif/0.5.0/specification/). Specifically, a fork of the `clang-tools-extra/clangd` subdirectory of the [llvm-project repo](https://github.com/llvm/llvm-project/).

This project has only been tested extensively on C++ projects, but C and Objective C projects should both be supported as well following the same instructions.

# Installation

## Dependencies

This project depends on LLVM and Clang. The code builds against LLVM and Clang version 10, but can index a wide variety of code. Please file an issue if you need to build against a different version of LLVM or Clang and we can start adding some version pragmas! You can try finding the location of your llvm installation by running `readlink -f $(which clang)`. On my computer, this returns `/usr/lib/llvm-10/bin/clang`, so the installation path is `/usr/lib/llvm-10`.

## Building
The project builds with CMake, so if you know what you're doing you can configure it yourself. For sensible defaults:
```sh
PATH_TO_LLVM=<path> ./config.sh build
cd build
make -j8
sudo make install
```
`PATH_TO_LLVM` should point to the llvm installation path from the previous step. The `8` in `make -j8` should be the number of threads you wish to allocate to the build (it's fairly small so it shouldn't matter much, but `make` is single threaded by default).

## Give it a whirl!

Assuming you followed the steps above, do the following from this project's root directory:
```sh
ln -s $(pwd)/build/compile_commands.json ./
lsif-clang --project-root=$(pwd) --executor=all-TUs compile_commands.json > dump.lsif
```
Inspect the file when it's done, you should see lots of glorious JSON!

# Usage

## Compilation Database

The tool depends on having a [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html) available, which is generated differently depending on what build system is in use. Please get in touch if you're having trouble generating a compilation database, we'd be happy to help troubleshoot!

### CMake

Add `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` to your `cmake` invocation. The database will get generated in your build directory, so you should symlink it to the source root.

### Make and others

Install the [Bear](https://github.com/rizsotto/Bear) tool and run `bear make`, or `bear <your-build-command>`. This tool is build system agnostic so it's a good fallback option.

### Bazel

Use the [bazel-compilation-database](https://github.com/grailbio/bazel-compilation-database) tool.

## Indexing

Once you have `compile_commands.json` at the root of your source tree, you can invoke `lsif-clang` like so:
```sh
lsif-clang --project-root=$(pwd) --executor=all-TUs compile_commands.json > dump.lsif
```

This will index the entire project. To index only some files, run:
```sh
lsif-clang --project-root=$(pwd) file1.cpp file2.cpp ... > dump.lsif
```

Note that this will still include lots of data about other files to properly supply hovers and such.

# Alternatives for C++ Projects

If you can't get `lsif-clang` working with your project, first file an issue! We want this to work everywhere. But the C++ ecosystem is fragmented, and it's possible that your project simply won't play nice with the `clang` toolchain. [lsif-cpp](https://github.com/sourcegraph/lsif-cpp) is also available, which acts as a plugin for arbitrary C++ compilers and might therefore be compatible. But it has several major defects compared to `lsif-clang` (it is much slower and does not provide hovers), and is not the recommended option.
