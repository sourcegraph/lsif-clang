FROM ubuntu:18.04 as build

# Base tools
RUN apt update && apt install -y ca-certificates wget gnupg2 lsb-release

# LLVM Repo
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-11 main" | tee -a /etc/apt/sources.list && apt-get update

# CMake repo
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg > /dev/null
RUN echo "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" | tee -a /etc/apt/sources.list && apt-get update

# Install the tool chain
RUN apt install -y llvm-11 clang-11 libclang-11-dev cmake

# Do the build
WORKDIR /lsif-clang

COPY . .

RUN mkdir /lsif-clang/build
RUN cd /lsif-clang/build && CC=clang-11 CXX=clang-11 cmake .. && make -C /lsif-clang/build -j$(nproc)
RUN cd /lsif-clang && clang-tools-extra/lsif-clang/package/copy_dependencies.sh ./bin/lsif-clang ./bin

FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# This will bring all required dependencies
COPY --from=build /lsif-clang/bin /usr/local/bin

ENTRYPOINT [ "lsif-clang" ]
