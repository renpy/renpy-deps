#!/bin/sh

set -e

PLATFORM="$1"
RENPY="${2:-/home/tom/ab/renpy}"
PYGAME_SDL2="${3:-/home/tom/ab/pygame_sdl2}"

DEPS="/home/tom/ab/renpy-deps"

. "/home/tom/ab/$PLATFORM-deps/env.sh"

INCLUDE="/home/tom/ab/$PLATFORM-deps/install/include/pygame_sdl2"

export PYGAME_SDL2_INSTALL_HEADERS=1

cd "$PYGAME_SDL2"
python setup.py clean --all
python setup.py install_lib -d $PYTHONPATH
python setup.py install_headers -d $INCLUDE

cd "$RENPY/module"
python setup.py clean --all
python setup.py install_lib -d $PYTHONPATH

cd "$DEPS/renpython"
python -O build.py linux-`arch` "$RENPY" renpy.py

# Give some time for processes to die before schroot unmounts us.
sleep 1
