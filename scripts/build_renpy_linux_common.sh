#!/bin/sh

PLATFORM="$1"
RENPY="${2:-/home/tom/ab/renpy}"

try () {
    "$@" || exit 1
}

. "/home/tom/ab/$PLATFORM-deps/env.sh"

DEPS="/home/tom/ab/renpy-deps"

try cd "$RENPY/module"
try python setup.py clean --all
try python setup.py install_lib -d $PYTHONPATH

try cd "$DEPS/renpython"
try python -O build.py linux-`arch` "$RENPY" renpy.py

# Give some time for processes to die before schroot unmounts us.
sleep 1
