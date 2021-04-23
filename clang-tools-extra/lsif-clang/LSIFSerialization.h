//===-- LSIFSerialization.h ------------------------------------*- C++-*-===//
//
// Maintained and developed by Sourcegraph. Plz no copy pasta.
//
//===----------------------------------------------------------------------===//
//
// LSIF spec:
// https://microsoft.github.io/language-server-protocol/specifications/lsif/0.5.0/specification/
//
//===----------------------------------------------------------------------===//

#include "index/Serialization.h"

void writeLSIF(const clang::clangd::IndexFileOut &O, llvm::raw_ostream &OS, bool Debug, bool DebugFiles, const std::string &ProjectRoot);
