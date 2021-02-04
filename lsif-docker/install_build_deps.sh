#!/bin/bash

set -eux
cd $(dirname "${BASH_SOURCE[0]}")

echo "TODO: Update install_build_deps.sh with whatever commands are needed to install build dependencies."

##### Build tool examples:
#
## Autotools
# apt-get install -y autoconf automake libtool pkg-config
#
## Bazel (Bazelisk)
# RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.7.4/bazelisk-linux-amd64 -O /usr/local/bin/bazelisk
# RUN chmod +x /usr/local/bin/bazelisk
# RUN ln -s /usr/local/bin/bazelisk /usr/local/bin/bazel
#
#
##### Compilation database generation examples:
#
## bazel-compilation-database
# git clone --depth=10 https://github.com/grailbio/bazel-compilation-database.git /bazel-compilation-database
#
## Bear
# apt-get install -y bear
