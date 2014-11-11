#!/bin/sh

try () {
    "$@" || exit 1
}

. /opt/windows_32/bin/win-builds-switch 32
. /newbuild/env.sh

RENPY="${1:-/t/ab/renpy}"
DEPS="/t/ab/renpy-deps"
PYGAME_SDL2="${2:-/t/ab/pygame_sdl2}"
INCLUDE="/newbuild/install/include/pygame_sdl2"

rm -Rf "$PYTHONPATH/renpy"

set -e

export PYGAME_SDL2_INSTALL_HEADERS=1

cd "$PYGAME_SDL2"
python setup.py clean --all
python setup.py build --compiler=mingw32 install_lib -d $PYTHONPATH install_headers -d $INCLUDE

cd "$RENPY/module"
python setup.py clean
python setup.py build --compiler=mingw32 install_lib -d $PYTHONPATH
python -O "$DEPS/renpython/build.py" windows-i686 "$RENPY" renpy.py
