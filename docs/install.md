# Prerequisites

This project depends on LLVM and Clang. lsif-clang itself should be built against LLVM and Clang version 10, and can index any code Clang 10 can compile.

### Ubuntu (20.04)

```sh
apt install llvm-10 clang clang-10 libclang-10-dev cmake binutils-dev
```

#### Older versions of Ubuntu

CMake version 3.16 or later is required (we've tested with CMake version 3.18.0). On older versions
of Ubuntu, `apt` may not install a recent enough version of CMake. You can install CMake manually
following the instructions here: https://cmake.org/download. We've tested this works on Ubuntu
18.04. On even older versions of Ubuntu, you may have to manually install other dependencies if they
don't exist in the `apt` package repository.

### MacOS

```sh
brew install cmake sourcegraph/brew/llvm@10 binutils
```

> Note: lsif-clang must currently be built using LLVM 10

# Installation

Make sure to checkout any submodules, either with `git clone --recurse-submodules ...` or `git submodule update --init --recursive`

### Ubuntu

```sh
cmake -B build
make -C build -j8  # the -j argument sets the parallelism level
sudo make -C build install
```

### MacOS

```sh
Clang_DIR=/usr/local/opt/llvm\@10/lib/cmake/clang cmake -B build -DPATH_TO_LLVM=/usr/local/opt/llvm\@10
make -C build -j8  # the -j argument sets the parallelism level
sudo make -C build install
```

Immediately after installing, you should run `lsif-clang`. If you encounter an error like "libLLVM.dylib cannot be opened because the developer cannot be verified", open **System Preferences > Security & Privacy > General** and click **Open Anyway** next to the message "libLLVM.dylib was blocked from use because it is not from an identified developer". Run `lsif-clang` again and click the **Open** button in the system dialog that pops up.

If you did not install LLVM 10 with Homebrew, you may need to modify the values of `Clang_DIR` and
`-DPATH_TO_LLVM`. If you encounter the following error:

```
Could not find a package configuration file provided by "Clang" with any of the following names:

	ClangConfig.cmake
	clang-config.cmake
```

then, do the following:

1. Find the path to `ClangConfig.cmake`:

   ```
   find /usr/ -name ClangConfig.cmake
   ```

1. Set the *containing directory* of the first result as the value for `Clang_DIR`. The LLVM root
   directory is likely an ancestor of this directory; it will be the directory that contains the
   `bin`, `include`, `lib`, and `share` subdirectories.

   ```
   Clang_DIR=/path/to/containing/dir cmake -B build -DPATH_TO_LLVM=/path/to/llvm/root
   ```
