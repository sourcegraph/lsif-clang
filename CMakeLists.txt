project(LSIFClang)
cmake_minimum_required(VERSION 3.16)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/)
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set (search_paths
  $ENV{PATH_TO_LLVM}
  $ENV{PATH_TO_LLVM}/lib/cmake
  $ENV{PATH_TO_LLVM}/lib/cmake/llvm
  $ENV{PATH_TO_LLVM}/lib/cmake/clang
  $ENV{PATH_TO_LLVM}/share/clang/cmake/
  $ENV{PATH_TO_LLVM}/share/llvm/cmake/
)

find_package(LLVM REQUIRED CONFIG
             PATHS ${search_paths}
             NO_DEFAULT_PATH)
find_package(Clang REQUIRED CONFIG
             PATHS ${search_paths}
             NO_DEFAULT_PATH)

include_directories(${LLVM_INCLUDE_DIRS})

add_library(clangDaemonFork
  AST.cpp
  # Cancellation.cpp
  # ClangdLSPServer.cpp
  # ClangdServer.cpp
  # CodeComplete.cpp
  CodeCompletionStrings.cpp
  # CompileCommands.cpp
  # Compiler.cpp
  Context.cpp
  # Diagnostics.cpp
  # DraftStore.cpp
  ExpectedTypes.cpp
  # FindSymbols.cpp
  FindTarget.cpp
  # FileDistance.cpp
  # Format.cpp
  # FS.cpp
  # FSProvider.cpp
  # FormattedString.cpp
  FuzzyMatch.cpp
  # GlobalCompilationDatabase.cpp
  Headers.cpp
  # HeaderSourceSwitch.cpp
  # Hover.cpp
  # IncludeFixer.cpp
  # JSONTransport.cpp
  Logger.cpp
  # PathMapping.cpp
  Protocol.cpp
  # Quality.cpp
  # ParsedAST.cpp
  # Preamble.cpp
  # RIFF.cpp
  # Selection.cpp
  # SemanticHighlighting.cpp
  # SemanticSelection.cpp
  # Shutdown.cpp
  SourceCode.cpp
  # QueryDriverDatabase.cpp
  # Threading.cpp
  Trace.cpp
  # TUScheduler.cpp
  URI.cpp
  # XRefs.cpp

  # index/Background.cpp
  # index/BackgroundIndexLoader.cpp
  # index/BackgroundIndexStorage.cpp
  # index/BackgroundQueue.cpp
  # index/BackgroundRebuild.cpp
  index/CanonicalIncludes.cpp
  # index/FileIndex.cpp
  index/Index.cpp
  index/IndexAction.cpp
  index/LSIFSerialization.cpp
  # index/MemIndex.cpp
  index/Merge.cpp
  index/Ref.cpp
  index/Relation.cpp
  # index/Serialization.cpp
  index/Symbol.cpp
  index/SymbolCollector.cpp
  index/SymbolID.cpp
  index/SymbolLocation.cpp
  index/SymbolOrigin.cpp
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
  # clangTidy
  clangTooling
  clangToolingCore
  clangToolingInclusions
  clangToolingRefactoring
  clangToolingSyntax
  ${LLVM_PTHREAD_LIB}
  ${CLANGD_ATOMIC_LIB}
  ${ALL_CLANG_TIDY_CHECKS}
  m
)
  

if (LLVM IN_LIST LLVM_AVAILABLE_LIBS)
  target_link_libraries(clangDaemonFork
    LLVM
    ${CLANG_DAEMON_LIBS}
  )
else()
  target_link_libraries(clangDaemonFork
    LLVMSupport
    ${CLANG_DAEMON_LIBS}
  )
endif()

# add_subdirectory(refactor/tweaks)
# add_subdirectory(tool)
add_subdirectory(indexer)
# add_subdirectory(index/dex/dexp)

if (LLVM_INCLUDE_BENCHMARKS)
  add_subdirectory(benchmarks)
endif()

if(CLANG_INCLUDE_TESTS)
add_subdirectory(test)
add_subdirectory(unittests)
endif()
