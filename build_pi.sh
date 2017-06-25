#!/bin/bash

set -ex

ROOT="$(readlink -f $(dirname $0)/..)"

export RASPBERRY_PI=1

cd "$ROOT"
mkdir -p build


# Set up apt, and use it to get packages and sources.

if [ ! -e build/built.pi_apt ]; then

    echo deb-src http://archive.raspbian.org/raspbian/ jessie main contrib non-free rpi | sudo tee /etc/apt/sources.list.d/raspian.list

    sudo apt-get update
    sudo apt-get install -y build-essential ccache cython git
    sudo apt-get build-dep -y libsdl2-2.0-0

    touch build/built.pi_apt
fi


# Make sure we have pygame_sdl2.

if [ ! -e pygame_sdl2 ]  ; then
    git clone https://github.com/renpy/pygame_sdl2 pygame_sdl2
fi


# Make sure we have renpy.

if [ ! -e renpy ] ; then
    git clone https://github.com/renpy/renpy renpy
fi


# Build Python.

if [ ! -e build/built.pi_python ]; then

    ./renpy-deps/build_python.sh

    touch build/built.pi_python
fi


# Build Ren'Py Dependencies.

if [ ! -e build/built.pi_deps ]; then

    ./renpy-deps/build.sh

    touch build/built.pi_deps
fi

# Source in the built environment.

. env.sh


# Build pygame_sdl2.

export PYGAME_SDL2_INSTALL_HEADERS=1

export PYGAME_SDL2_CC="ccache gcc"
export PYGAME_SDL2_LD="ccache gcc"
export PYGAME_SDL2_CXX="ccache g++"

INCLUDE="$ROOT/install/include/pygame_sdl2"

pushd pygame_sdl2
python setup.py install_lib -d "$PYTHONPATH"
python setup.py install_headers -d "$INCLUDE"
popd


# Build Ren'Py.

export RENPY_RASPBERRY_PI=1

export RENPY_CC="ccache gcc"
export RENPY_LD="ccache gcc"
export RENPY_CXX="ccache g++"

pushd renpy/module
python setup.py install_lib -d "$PYTHONPATH"
popd

# Launch script.

cat > pi_renpy.sh <<EOT
#!/bin/sh
. "$ROOT/env.sh"
exec python -O "$ROOT/renpy/renpy.py" "\$@"
EOT

chmod +x pi_renpy.sh


# Build distro.

pushd "$ROOT/renpy-deps/renpython"
python -O build.py linux-`arch` "$ROOT/renpy" renpy.py
popd

rm -Rf renpy/lib
cp -a renpy/build/linux-armv7l/lib renpy
