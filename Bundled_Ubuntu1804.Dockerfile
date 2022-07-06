# This Dockerfile is used to create a build of lsif-clang
# along with the accompanying dynamically linked libraries.
# Those are packaged up together in a tarball for ease
# of deployment. In the future, it would be nicer to provide
# a statically linked binary.
#
# See issue https://github.com/sourcegraph/lsif-clang/issues/72
#
# We are using ubuntu 18.04 so that the dynamic libraries
# only link in symbols from older Glibc versions, which will
# be present in newer Glibc versions. Building on Ubuntu 22.04
# will lead to missing symbols when trying to run on (say) 20.04.

# KNOWN LIMITATION: {clang,llvm}-11 libraries are not available for aarch64
# on Ubuntu 18.04.

FROM ubuntu:18.04 as build

# Base tools
RUN apt-get update && apt-get install -y ca-certificates wget gnupg2 lsb-release

# Set up LLVM and CMake
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key \
      | apt-key add - && \
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
      | gpg --dearmor - \
      | tee /etc/apt/trusted.gpg.d/kitware.gpg \
      > /dev/null && \
    echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-11 main" \
      | tee -a /etc/apt/sources.list && \
    echo "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" \
      | tee -a /etc/apt/sources.list && \
    apt-get update

# Install the tool chain
RUN apt install -y llvm-11 clang-11 libclang-11-dev cmake libdwarf-dev libelf-dev

# Do the build
WORKDIR /lsif-clang

COPY . .

RUN cd /lsif-clang && \
    CC=clang-11 CXX=clang-11 cmake -B build && \
    make -C /lsif-clang/build -j$(nproc) && \
    clang-tools-extra/lsif-clang/package/copy_needed_dynamic_libs.sh ./bin/lsif-clang ./bin

FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# This will bring all required dependencies
COPY --from=build /lsif-clang/bin /usr/local/bin

ENTRYPOINT [ "lsif-clang" ]
