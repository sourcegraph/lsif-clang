# lsif-clang indexer ![Status: Development](https://img.shields.io/badge/status-beta-yellow?style=flat)

![GIF displaying usage on the linux kernel.](docs/images/torvalds-linux.gif)

This repo provides an LSIF indexer for C and C++ code.
It may work for Objective C code too,
but it hasn't been well-tested.
See the [compatibility](docs/compatibility.md) page for
information about support build configurations.

It's a work-in-progress, so it doesn't have the same functionality
as other Sourcegraph indexers like lsif-go, scip-java or scip-typescript.

## Usage

1. Follow the [installation instructions](docs/install.md) to obtain `lsif-clang`.
2. Generate a [compilation database](docs/compdb.md).
3. Run `lsif-clang`
    ```sh
    /path/to/lsif-clang compile_commands.json
    ```
    NOTE: The working directory should be the same as one used to generate the compilation database.
    The compilation database may have relative paths,
    which lsif-clang will interpret relative to the working directory it is run from.

    If you get missing header warnings (possible due to divergence between lsif-clang and Apple Clang),
    use an extra flag:
    ```
    lsif-clang --extra-arg="-resource-dir=$(clang -print-resource-dir)" compile_commands.json
    ```
    If you are still missing headers, there's likely an error in the way the compilation database was set up,
    or some generated code that's necessary for C++ compilation hasn't been output yet.

    If the error is due to missing generated files,
    you need to generate them up front using your build system.
    Typically, a full build will accomplish this,
    but your build system may have some faster option as well.

See the [examples](docs/examples.md) of producing LSIF indexes for a variety of OSS repositories to help troubleshoot.

## Troubleshooting

In some cases, lsif-clang may crash. Normally, it should print a stack trace if that happens.
In case you have a large build with a large number of failures,
with failure output intermingled with normal output,
you can narrow down failures using the [external driver script](./utils/lsif-clang-driver.py).

Example invocations:

- Fail fast (exit after first error), prints error output and reproduction information
    ```sh
    ./utils/lsif-clang-driver.py /path/to/lsif-clang /path/to/compile_commands.json

    Found lsif-clang failure (stdout+stderr below):
    --------------------------------------------------------------
    <lsif-clang output>
    --------------------------------------------------------------

    Reproduce the failure by running:
      /path/to/lsif-clang /<tmp-folder>/compile_commands.json
    ```
- Don't fail fast, printing all output and showing the number of errors at the end
    ```sh
    ./utils/lsif-clang-driver.py /path/to/lsif-clang /path/to/compile_commands.json --no-fail-fast

    <lsif-clang output>
    <reproduction information>
    ...
    <lsif-clang output>
    <reproduction information>

    30/31 lsif-clang commands failed. 😭
    ```

See the `--help` output for more flag options.

## Testing the generated LSIF index

You can use the [lsif-validate](https://github.com/sourcegraph/sourcegraph/tree/main/lib/codeintel/tools/lsif-validate) tool for basic sanity checking, or [upload the index to a Sourcegraph instance](https://docs.sourcegraph.com/code_intelligence/how-to/adding_lsif_to_workflows#basic-usage) for precise code navigation.

## Additional licensing notes

We use the [backwards-cpp](https://github.com/bombela/backward-cpp) code
which is [MIT licensed](https://github.com/bombela/backward-cpp/blob/master/LICENSE.txt).

## Historical note

This project was forked from [upstream LLVM](https://github.com/llvm/llvm-project/), with the core indexer being implemented as a copy of [clangd](https://clangd.llvm.org/) with modifications to add support for outputting [LSIF indexes](https://microsoft.github.io/language-server-protocol/specifications/lsif/0.5.0/specification/).

There's more info about the repo structure and its history in the [Forking Strategy](./docs/fork_strategy.md) doc.