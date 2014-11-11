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

try x86lucid /home/tom/ab/renpy-deps/scripts/build_linux_common.sh x86lucid-deps i686
try x64lucid /home/tom/ab/renpy-deps/scripts/build_linux_common.sh x64lucid-deps x86_64



