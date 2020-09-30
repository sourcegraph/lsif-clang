# lsif-clang indexer ![](https://img.shields.io/badge/status-development-yellow?style=flat)

This project is a fork of [clangd](https://clangd.llvm.org/) with patches to add support for outputting [LSIF indexes](https://microsoft.github.io/language-server-protocol/specifications/lsif/0.5.0/specification/). Specifically, a fork of the `clang-tools-extra/clangd` subdirectory of the [llvm-project repo](https://github.com/llvm/llvm-project/).

This project has only been tested extensively on C++ projects, but C and Objective C projects should both be supported as well following the same instructions.

# Alternatives for C++ Projects

If you can't get `lsif-clang` working with your project, first file an issue! We want this to work everywhere. 
But the C++ ecosystem is fragmented, and it's possible that your project simply won't play nice with the `clang` toolchain. 
[lsif-cpp](https://github.com/sourcegraph/lsif-cpp) is also available, which acts as a plugin for arbitrary C++ compilers and might therefore be compatible. 
But it has several major defects compared to `lsif-clang` (it is much slower and does not provide hovers), and is not the recommended option.

# Usage

There are 4 steps, and instructions for each can vary by platform and build system.

1. Install dependencies
1. Build lsif-clang
1. Generate a compilation database.
1. Run lsif-clang.

## Quick example
Here's how you would build an index of the lsif-clang tool on Ubuntu 20.04.

```sh
apt install llvm-10 clang clang-10 libclang-10-dev cmake  `# install dependencies`
git clone https://github.com/sourcegraph/lsif-clang       `# get the code`
cd lsif-clang
cmake -B build                                            `# configure lsif-clang`
make -C build -j16 install                                `# build and install lsif-clang` 
ln -s $(pwd)/build/compile_commands.json ./               `# link the compilation database to the project root`
lsif-clang compile_commands.json > dump.lsif              `# generate an index`
```

The following sections provide detailed explanations of each step and variations on the commands for different platforms and build systems.

## Install dependencies

This project depends on LLVM and Clang. lsif-clang itself should be built against LLVM and Clang version 10, and can index any code Clang 10 can compile. Work is ongoing to compile against other versions of LLVM. Here are instructions to get the dependencies on a few platforms:

### Ubuntu (20.04)

```sh
apt install llvm-10 clang clang-10 libclang-10-dev cmake
```

#### Older versions of Ubuntu

CMake version 3.16 or later is required (we've tested with CMake version 3.18.0). On older versions
of Ubuntu, `apt` may not install a recent enough version of CMake. You can install CMake manually
following the instructions here: https://cmake.org/download. We've tested this works on Ubuntu
18.04. On even older versions of Ubuntu, you may have to manually install other dependencies if they
don't exist in the `apt` package repository.

### MacOS

```sh
brew install llvm cmake
```

## Build lsif-clang
Here is a minimal example, known extra steps for specific platforms follow:

```sh
cmake -B build
make -C build -j16 install
```

### MacOS
Add the following extra argument to the `cmake` step:
```sh
cmake -B build -DPATH_TO_LLVM=/usr/local/opt/lib
```

## Generate a compilation database

`lsif-clang` itself is configured to do this automatically, so to test the that the tool built properly you can simply sym-link it to the project root from the build directory and skip to [running lsif-clang](#run-lsif-clang).

From the project root:
```sh
ln -s $(pwd)/build/compile_commands.json ./
```

Instructions for generating this compilation database for various build systems follows:

### CMake

If a project builds with CMake, you can ensure that a compilation database is generated in the build directory with the following flag:
```sh
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

For some projects, we've noticed that CMake generates a faulty database, but that the actual build step can output more sensible values. The Ninja build tool provides a convenient mechanism for this. Assuming Ninja is installed:

```sh
cmake <normal args> -G Ninja
cd <build dir>
ninja -t compdb > compile_commands.json
```

This database will also contain irrelevant entries which will make lsif-clang output quite noisy but still functional. To filter the irrelevant entries, inspect the `compile_commands.json` and find an entry for an actual c++ compile command. Here's an example for me:
```json
 {
  "directory": "/home/arrow/sourcegraph/lsif-clang/build2",
  "command": "/usr/bin/c++   -I../ -I/usr/lib/llvm-10/include    -std=gnu++17 -o CMakeFiles/clangDaemonFork.dir/AST.cpp.o -c /home/arrow/sourcegraph/lsif-clang/AST.cpp",
  "file": "/home/arrow/sourcegraph/lsif-clang/AST.cpp"
}
```

I can then use the "command" value of `/usr/bin/c++` in the following jq snippet:
```sh
ninja -t compdb | jq '[ .[] | select(.command | startswith("/usr/bin/c++")) ] > compile_commands.json'
```

### Bazel

Use the [bazel-compilation-database](https://github.com/grailbio/bazel-compilation-database) tool.

### If all else fails

Install the [Bear](https://github.com/rizsotto/Bear) tool and run `bear make`, or `bear <your-build-command>`. This will intercept the actual commands used to build your project and generate a compilation database from them. This is a last resort as it requires you to compile your entire project from scratch before compiling it a second time with `lsif-clang`, which can take quite a while.

## Run lsif-clang

Once you have a `compile_commands.json` in the root of your project's source, you can use the following command to index the entire project:

```sh
lsif-clang compile_commands.json > dump.lsif
```

To index individual files, use:

```sh
lsif-clang file1.cpp file2.cpp ... > dump.lsif
```

### MacOS

The indexer may fail to find system header files on MacOS (and possibly other systems) resulting in console error messages such as `fatal error: stdarg.h not found`.

A workaround is to supply clang arguments via `--extra-arg`, which will be passed to each of the underlying translation unit compile commands. For example:`

```bash
$ clang -print-resource-dir
/Library/Developer/CommandLineTools/usr/lib/clang/11.0.3

$ lsif-clang \
  --extra-arg='-resource-dir=/Library/Developer/CommandLineTools/usr/lib/clang/11.0.3' \
  compile_commands.json > dump.lsif
```

## Test the output

You can use the [lsif-validate](https://github.com/sourcegraph/lsif-test) tool for basic sanity checking, or [upload the index to a Sourcegraph instance](https://docs.sourcegraph.com/user/code_intelligence/lsif_quickstart) to see the hovers, definitions, and references in action.
