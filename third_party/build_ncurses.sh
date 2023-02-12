#!/usr/bin/env bash

set -exuo pipefail

pushd ncurses

./configure --with-shared
make

popd
