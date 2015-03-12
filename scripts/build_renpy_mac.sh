#!/bin/sh

BASE=/Users/tom
AB=/Volumes/ab
clean=${1:-clean}
RENPY="${2:-/Volumes/ab/renpy}"
PYGAME_SDL2="${3:-/Volumes/ab/pygame_sdl2}"
RENIOS="${4:-/Users/tom/ripe/renios}"

try () {
    "$@" || exit 1
}

if [ ! -e "$RENPY" ]; then
  osascript -e 'tell application "finder"' -e 'open location "cifs://eileen/ab"' -e 'end tell'
fi

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

unset RENPY_STEAM_SDK
unset RENPY_STEAM_PLATFORM

cd "$RENIOS"
[ $clean = noclean ] || ./build_all.sh

echo done.
