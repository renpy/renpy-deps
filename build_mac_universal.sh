#!/bin/bash

# This is the script I use to build the mac versions of all the software
# used by Ren'Py, in both i386 and PPC variants. We then build applications
# using py2app, and merge the two together into a single application.

try () {
    "$@" || exit -1
}

DIR=`dirname $0`

export RENPY_FRAMEWORK="/Developer/SDKs/MacOSX10.4u.sdk"
export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT="$RENPY_FRAMEWORK"
export SDK_DIR="$RENPY_FRAMEWORK"
export SDK_NAME=macosx10.4
export CFLAGS="-isysroot $RENPY_FRAMEWORK -mmacosx-version-min=10.4"
export EXTRA_CFLAGS="-isysroot $RENPY_FRAMEWORK -mmacosx-version-min=10.4"
export CXXFLAGS="-isysroot $RENPY_FRAMEWORK -mmacosx-version-min=10.4"
export LDFLAGS="-Wl,-syslibroot,$RENPY_FRAMEWORK -mmacosx-version-min=10.4"
# export LDFLAGS="-isysroot $RENPY_FRAMEWORK -mmacosx-version-min=10.4"


# Build the i386 version.
arch="-arch i386" 

export CC="gcc $arch"
export LD="gcc $arch"
export CXX="g++ $arch"
export CXXLD="g++ $arch"
export FFMPEGFLAGS=""

mkdir -p newbuild.i386
try cd newbuild.i386
try "$DIR/build_python.sh"
try "$DIR/build.sh"
cd ..

# Build the ppc version.
arch="-arch ppc"
export MACOSX_DEFAULT_ARCH="ppc"

export CC="gcc $arch"
export LD="gcc $arch"
export CXX="g++ $arch"
export CXXLD="g++ $arch"
export FFMPEGFLAGS="--arch=ppc"
export SDL_ASM="--disable-nasm"
export JPEG_ASM="--without-simd"

mkdir -p newbuild.ppc
try cd newbuild.ppc

mkdir -p install/bin
echo '#!/bin/sh' > install/bin/arch
echo 'echo ppc' > install/bin/arch
chmod a+x install/bin/arch

try "$DIR/build_python.sh"
try "$DIR/build.sh"
cd ..
