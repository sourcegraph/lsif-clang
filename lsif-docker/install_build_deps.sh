#!/bin/bash

set -eux
cd $(dirname "${BASH_SOURCE[0]}")

apt-get install -y autoconf automake libtool
apt-get install -y pkg-config
apt-get install -y libpng-dev
apt-get install -y libjpeg8-dev
apt-get install -y libtiff5-dev
apt-get install -y zlib1g-dev
apt-get install -y libleptonica-dev
apt-get install -y pkg-config
