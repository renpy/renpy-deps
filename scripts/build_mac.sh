#!/bin/sh

try () {
    "$@" || exit -1
}

try mkdir -p ~/newbuild
try cd ~/newbuild
try sh /Users/tom/ab/renpy-deps/build_mac.sh
