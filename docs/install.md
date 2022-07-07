# Installing lsif-clang

There are two ways of setting up lsif-clang, in increasing order of complexity:
1. Use the existing bundled tarball from the [Releases page][],
   which includes the `lsif-clang` binary and necessary dynamic libraries.
   This has been tested for Ubuntu 18.04 and Ubuntu 20.04,
   and should work for newer Ubuntu versions too.
2. Build `lsif-clang` from source.
3. Use a Docker image.

We describe each of these in turn.

[Releases page]: https://github.com/sourcegraph/lsif-clang/releases
## Using the bundled tarball

NOTE: This may or may not work on Linux distributions other than Ubuntu.

Download a tarball from the [Releases page][] and unpack it (`tar -xzvf lsif-clang-<release>.tar.gz`).
You should see an executable script named `lsif-clang`,
which can be invoked normally.

## Building from source

### Install dependencies.

#### Ubuntu

```sh
# Ubuntu 22.04
sudo apt install llvm-11 llvm-11-dev clang-11 libclang-11-dev cmake binutils-dev libdwarf-dev libelf-dev
```

For installing dependencies in Ubuntu 18.04, see the corresponding [Dockerfile](Bundled_Ubuntu1804.Dockerfile).

#### macOS

```sh
brew install cmake llvm@11 binutils
```

### Clone and build

```
git clone https://github.com/sourcegraph/lsif-clang.git --depth=1
```

#### Ubuntu

```sh
cmake -B build
make -C build -j8
```
#### macOS

```sh
Clang_DIR=/usr/local/opt/llvm\@11/lib/cmake/clang cmake -B build -DPATH_TO_LLVM=/usr/local/opt/llvm\@11
make -C build -j8
```

<details>
<summary>Troubleshooting missing ClangConfig.cmake error</summary>

If you encounter the following error:

```
Could not find a package configuration file provided by "Clang" with any of the following names:

	ClangConfig.cmake
	clang-config.cmake
```

Double-check that `llvm@11` was installed correctly with `brew info llvm@11`.
A successful installation should have output with something like "Poured from bottle on."

If `llvm@11` was installed

1. Manually the path to `ClangConfig.cmake`:

   ```
   find /usr/ -name ClangConfig.cmake
   ```

1. Set the *containing directory* of the first result as the value for `Clang_DIR`. The LLVM root
   directory is likely an ancestor of this directory; it will be the directory that contains the
   `bin`, `include`, `lib`, and `share` subdirectories.

   ```
   Clang_DIR="$(find /opt -name ClangConfig.cmake | head -n 1 | xargs dirname)" cmake -B build -DPATH_TO_LLVM=/path/to/llvm/root
   ```

</details>

### Cross-check

Run `./bin/lsif-clang build/compile_commands.json > dump.lsif` to try indexing `lsif-clang`'s
source code with itself. Usually, this should just work.

<details>
<summary>Troubleshooting macOS libLLVM.dylib error</summary>

On macOS, if you encounter an error like "libLLVM.dylib cannot be opened because the developer cannot be verified", open **System Preferences > Security & Privacy > General** and click **Open Anyway** next to the message "libLLVM.dylib was blocked from use because it is not from an identified developer". Run `lsif-clang` again and click the **Open** button in the system dialog that pops up.

</details>

## Using a Docker image

The [Sourcegraph docs on indexing C++](https://docs.sourcegraph.com/code_intelligence/how-to/index_a_cpp_repository#with-docker-recommended)
describe how to use Docker to index C++ code.

You need to make one change:
- The prefix for setting up `lsif-clang` is out-of-date.
  Instead, you can use:
  ```
  FROM sourcegraph/lsif-clang:latest
  ```
  as the base image.
