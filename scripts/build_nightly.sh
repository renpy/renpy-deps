#!/bin/bash

set -x

# For testing purposes, run this with ./build_nightly.sh ~/ab/renpy

try () {
    "$@" || exit 1
}

link () {
    if [ ! -L $2 ]; then
      try ln -s $1 $2
    fi
}

# Update the README.
try cp /home/tom/ab/renpy-deps/scripts/README.nightly /home/tom/ab/WWW.nightly/README.txt

try cd /home/tom/ab

# Check out the android build.

if [ -n "$1" -a -e nightly-android/.git ]; then
    try cd nightly-android
    try git pull

else
    rm -Rf nightly-android

    try git clone "git@github.com:renpy/rapt.git" \
        --reference /home/tom/ab/android nightly-android

    try cd nightly-android
fi

link /home/tom/ab/android/Sdk Sdk

try cd ..

# Activate the virtualenv for the prebuild.
. /home/tom/.virtualenvs/nightlyrenpy/bin/activate

# Check out pygame_sdl2.

if [ -n "$1" ] ; then
    if [ -e nightly-pygame_sdl2/.git ]; then
        try cd nightly-pygame_sdl2
        try git pull
    else
        try git clone /home/tom/ab/pygame_sdl2 --reference /home/tom/ab/pygame_sdl2 nightly-pygame_sdl2
        try cd nightly-pygame_sdl2
    fi
else
    rm -Rf nightly-pygame_sdl2
    try git clone https://github.com/renpy/pygame_sdl2.git --reference /home/tom/ab/pygame_sdl2 nightly-pygame_sdl2
    try cd nightly-pygame_sdl2
fi

try python setup.py install
try cd ..

# Check out Ren'Py.

if [ -n "$1" ] ; then

    if [ -e nightly-renpy/.git ]; then
        try cd nightly-renpy
        try git pull
    else
        try git clone /home/tom/ab/renpy --reference /home/tom/ab/renpy nightly-renpy
        try cd nightly-renpy
    fi
else
    rm -Rf nightly-renpy
	  try git clone https://github.com/renpy/renpy.git --reference /home/tom/ab/renpy nightly-renpy
    try cd nightly-renpy
fi

# Run the after checkout script.
try ./after_checkout.sh

link /home/tom/ab/WWW.nightly dl
link /home/tom/ab/nightly-android android
link /home/tom/ab/nightly-android/dist rapt
link /home/tom/ab/nightly-pygame_sdl2 pygame_sdl2
link /home/tom/ab/renpy/atom atom
link /home/tom/ab/renpy/editra editra
link /home/tom/ab/renpy/jedit jedit
link /home/tom/ab/renpy/renios renios

# Figure out a reasonable version name, and check that it doesn't already
# exist.
REV=$(git rev-parse --short HEAD)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ -z "$1" -a -e dl/*-$REV ]; then
  echo $REV has already been built.
  exit 0
fi

export RENPY_NIGHTLY="nightly-$(date +%Y-%m-%d)-$REV"

# Generate source.

export RENPY_CYTHON=cython
export RENPY_DEPS_INSTALL=/usr::/usr/lib/x86_64-linux-gnu/
export RENPY_SIMPLE_EXCEPTIONS=1

try ./run.sh tutorial quit

# Copy launcher over.
cp /home/tom/ab/renpy-deps/windows/launch/renpy.exe .

# Build Ren'Py for real.
try /home/tom/ab/renpy-deps/scripts/build_all.py -p nightly-renpy -s nightly-pygame_sdl2
unset RENPY_BUILD_ALL

# Build the documentation.
try cd /home/tom/ab/nightly-renpy/sphinx
try ./build.sh

# Run some basic tests.
try cd /home/tom/ab/nightly-renpy

try /home/tom/ab/renpy-deps/scripts/test_all.py --no-mac --no-linux -p nightly-renpy
try ./renpy.sh tutorial lint

if [ -n "$1" ]; then
    exit
fi

# Build the distribution.
try python -O distribute.py "$RENPY_NIGHTLY" --pygame /home/tom/ab/nightly-pygame_sdl2 --sign

# Create a symlink to the current nightly.
try cd /home/tom/magnetic/ab/WWW.nightly/
rm current
ln -s "$RENPY_NIGHTLY" current

rm renpy-nightly-sdk.zip
rm renpy-nightly-sdk.tar.bz2
ln -s current/renpy-*-sdk.zip renpy-nightly-sdk.zip
ln -s current/renpy-*-sdk.tar.bz2 renpy-nightly-sdk.tar.bz2

# Index the nightly.
try /home/tom/ab/renpy-deps/scripts/index_nightly.py /home/tom/magnetic/ab/WWW.nightly/

# Upload everything to the server.
try rsync -av /home/tom/magnetic/ab/WWW.nightly/ tom@abagail.onegeek.org:/home/tom/WWW.nightly --delete

# Delete old nightlies.
find /home/tom/magnetic/ab/WWW.nightly/ -ctime +30.5 -delete || true



