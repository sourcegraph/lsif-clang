# This Dockerfile is used to create a build of lsif-clang
# along with the accompanying dynamically linked libraries.
# Those are packaged up together in a tarball for ease
# of deployment. In the future, it would be nicer to provide
# a statically linked binary.
#
# See issue https://github.com/sourcegraph/lsif-clang/issues/72

FROM ubuntu:22.04 as build

# Base tools
RUN apt update && apt install -y wget lsb-release llvm-11-dev llvm-11 libclang-11-dev clang-11 cmake libdwarf-dev libelf-dev

# Do the build
WORKDIR /lsif-clang

COPY . .

RUN cd /lsif-clang && \
    CC=clang-11 CXX=clang-11 cmake -B build && \
    make -C /lsif-clang/build -j$(nproc) && \
    clang-tools-extra/lsif-clang/package/copy_dependencies.sh ./bin/lsif-clang ./bin

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# This will bring all required dependencies
COPY --from=build /lsif-clang/bin /usr/local/bin

ENTRYPOINT [ "lsif-clang" ]
