FROM ubuntu:22.04 as build

RUN apt update && apt install -y llvm-11 llvm-11-dev clang-11 libclang-11-dev cmake libdwarf-dev libelf-dev

WORKDIR /lsif-clang

COPY . .

RUN CC=clang-11 CXX=clang-11 cmake -B build && make -C build -j$(nproc)

FROM ubuntu:22.04

RUN apt update && apt install -y libllvm11 cmake clang-11

# Might as well set this, for auto-index purposes
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=build /lsif-clang/bin/lsif-clang /usr/local/bin/lsif-clang

ENTRYPOINT [ "lsif-clang" ]
