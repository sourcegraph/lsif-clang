add_executable(lsif-clang
    LSIFClangMain.cpp
    LSIFSerialization.cpp
    # ${BACKWARD_ENABLE}
    )

# Make other directories available to us in clang-tools-extra
include_directories("../clangd/")
# add_subdirectory("../clangd/indexer/")


add_library(clangDaemonMinimal
  ../clangd/AST.cpp
  ../clangd/CodeCompletionStrings.cpp
  ../clangd/CollectMacros.cpp
  ../clangd/Compiler.cpp
  ../clangd/Diagnostics.cpp
  ../clangd/ExpectedTypes.cpp
  ../clangd/FindTarget.cpp
  ../clangd/FS.cpp
  ../clangd/FuzzyMatch.cpp
  ../clangd/Headers.cpp
  ../clangd/Preamble.cpp
  ../clangd/Protocol.cpp
  ../clangd/SourceCode.cpp
  ../clangd/URI.cpp

  ../clangd/support/Context.cpp
  ../clangd/support/Logger.cpp
  ../clangd/support/Trace.cpp
  ../clangd/support/ThreadsafeFS.cpp

  ../clangd/index/CanonicalIncludes.cpp
  ../clangd/index/Index.cpp
  ../clangd/index/IndexAction.cpp
  ../clangd/index/Merge.cpp
  ../clangd/index/Ref.cpp
  ../clangd/index/Relation.cpp
  ../clangd/index/Symbol.cpp
  ../clangd/index/SymbolCollector.cpp
  ../clangd/index/SymbolID.cpp
  ../clangd/index/SymbolLocation.cpp
  ../clangd/index/SymbolOrigin.cpp

  # Cancellation.cpp
  # ClangdLSPServer.cpp
  # ClangdServer.cpp
  # CodeComplete.cpp
  # CompileCommands.cpp
  # DraftStore.cpp
  # FSProvider.cpp
  # FileDistance.cpp
  # FindSymbols.cpp
  # Format.cpp
  # FormattedString.cpp
  # GlobalCompilationDatabase.cpp
  # HeaderSourceSwitch.cpp
  # Hover.cpp
  # IncludeFixer.cpp
  # JSONTransport.cpp
  # ParsedAST.cpp
  # PathMapping.cpp
  # Quality.cpp
  # QueryDriverDatabase.cpp
  # RIFF.cpp
  # Selection.cpp
  # SemanticHighlighting.cpp
  # SemanticSelection.cpp
  # Shutdown.cpp
  # TUScheduler.cpp
  # Threading.cpp
  # XRefs.cpp

  # support/Markup.cpp

  # index/Background.cpp
  # index/BackgroundIndexLoader.cpp
  # index/BackgroundIndexStorage.cpp
  # index/BackgroundQueue.cpp
  # index/BackgroundRebuild.cpp
  # index/FileIndex.cpp
  # index/MemIndex.cpp
  # index/Serialization.cpp
  # index/YAMLSerialization.cpp

  # index/dex/Dex.cpp
  # index/dex/Iterator.cpp
  # index/dex/PostingList.cpp
  # index/dex/Trigram.cpp

  # refactor/Rename.cpp
  # refactor/Tweak.cpp
  )

set(CLANGD_ATOMIC_LIB "")
if(NOT HAVE_CXX_ATOMICS64_WITHOUT_LIB)
  list(APPEND CLANGD_ATOMIC_LIB "atomic")
endif()

set(CLANG_DAEMON_LIBS
  clangAST
  clangASTMatchers
  clangBasic
  clangDriver
  clangFormat
  clangFrontend
  clangIndex
  clangLex
  clangSema
  clangSerialization
  clangTidy
  clangTooling
  clangToolingCore
  clangToolingInclusions
  clangToolingRefactoring
  clangToolingSyntax
  ${LLVM_PTHREAD_LIB}
  # ${CLANGD_ATOMIC_LIB}
  ${ALL_CLANG_TIDY_CHECKS}
  m
)
  

if (LLVM IN_LIST LLVM_AVAILABLE_LIBS)
  target_link_libraries(clangDaemonMinimal
    LLVM
    ${CLANG_DAEMON_LIBS}
  )
else()
  target_link_libraries(clangDaemonMinimal
    LLVMSupport
    ${CLANG_DAEMON_LIBS}
  )
endif()

target_link_libraries(lsif-clang
  stdc++
  clangDaemonMinimal
)

install(TARGETS lsif-clang)
