FROM ubuntu:focal

# General dependencies
RUN apt-get -qq update
RUN apt-get install -qq -y llvm-10 clang clang-10 libclang-10-dev cmake wget curl zip
RUN apt-get install -qq -y git

# Install lsif-clang
ENV LSIF_CLANG_REV=366659086a6ba2968c837179c17ff978cf3efc97
RUN git clone https://github.com/sourcegraph/lsif-clang.git
WORKDIR /lsif-clang
RUN git checkout $LSIF_CLANG_REV
RUN cmake -B build
RUN make -C build install
WORKDIR /

# src-cli
ENV SRC_ACCESS_TOKEN=""
ENV SRC_ENDPOINT="https://sourcegraph.com"
RUN curl -L https://sourcegraph.com/.api/src-cli/src_linux_amd64 -o /usr/local/bin/src
RUN chmod +x /usr/local/bin/src

# Install build dependencies that do not change from revision to revision
RUN mkdir -p /sh
COPY ./install_build_deps.sh /sh/install_build_deps.sh
RUN /sh/install_build_deps.sh

# Add entrypoint scripts
COPY ./checkout.sh /sh/checkout.sh
COPY ./gen_compile_commands.sh /sh/gen_compile_commands.sh
COPY ./gen_lsif.sh /sh/gen_lsif.sh
COPY ./upload.sh /sh/upload.sh
COPY ./run.sh /sh/run.sh


ENV PROJECT_REV=""
ENV SRC_ACCESS_TOKEN=""
ENV SRC_ENDPOINT="https://sourcegraph.com"
CMD /sh/run.sh
