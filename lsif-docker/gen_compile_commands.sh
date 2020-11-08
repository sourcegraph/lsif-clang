#!/bin/bash

set -eux

cd /source

mkdir -p /install
./autogen.sh
./configure --prefix=/install
bear make
