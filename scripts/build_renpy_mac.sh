#!/bin/sh

BASE=/Users/tom
AB=/Volumes/shared/ab
clean=${1:-clean}
RENPY="${2:-/Volumes/shared/ab/renpy}"
PYGAME_SDL2="${3:-/Volumes/shared/ab/pygame_sdl2}"
RENIOS="${4:-/Users/tom/ripe/renios}"

try () {
    "$@" || exit 1
}

. "$BASE/newbuild/env.sh"

INCLUDE="$BASE/newbuild/install/include/pygame_sdl2"

export RENPY_CC="ccache gcc"
export RENPY_LD="ccache gcc"
export RENPY_CXX="ccache g++"

set -e

export PYGAME_SDL2_INSTALL_HEADERS=1
export RENPY_STEAM_SDK=$AB/steam/sdk
export RENPY_STEAM_PLATFORM=osx32

cd "$PYGAME_SDL2"
[ $clean = noclean ] || python setup.py clean --all
python setup.py install_lib -d $PYTHONPATH install_headers -d $INCLUDE

cd "$RENPY/module"
[ $clean = noclean ] || python setup.py clean --all
python setup.py install_lib -d $PYTHONPATH

cd "$AB/renpy-deps/renpython"
python -O build.py darwin-x86_64 "$RENPY" renpy.py

unset RENPY_CC
unset RENPY_LD
unset RENPY_CXX

cd "$RENIOS"
./build_all.sh

echo done.
