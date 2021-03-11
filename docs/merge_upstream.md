# To update an llvmorg-$x-clangd branch in sourcegraph/lsif-clang
```bash
git checkout llvmorg-$x-clangd
git -C $LLVM_PROJECT_DIR checkout llvmorg-$x (check if $x has a new minor version)
git -C $LLVM_PROJECT_DIR diff $(cat $LSIF_CLANG_DIR/latest_commit.txt) llvmorg-$x clang-tools-extra/clangd | sed 's/\([ab\/]\)clang-tools-extra\/clangd\//\1/g' > clangd.diff
git apply clangd.diff
git -C $LLVM_RPOJECT_DIR rev-list -n 1 llvmorg-$x > latest_commit.txt
git commit -am 'merge upstream'
```

# merge llvmorg-$x-clangd into llvmorg-$x-lsif-clang
```bash
git checkout llvmorg-$x-lsif-clang
git merge llvmorg-$x-clangd
```
Then resolve conflicts, commit, done!
