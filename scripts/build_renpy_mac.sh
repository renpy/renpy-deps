#!/bin/sh

BASE=/Users/tom
AB=/Volumes/shared/ab
RENPY="${1:-/Volumes/shared/ab/renpy}"
PYGAME_SDL2="${2:-/Volumes/shared/ab/pygame_sdl2}"


try () {
    "$@" || exit 1
}

. "$BASE/newbuild/env.sh"

INCLUDE="$BASE/newbuild/install/include/pygame_sdl2"

export RENPY_CC="ccache gcc"
export RENPY_LD="ccache gcc"

set -e

export PYGAME_SDL2_INSTALL_HEADERS=1

cd "$PYGAME_SDL2"
python setup.py clean --all
python setup.py install_lib -d $PYTHONPATH install_headers -d $INCLUDE

cd "$RENPY/module"
python setup.py clean --all
python setup.py install_lib -d $PYTHONPATH

cd "$AB/renpy-deps/renpython"
python -O build.py darwin-x86_64 "$RENPY" renpy.py

echo done.
