# Compatibility

This doc page lists what kind of C++ projects lsif-clang supports.

In theory, lsif-clang should be able to index any C++ file which Clang can compile. The possible points of incompatibility are then:
- The code is not compileable by Clang. This is usually because the project is normally compiled with gcc, and uses C++ features from very new C++ standards. The only potential route to resolving this incompatibility is upgrading lsif-clang to depend on a newer version of the Clang libraries.
- It is too difficult to instruct lsif-clang on *how* to compile those files. i.e. it is too difficult to generate a compile_commands.json. This is usually an incompatibility in the build system, and can be resolved by using slower but more accurate tools for generating a compile_commands.json.

# Well Supported

- Projects which compile with Clang
- Projects which build using CMake
- Projects which build using Ninja

# Less well supported, but still possible

- Projects which compile with gcc, but don't use Clang-incompatible features
- Projects which build with Make
- Projects which build with Bazel

# Unsupported or unknown

- Projects which compile with gcc and use Clang-incompatible features
- Projects which build with other build tools than the ones listed above
