#!/bin/bash

. abi_settings.sh $1 $2 $3

pushd faac-1.28

make clean

autoreconf -ivf

./configure \
  --disable-dependency-tracking \
  --with-pic \
  --host="$NDK_TOOLCHAIN_ABI" \
  --without-mp4v2 \
  --enable-static \
  --disable-shared \
  --prefix="${TOOLCHAIN_PREFIX}" || exit 1

make -j${NUMBER_OF_CORES} install || exit 1

popd
