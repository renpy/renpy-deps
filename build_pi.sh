#!/bin/bash

set -ex

export RASPBERRY_PI=1

cd ~/newbuild
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
