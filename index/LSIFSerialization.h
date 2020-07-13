//===-- LSIFSerialization.h ------------------------------------*- C++-*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// LSIF spec:
// https://microsoft.github.io/language-server-protocol/specifications/lsif/0.5.0/specification/
//
//===----------------------------------------------------------------------===//

#include "index/Serialization.h"

namespace clang {
namespace clangd {
  void writeLSIF(const IndexFileOut &O, llvm::raw_ostream &OS);
}// namespace clangd
}// namespace clang
