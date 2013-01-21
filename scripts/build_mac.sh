#!/bin/sh

try () {
    "$@" || exit -1
}

try cd ~
try mkdir -p newbuild
try sh /Volumes/shared/ab/renpy-deps/build_mac.sh
