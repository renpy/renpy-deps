#!/bin/bash

set -ex

ROOT="$(readlink -f $(dirname $0)/..)"

export RASPBERRY_PI=1
export RENPY_RASPBERRY_PI=1

cd "$ROOT"
mkdir -p build

if [ ! -e build/built.pi_apt ]; then

    echo deb-src http://archive.raspbian.org/raspbian/ jessie main contrib non-free rpi | sudo tee /etc/apt/sources.list.d/raspian.list

    sudo apt-get update
    sudo apt-get install -y build-essential ccache
    sudo apt-get build-dep -y libsdl2-2.0-0

    touch build/built.pi_apt
fi


if [ ! -e build/built.pi_python ]; then

    ./renpy-deps/build_python.sh

    touch build/built.pi_python
fi


if [ ! -e build/built.pi_deps ]; then

    ./renpy-deps/build.sh

    touch build/built.pi_deps
fi

. env.sh

export PYGAME_SDL2_INSTALL_HEADERS=1

INCLUDE="$ROOT/install/include/pygame_sdl2"

pushd pygame_sdl2
python setup.py install_lib -d "$PYTHONPATH"
python setup.py install_headers -d "$INCLUDE"
popd


pushd renpy/module
python setup.py install_lib -d "$PYTHONPATH"
popd
