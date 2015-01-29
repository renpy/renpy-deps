#!/bin/sh

set -e

PLATFORM="$1"
clean=${2:-clean}
RENPY="${3:-/home/tom/ab/renpy}"
PYGAME_SDL2="${4:-/home/tom/ab/pygame_sdl2}"

export RENPY_STEAM_SDK=/home/tom/ab/steam/sdk
case `arch` in
    x86_64)
        export RENPY_STEAM_PLATFORM=linux64
        ;;
    i686)
        export RENPY_STEAM_PLATFORM=linux32
        ;;
    *)
        echo "Unknown platform" `arch`.
esac


DEPS="/home/tom/ab/renpy-deps"

. "/home/tom/ab/$PLATFORM-deps/env.sh"

INCLUDE="/home/tom/ab/$PLATFORM-deps/install/include/pygame_sdl2"

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
