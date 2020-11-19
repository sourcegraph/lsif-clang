include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/backward-cpp)

add_executable(lsif-clang
    IndexerMain.cpp
    ${BACKWARD_ENABLE}
)

add_backward(lsif-clang)

install(TARGETS lsif-clang)

set(CLANG_LIBS
  clangDaemonFork
  clangAST
  clangBasic
  clangFrontend
  clangIndex
  clangLex
  clangTooling
  stdc++
)

if (LLVM IN_LIST LLVM_AVAILABLE_LIBS)
  target_link_libraries(lsif-clang
    LLVM
    ${CLANG_LIBS}
  )
else()
  target_link_libraries(lsif-clang
    LLVMSupport
    ${CLANG_LIBS}
  )
endif()
