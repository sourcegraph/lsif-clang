cmake_policy(SET CMP0048 NEW)

project(LSIFClang VERSION 0.1)

cmake_minimum_required(VERSION 3.16)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_BUILD_TYPE RelWithDebInfo)
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O3 -DNDEBUG -g")
# set(LLVM_ENABLE_PROJECTS "clang;clang-tools-extra")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)

if (PATH_TO_LLVM)
  set (search_paths
    PATHS
    ${PATH_TO_LLVM}
    ${PATH_TO_LLVM}/cmake
    ${PATH_TO_LLVM}/lib/cmake
    ${PATH_TO_LLVM}/lib/cmake/llvm
    ${PATH_TO_LLVM}/lib/cmake/clang
    ${PATH_TO_LLVM}/share/clang/cmake/
    ${PATH_TO_LLVM}/share/llvm/cmake/
    NO_DEFAULT_PATH NO_CMAKE_PATH
  )

  message(STATUS "Searching in: ${search_paths}")
endif()

find_package(Clang
  REQUIRED CONFIG
  ${search_paths}
  )

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")
message(STATUS "Using ClangConfig.cmake in: ${CLANG_CMAKE_DIR}")

include_directories(${LLVM_INCLUDE_DIRS})

add_subdirectory("clang-tools-extra/lsif-clang")
