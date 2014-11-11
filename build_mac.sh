#!/bin/bash

# This builds the mac version of the Ren'Py dependencies.

try () {
    "$@" || exit -1
}

DIR=`dirname $0`

# Note - I had to link this into the SDKs directory of XCode to make it work.
# I'm not sure why.
# export SDKROOT="/Users/tom/SDKs/MacOSX10.6.sdk"
export MACOSX_DEPLOYMENT_TARGET=10.6

export PATH="$SDKROOT/usr/bin:$PATH"

export CFLAGS="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
export EXTRA_CFLAGS="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
export CXXFLAGS="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
# export LDFLAGS="-Wl,-syslibroot,$SDKROOT -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
export LDFLAGS="-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"

export JPEG_ASM="--host x86_64-apple-darwin"

try "$DIR/build_python.sh"
try "$DIR/build.sh"
