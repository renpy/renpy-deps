#!/bin/bash

try () {
    "$@" || exit 1
}

# Check out Ren'Py.
try cd /home/tom/ab
rm -Rf nightly-renpy

try git clone \
    https://github.com/renpy/renpy.git \
    --reference /home/tom/ab/renpy \
    nightly-renpy

try cd nightly-renpy

# Symlink some files over.

try ln -s /home/tom/ab/WWW.nightly dl

# For debug purposes, copy some files over.
try cp /home/tom/ab/renpy/after_checkout.sh .
try cp /home/tom/ab/renpy/distribute.py .
try cp /home/tom/ab/renpy/launcher/game/options.rpy launcher/game

try ./after_checkout.sh

# Figure out a reasonable version name, and check that it doesn't already
# exist.
REV=$(git rev-parse --short HEAD)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ -e dl/*-$REV ]; then
  echo $REV has already been built.
  exit 0
fi

export RENPY_NIGHTLY="renpy-nightly-$(date +%Y-%m-%d)-$BRANCH-$REV"

# Build Ren'Py
. /home/tom/.virtualenvs/nightlyrenpy/bin/activate

export RENPY_CYTHON=cython
export RENPY_DEPS_INSTALL=/usr::/usr/lib/x86_64-linux-gnu/

try ./run.sh tutorial quit

try /home/tom/ab/renpy-deps/scripts/build_all.py -p nightly-renpy

# Build the documentation.
try cd /home/tom/ab/nightly-renpy/sphinx
try ./build.sh

# Build the distribution.
try cd /home/tom/ab/nightly-renpy
try python -O distribute.py --fast "$RENPY_NIGHTLY"

# Upload everything to the server.
try rsync -av /home/tom/magnetic/ab/WWW.nightly/ tom@erika.onegeek.org:/home/tom/WWW.nightly --delete


