//===--- Merge.h -------------------------------------------------*- C++-*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_TOOLS_EXTRA_CLANGD_INDEX_MERGE_H
#define LLVM_CLANG_TOOLS_EXTRA_CLANGD_INDEX_MERGE_H

#include "Index.h"

namespace clang {
namespace clangd {

// Merge symbols L and R, preferring data from L in case of conflict.
// The two symbols must have the same ID.
// Returned symbol may contain data owned by either source.
Symbol mergeSymbol(const Symbol &L, const Symbol &R,
                   const std::string &ProjectRoot);

} // namespace clangd
} // namespace clang

#endif // LLVM_CLANG_TOOLS_EXTRA_CLANGD_INDEX_MERGE_H
