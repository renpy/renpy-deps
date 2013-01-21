#!/bin/bash

# This builds the mac version of the Ren'Py dependencies.

try () {
    "$@" || exit -1
}

DIR=`dirname $0`

export SDKROOT="/Users/tom/SDKs/MacOSX10.6.sdk"
export MACOSX_DEPLOYMENT_TARGET=10.6
export CFLAGS="-isysroot $SDKROOT -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
export EXTRA_CFLAGS="-isysroot $SDKROOT -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
export CXXFLAGS="-isysroot $SDKROOT -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
# export LDFLAGS="-Wl,-syslibroot,$SDKROOT -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
export LDFLAGS="-isysroot $SDKROOT -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"

export JPEG_ASM="--host x86_64-apple-darwin"

try "$DIR/build_python.sh"
try "$DIR/build.sh"

