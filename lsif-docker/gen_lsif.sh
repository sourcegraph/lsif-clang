#!/bin/bash

set -eux
cd /source

lsif-clang compile_commands.json
