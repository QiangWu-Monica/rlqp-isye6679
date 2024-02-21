#!/bin/bash

set -e

declare -a CMAKE_FLAGS
[ -e build_cuda.config ] && CMAKE_FLAGS=("${CMAKE_FLAGS[@]}" $(<build_cuda.config))
CMAKE_FLAGS=("${CMAKE_FLAGS[@]}" "$@")

rm -rf build
mkdir -p build
cd build

cmake "${CMAKE_FLAGS[@]}" ..
cmake --build .
make -j4

echo "Finished. Check the 'build' directory for results."
