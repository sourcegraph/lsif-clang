#!/bin/bash

set -eux
cd $(dirname "${BASH_SOURCE[0]}")

./checkout.sh
./gen_compile_commands.sh
./gen_lsif.sh
./upload.sh
