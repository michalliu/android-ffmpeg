#!/bin/bash

. abi_settings.sh $1 $2 $3

pushd ffmpeg

CFLAGS="$CFLAGS -O3 -DANDROID"

case $1 in
  armeabi)
    CPU="cortex-a5"
    ABLES="--disable-neon"
  ;;
  armeabi-v7a)
    CFLAGS="$CFLAGS -march=armv7-a -mfloat-abi=softfp"
    ABLES="--enable-asm --enable-thumb --enable-hwaccels --cpu=armv7-a"
    CPU="cortex-a8"
  ;;
  armeabi-v7a-neon)
    CFLAGS="$CFLAGS -march=armv7-a -mfloat-abi=softfp -mfpu=neon"
    ABLES="--enable-asm --enable-thumb --enable-hwaccels --cpu=armv7-a --enable-neon"
  ;;
  x86)
    CPU='i686'
  ;;
esac

make clean

config_standard() {
./configure \
--target-os="$TARGET_OS" \
--cross-prefix="$CROSS_PREFIX" \
--arch="$NDK_ABI" \
--cpu="$CPU" \
--enable-runtime-cpudetect \
--sysroot="$NDK_SYSROOT" \
$ABLES \
--enable-pic \
--enable-libx264 \
--enable-libass \
--enable-libfreetype \
--enable-libfribidi \
--enable-fontconfig \
--enable-pthreads \
--disable-debug \
--disable-ffserver \
--enable-version3 \
--enable-hardcoded-tables \
--disable-ffplay \
--disable-ffprobe \
--enable-gpl \
--enable-yasm \
--disable-doc \
--disable-shared \
--enable-static \
--pkg-config="${2}/ffmpeg-pkg-config" \
--prefix="${2}/build/${1}" \
--extra-cflags="-I${TOOLCHAIN_PREFIX}/include $CFLAGS" \
--extra-ldflags="-L${TOOLCHAIN_PREFIX}/lib $LDFLAGS" \
--extra-libs="-lpng -lexpat -lm" \
--extra-cxxflags="$CXX_FLAGS" || exit 1
}

#strip down ffmpeg
config_small(){
./configure \
--target-os="$TARGET_OS" \
--cross-prefix="$CROSS_PREFIX" \
--arch="$NDK_ABI" \
--cpu="$CPU" \
--enable-runtime-cpudetect \
--sysroot="$NDK_SYSROOT" \
$ABLES \
--disable-debug \
--disable-doc \
--disable-ffplay \
--disable-ffserver \
--disable-stripping \
--disable-avdevice \
--disable-postproc \
--disable-network \
--enable-pthreads \
--enable-small \
--disable-encoders \
--enable-encoder=libx264 \
--enable-encoder=libfaac \
--enable-libx264 \
--enable-libfaac \
--disable-decoders \
--enable-decoder=mjpeg \
--disable-parsers \
--disable-muxers \
--enable-muxer=mp4 \
--disable-demuxers \
--enable-demuxer=image2 \
--disable-protocols \
--enable-protocol=file \
--disable-devices \
--disable-bsfs \
--enable-nonfree \
--enable-static \
--enable-gpl \
--enable-pic \
--pkg-config="${2}/ffmpeg-pkg-config" \
--prefix="${2}/build/${1}" \
--extra-cflags="-I${TOOLCHAIN_PREFIX}/include $CFLAGS" \
--extra-ldflags="-L${TOOLCHAIN_PREFIX}/lib $LDFLAGS" \
--extra-libs="-lpng -lexpat -lm" \
--extra-cxxflags="$CXX_FLAGS" || exit 1
}

#config_standard $@
config_small $@

make V=s -j${NUMBER_OF_CORES} && make install || exit 1

popd
