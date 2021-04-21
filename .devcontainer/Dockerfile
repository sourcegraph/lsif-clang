FROM ubuntu:20.10

RUN apt update

RUN DEBIAN_FRONTEND=noninteractive \
    apt -y install git openssh-server wget curl llvm-10 \
    clang clang-10 libclang-10-dev cmake fish zsh gdb lldb \
    curl gnupg unzip zip sudo clangd nano vim valgrind \
    apt-transport-https ca-certificates lsb-release gnupg2 \
    software-properties-common

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" \
    && apt update \
    && apt -y install docker-ce-cli \
    && touch /var/run/docker.sock

# Would be nice if we got bin releases of lsif-validate and lsif-visualize, to skip having to install Go
RUN mkdir /tmp/go && cd /tmp/go \
    && wget https://golang.org/dl/go1.15.5.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.15.5.linux-amd64.tar.gz

RUN mkdir /tmp/bazel && cd /tmp/bazel \
    && curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg \
    && mv bazel.gpg /etc/apt/trusted.gpg.d/ \
    && echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
    && apt update && apt install -y bazel

# change to zsh if youd like
RUN useradd -m ubuntu \
    && usermod -aG sudo ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && mkdir /home/ubuntu/go && mkdir -p /workspace/lsif-clang \
    && chown -R ubuntu /workspace && chown -R ubuntu /home/ubuntu/go

USER ubuntu

ENV PATH="${PATH}:/usr/local/go/bin:${HOME}/go/bin"

RUN go get github.com/sourcegraph/lsif-test/cmd/lsif-validate \
    && go get github.com/sourcegraph/lsif-test/cmd/lsif-visualize

