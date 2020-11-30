# Compilation databases

lsif-clang figures out how to compile your code by reading from a [JSON compilation database](http://clang.llvm.org/docs/JSONCompilationDatabase.html), a specification published by the LLVM project. This page contains detailed instructions for how to generate compilation databases for various build systems.

## CMake

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

This database will also contain irrelevant entries which will make lsif-clang output quite noisy but still functional. To filter the irrelevant entries, you can use a `jq` snippet like:
```sh
ninja -t compdb | jq '[ .[] | select(.command | startswith("/usr/bin/c++")) ] > compile_commands.json'
```
You can manually inspect the output of `ninja -t compdb` to see what compiler invocation to replace `/usr/bin/c++` with.


## Bazel

Add the following to your WORKSPACE:
```skylark
http_archive(
    name = "com_grail_bazel_compdb",
    strip_prefix = "bazel-compilation-database-master",
    urls = ["https://github.com/grailbio/bazel-compilation-database/archive/master.tar.gz"],
)
```

Then you can run:
```bash
bazel build \
  --aspects=@bazel_compdb//:aspects.bzl%compilation_database_aspect \
  --output_groups=compdb_files,header_files \ # this should include any generated outputs needed for cpp compilation
  $(bazel query 'kind("cc_(library|binary|test|inc_library|proto_library)", //...)')
```
The bazel query might look different for your project.


## If all else fails, bears

Install the [Bear](https://github.com/rizsotto/Bear) tool and run `bear make`, or `bear <your-build-command>`. This will intercept the actual commands used to build your project and generate a compilation database from them. This is a last resort as it requires you to compile your entire project from scratch before compiling it a second time with `lsif-clang`, which can take quite a while.

