#!/bin/sh

BASE=/Users/tom
AB=/Users/tom/ab
clean=${1:-clean}
RENPY="${2:-/Users/tom/ab/renpy}"
PYGAME_SDL2="${3:-/Users/tom/ab/pygame_sdl2}"
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

export PYGAME_SDL2_CC="ccache gcc"
export PYGAME_SDL2_LD="ccache gcc"
export PYGAME_SDL2_CXX="ccache g++"

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

cd "$RENPY"
cp "$RENPY_STEAM_SDK/redistributable_bin/$RENPY_STEAM_PLATFORM/libsteam_api.dylib" "build/darwin-x86_64/lib/darwin-x86_64/"
chmod a+x "build/darwin-x86_64/lib/darwin-x86_64/libsteam_api.dylib"
install_name_tool -change "@loader_path/libsteam_api.dylib" "@executable_path/libsteam_api.dylib" "build/darwin-x86_64/lib/darwin-x86_64/lib/python2.7/_renpysteam.so"

unset RENPY_CC
unset RENPY_LD
unset RENPY_CXX

unset RENPY_STEAM_SDK
unset RENPY_STEAM_PLATFORM

export XCODEAPP=~/Xcode.app

cd "$RENIOS"
[ $clean = noclean ] || ./build_all.sh

echo done.
