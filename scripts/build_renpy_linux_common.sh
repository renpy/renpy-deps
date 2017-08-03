#!/bin/sh

set -e

PLATFORM="$1"
clean=${2:-clean}
RENPY="${3:-/home/tom/ab/renpy}"
PYGAME_SDL2="${4:-/home/tom/ab/pygame_sdl2}"






case `arch` in
    x86_64)
        NEWBUILD="/home/tom/ab/$PLATFORM-deps"
        export RENPY_STEAM_SDK="${RENPY_STEAM_SDK:-/home/tom/ab/steam/sdk}"
        export RENPY_STEAM_PLATFORM=linux64
        ;;
    i686)
        NEWBUILD="/home/tom/ab/$PLATFORM-deps"
        export RENPY_STEAM_SDK="${RENPY_STEAM_SDK:-/home/tom/ab/steam/sdk}"
        export RENPY_STEAM_PLATFORM=linux32
        ;;
    armv7l)
        export RENPY_RASPBERRY_PI=1

        export PYGAME_SDL2_CC="ccache gcc"
        export PYGAME_SDL2_LD="ccache gcc"
        export PYGAME_SDL2_CXX="ccache g++"

        export RENPY_CC="ccache gcc"
        export RENPY_LD="ccache gcc"
        export RENPY_CXX="ccache g++"

        NEWBUILD="/home/pi/newbuild"
        ;;
    *)
        echo "Unknown platform" `arch`.
        exit 1
        ;;
esac

. "$NEWBUILD/env.sh"


DEPS="/home/tom/ab/renpy-deps"

if [ -n "$RENPY_STEAM_PLATFORM" ]; then
    cp "$RENPY_STEAM_SDK/redistributable_bin/$RENPY_STEAM_PLATFORM/libsteam_api.so" "$RENPY_DEPS_INSTALL/lib"
fi

INCLUDE="$NEWBUILD/install/include/pygame_sdl2"

export PYGAME_SDL2_INSTALL_HEADERS=1

cd "$PYGAME_SDL2"
[ $clean = noclean ] || python setup.py clean --all
python setup.py install_lib -d $PYTHONPATH
python setup.py install_headers -d $INCLUDE


cd "$RENPY/module"
[ $clean = noclean ] || python setup.py clean --all
python setup.py install_lib -d $PYTHONPATH

cd "$DEPS/renpython"
python -O build.py linux-`arch` "$RENPY" renpy.py

# Give some time for processes to die before schroot unmounts us.
sleep 1
