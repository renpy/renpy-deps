#!/bin/sh

try () {
    "$@" || exit 1
}

. /newbuild/env.sh

RENPY="${1:-/t/ab/renpy}"
DEPS="/t/ab/renpy-deps"

try cd "$RENPY/module"
try python setup.py clean
try python setup.py build --compiler=mingw32 install_lib -d $PYTHONPATH
try python -O "$DEPS/renpython/build.py" windows-i686 "$RENPY" renpy.py
