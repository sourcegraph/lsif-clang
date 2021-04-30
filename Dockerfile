FROM ubuntu:20.10 as build

RUN apt update && apt install -y llvm-10 clang-10 libclang-10-dev cmake

WORKDIR /lsif-clang

COPY . .

RUN CC=clang-10 CXX=clang-10 cmake -B build && make -C build -j$(nproc)

FROM ubuntu:20.10

RUN apt update && apt install -y libllvm10 cmake clang-10

# Might as well set this, for auto-index purposes
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=build /lsif-clang/bin/lsif-clang /usr/local/bin/lsif-clang

ENTRYPOINT [ "lsif-clang" ]