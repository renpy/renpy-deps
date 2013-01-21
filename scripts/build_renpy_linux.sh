#!/bin/sh

try () {
    "$@" || exit 1
}

x86lucid () {
    schroot -p -c x86lucid -- "$@"
}

x64lucid () {
    schroot -p -c x64lucid -- "$@"
}

try x86lucid /home/tom/ab/renpy-deps/scripts/build_renpy_linux_common.sh x86lucid
try x64lucid /home/tom/ab/renpy-deps/scripts/build_renpy_linux_common.sh x64lucid


