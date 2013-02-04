#!/bin/sh

try () {
    "$@" || exit -1
}

. /newbuild/env.sh

try cd /t/ab/renpy/module
try python setup.py clean
try python setup.py build --compiler=mingw32 install_lib -d $PYTHONPATH
try python -OO /t/ab/renpy-deps/renpython/build.py windows-i686 /t/ab/renpy



