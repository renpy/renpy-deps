#!/bin/sh

BASE=/Users/tom
AB=/Volumes/shared/ab
RENPY="${1:-/Volumes/shared/ab/renpy}"


try () {
    "$@" || exit 1
}

. "$BASE/newbuild/env.sh"

export RENPY_CC="ccache gcc"
export RENPY_LD="ccache gcc"

try cd "$RENPY/module"
try python setup.py clean --all
try python setup.py install_lib -d $PYTHONPATH

try cd "$AB/renpy-deps/renpython"
try python -O build.py darwin-x86_64 "$RENPY" renpy.py

echo done.
