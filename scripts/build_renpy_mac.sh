#!/bin/sh

try () {
    "$@" || exit -1
}

BASE=/Users/tom

. "$BASE/newbuild/env.sh"

try cd /Volumes/shared/ab/renpy/module
try sh ./build.sh

echo done.