FROM ubuntu:20.04

RUN apt update && apt upgrade -y

RUN DEBIAN_FRONTEND=noninteractive \
    apt -y install git openssh-server wget curl llvm-10 \
    clang clang-10 libclang-10-dev cmake fish gdb lldb \
    curl gnupg unzip zip sudo clangd

# Would be nice if we got bin releases of lsif-validate and lsif-visualize, to skip having to install Go
RUN mkdir /tmp/go && cd /tmp/go \
    && wget https://golang.org/dl/go1.15.5.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.15.5.linux-amd64.tar.gz

ENV PATH="${PATH}:/usr/local/go/bin:${HOME}/go/bin"

RUN mkdir /tmp/bazel && cd /tmp/bazel \
    && curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg \
    && mv bazel.gpg /etc/apt/trusted.gpg.d/ \
    && echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
    && apt update && apt install -y bazel

RUN useradd -ms /usr/bin/fish ubuntu \
    && usermod -aG sudo ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && mkdir /home/ubuntu/go && mkdir -p /workspace/lsif-clang \
    && chown -R ubuntu /workspace && chown -R ubuntu /home/ubuntu/go

USER ubuntu

RUN go get github.com/sourcegraph/lsif-test/cmd/lsif-validate \
    && go get github.com/sourcegraph/lsif-test/cmd/lsif-visualize
