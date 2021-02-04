#!/bin/bash

set -eux
cd $(dirname "${BASH_SOURCE[0]}")

mkdir -p /source

PROJECT_CLONE_URL=
if [ -z "$PROJECT_CLONE_URL" ]; then
    echo 'Set PROJECT_CLONE_URL in checkout.sh to the clone URL of your project, e.g., "https://github.com/tesseract-ocr/tesseract.git"'
    exit 1
fi

git clone --depth=10 "$PROJECT_CLONE_URL" /source

if [ ! -z "$PROJECT_REV" ]; then
    pushd /source
    git checkout "$PROJECT_REV"
    popd
fi
