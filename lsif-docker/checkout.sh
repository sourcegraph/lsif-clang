#!/bin/bash

set -eux
cd $(dirname "${BASH_SOURCE[0]}")

mkdir -p /source
git clone --depth=10 https://github.com/tesseract-ocr/tesseract.git /source

if [ ! -z "$PROJECT_REV" ]; then
    pushd /source
    git checkout "$PROJECT_REV"
    popd
fi
