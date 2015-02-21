#!/bin/sh

try () {
    "$@" || exit -1
}

try mkdir -p ~/newbuild
try cd ~/newbuild
try sh /Volumes/ab/renpy-deps/build_mac.sh
