#!/bin/sh

DEPS="$1"

try () {
    "$@" || exit 1
}

. "/home/tom/ab/$DEPS-deps/env.sh"

try cd /home/tom/ab/renpy/module
try python setup.py clean --all
try python setup.py install_lib -d $PYTHONPATH

try cd /home/tom/ab/renpy-deps/renpython
try python -OO build.py linux-`arch` /home/tom/ab/renpy


#
# try cd /home/tom/ab/py4renpy
# try ./build.sh 