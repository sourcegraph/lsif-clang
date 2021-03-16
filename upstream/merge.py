"""
$ git checkout llvmorg-$x-clangd
$ git -C $LLVM_PROJECT_DIR checkout llvmorg-$x (check if $x has a new minor version)
$ git -C $LLVM_PROJECT_DIR diff $(cat $LSIF_CLANG_DIR/latest_commit.txt) llvmorg-$x clang-tools-extra/clangd \
            | sed 's/clang-tools-extra\/clangd\///' > clangd.diff
$ git apply clangd.diff
$ git -C $HOME/sourcegraph/lsif-clang-test/llvm-project rev-list -n 1 llvmorg-10.0.1 > latest_commit.txt
$ git commit -am 'merge upstream'

# merge llvmorg-$x-clangd into llvmorg-$x-lsif-clang
$ git checkout llvmorg-$x-lsif-clang
$ git merge llvmorg-$x-clangd


options:
- bca373f73fc82728a8335e7d6cd164e8747139ec
- d5f8656a68c25e93c5c8f03e0670fecb16609d40
- da883d2c3b2fcf4977f2bbac11012da804655919


- Looks like last in 10.0.0: bca373f73fc82728a8335e7d6cd164e8747139ec

not likely:
- b2666ccca0277371a09e43a0a5a0f78029ba81e5

"""

import logging
import os
import subprocess
from pathlib import Path

import click
from git import Repo

logging.basicConfig(level=logging.INFO, format="%(levelname)s\t: %(message)s")


def _get_cache_dir() -> Path:
    root = os.getenv("XDG_CACHE_DIR")
    if not root:
        root = Path(os.path.expanduser("~/.cache"))

    llvm_path = root / "lsif-clang"
    llvm_path.mkdir(parents=True, exist_ok=True)

    return llvm_path


def _get_llvm_root() -> Path:
    return _get_cache_dir() / "llvm-project"


def _get_temp_lsif_root() -> Path:
    return _get_cache_dir() / "lsif-clang"


LLVM_VERSIONS = {10, 11}
LLVM_ROOT = _get_llvm_root()

with open("upstream/latest_commit.txt", "r") as _commit_reader:
    LATEST_COMMIT = _commit_reader.readline().strip()

TEMP_LSIF_CLANG = _get_temp_lsif_root()


def _checkout_repo(url: str, p: Path):
    if p.exists():
        logging.info(f"{url}is already checked out to: {p}")
        return

    subprocess.run(["git", "clone", url, p.absolute()], check=True)


def _checkout_upstream_llvm():
    _checkout_repo("https://github.com/llvm/llvm-project", LLVM_ROOT)


def _checkout_test_lsif_clang():
    _checkout_repo("https://github.com/sourcegraph/lsif-clang", TEMP_LSIF_CLANG)


def _checkout_llvm_tag(release: str):
    if not LLVM_ROOT.exists():
        raise Exception("Missing llvm project")

    # TODO: This is a bit annoying, since idk how to do this with the git thing.
    llvm_repo = Repo(LLVM_ROOT.absolute())
    release_tag = llvm_repo.tags[release]
    if llvm_repo.head.commit == release_tag.commit:
        logging.info(f"Already checked out to: {release}")
        return

    llvm_repo.git.checkout(release)


def _make_their_llvm_tag(llvm_version: int, minor_version: int = 0, patch_number: int = 0) -> str:
    return f"llvmorg-{llvm_version}.{minor_version}.{patch_number}"


def _make_our_clangd_branch(llvm_version: int, minor_version: int = 0, patch_number: int = 0) -> str:
    return f"llvmorg-{llvm_version}.{minor_version}.{patch_number}-clangd"


def _make_our_lsif_branch(llvm_version: int, minor_version: int = 0, patch_number: int = 0) -> str:
    return f"llvmorg-{llvm_version}.{minor_version}.{patch_number}-lsif-clang"


def _get_llvm_diff(p: Path, latest_commit: str, tag: str) -> str:
    res = subprocess.run(
        ["git", "diff", latest_commit, tag, "clang-tools-extra/clangd/"],
        capture_output=True,
        check=True,
        cwd=p.absolute(),
    )

    output = res.stdout.decode("utf-8")

    return output


def _transform_llvm_diff(output: str) -> str:
    # Maps source files from "/clang-tools-extra/clangd" -> "/
    output = output.replace("clang-tools-extra/clangd/", "")

    return output


# Might want to do something like:
#   for llvm_version in [10, 11]:
#       for minor_version in [0]:
#           for patch in [0, 1]:
#               apply patch?


@click.command()
@click.option("--llvm-version", required=True, type=int)
@click.option("--minor-version", default=0, type=int)
@click.option("--patch-number", default=0, type=int)
def main(llvm_version: int, minor_version: int, patch_number: int):
    if llvm_version not in LLVM_VERSIONS:
        raise Exception(f"Not a valid llvm version '{llvm_version}'. Acceptable version: {LLVM_VERSIONS}")

    _checkout_upstream_llvm()
    _checkout_test_lsif_clang()

    # TODO:
    #   - Checkout new branch with commit we're going to merge
    #   - Attempt to apply patch
    #   - Move patch forward.

    # TODO: Validate each of these exists.
    llvm_tag = _make_their_llvm_tag(llvm_version, minor_version, patch_number)
    clangd_branch = _make_our_clangd_branch(llvm_version, minor_version, patch_number)
    lsif_branch = _make_our_lsif_branch(llvm_version, minor_version, patch_number)

    _checkout_llvm_tag(llvm_tag)

    diff = _get_llvm_diff(LLVM_ROOT, LATEST_COMMIT, llvm_tag)
    diff = _transform_llvm_diff(diff)

    if not diff:
        print("No diff: Done!")
        return

    diff_file = _get_cache_dir() / "llvm_patch.diff"

    with open(diff_file, "w") as writer:
        writer.write(diff)

    lsif_clang_repo = Repo(TEMP_LSIF_CLANG)
    lsif_clang_repo.git.checkout(clangd_branch)

    print(
        subprocess.run(
            ["git", "apply", diff_file.absolute()],
            cwd=TEMP_LSIF_CLANG.absolute(),
            # check=True,
            capture_output=True,
        )
    )


if __name__ == "__main__":
    main()
