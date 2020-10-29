# Get dependencies

This project depends on LLVM and Clang. lsif-clang itself should be built against LLVM and Clang version 10, and can index any code Clang 10 can compile.

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

# Install the tool

```sh
cmake -B build
sudo make -C build -j16 install
```

#### MacOS
Add the following extra argument to the `cmake` step:
```sh
cmake -B build -DPATH_TO_LLVM=/usr/local/opt/lib
```

If you encounter the following error:

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
1. Set the *containing directory* of the first result as the value for `Clang_DIR` in the following command:
   ```
   Clang_DIR=/path/to/containing/dir cmake -B build -DPATH_TO_LLVM=/usr/local/opt/lib
   ```
