#!/bin/sh

BASE=/Users/tom
AB=/Volumes/shared/ab

try () {
    "$@" || exit 1
}

. "$BASE/newbuild/env.sh"

try cd $AB/renpy/module
try python setup.py clean --all
try python setup.py install_lib -d $PYTHONPATH

try cd $AB/renpy-deps/renpython
try python -OO build.py darwin-x86_64 $AB/renpy

echo done.