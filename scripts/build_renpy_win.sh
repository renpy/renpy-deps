#!/bin/sh

try () {
    "$@" || exit 1
}

. /opt/windows_32/bin/win-builds-switch 32
. /newbuild/env.sh

clean=${1:-clean}
DEPS="/t/ab/renpy-deps"
RENPY="${2:-/t/ab/renpy}"
PYGAME_SDL2="${3:-/t/ab/pygame_sdl2}"
INCLUDE="/newbuild/install/include"
export CFLAGS="-I$INCLUDE"

rm -Rf "$PYTHONPATH/renpy"

export MSYSTEM=MINGW32

set -e

export PYGAME_SDL2_INSTALL_HEADERS=1
export CFLAGS="-I$INCLUDE"

export RENPY_STEAM_SDK="${RENPY_STEAM_SDK:-/t/ab/steam/sdk}"
export RENPY_STEAM_PLATFORM=

cd "$PYGAME_SDL2"
[ $clean = noclean ] || python setup.py clean --all
python setup.py build --compiler=mingw32 install_lib -d $PYTHONPATH install_headers -d $INCLUDE/pygame_sdl2

unset CFLAGS

cd "$RENPY/module"
[ $clean = noclean ] || python setup.py clean --all
python setup.py build --compiler=mingw32 install_lib -d $PYTHONPATH
python -O "$DEPS/renpython/build.py" windows-i686 "$RENPY" renpy.py

cp "$DEPS/windows/main/main.exe" "$RENPY/build/windows-i686/lib/windows-i686/renpy.exe"
