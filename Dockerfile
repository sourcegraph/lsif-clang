FROM ubuntu:20.04 as build

RUN apt update && apt install -y llvm-10 clang clang-10 libclang-10-dev cmake

WORKDIR /lsif-clang

COPY . .

RUN cmake -B build && make -C build -j$(nproc)

FROM ubuntu:20.04

RUN apt update && apt install -y llvm-10 cmake

COPY --from=build /lsif-clang/bin/lsif-clang /usr/local/bin/lsif-clang

ENTRYPOINT [ "lsif-clang" ]