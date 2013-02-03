#!/bin/bash

# This is called after each build is complete, to combine them into a single
# lib directory.


try () {
    "$@" || exit 1
}

DEPS=/home/tom/ab/renpy-deps
RENPY=/home/tom/ab/renpy

try python -OO $DEPS/renpython/merge.py \
    $RENPY \
    linux-x86_64 \
    linux-i686 \
    darwin-x86_64
 
WINLIB=$RENPY/lib/windows-i686
    
try mkdir -p $WINLIB

try cp $DEPS/windows/zsync.exe $WINLIB
try cp $DEPS/windows/zsyncmake.exe $WINLIB
try cp $DEPS/windows/dxwebsetup.exe $RENPY/lib

