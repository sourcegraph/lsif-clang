project(StandaloneTest)
cmake_minimum_required(VERSION 3.16)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_BUILD_TYPE RelWithDebInfo)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)

message(STATUS "CMaking StandaloneTest")

add_executable(main src/standalone.c)
