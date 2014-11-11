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

DEPS=/home/tom/ab/renpy-deps

try x86lucid "$DEPS/scripts/build_renpy_linux_common.sh" x86lucid "$1" "$2"
try x64lucid "$DEPS/scripts/build_renpy_linux_common.sh" x64lucid "$1" "$2"


