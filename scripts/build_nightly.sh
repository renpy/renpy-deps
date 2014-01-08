#!/bin/bash

# For testing purposes, run this with ./build_nightly.sh ~/ab/renpy

try () {
    "$@" || exit 1
}

# Update the README.
try cp /home/tom/ab/renpy-deps/scripts/README.nightly /home/tom/ab/WWW.nightly/README.txt

# Check out Ren'Py.
try cd /home/tom/ab

if [ -n "$1" ] ; then
    if [ -e nightly-renpy/.git ]; then
        try cd nightly-renpy
        try git pull
    else
        try git clone "$1" --reference /home/tom/ab/renpy nightly-renpy
        try cd nightly-renpy
    fi
else
    rm -Rf nightly-renpy

	try git clone \
	    https://github.com/renpy/renpy.git \
	    --reference /home/tom/ab/renpy \
	    nightly-renpy

    try cd nightly-renpy
fi

# Run the after checkout script.
try ./after_checkout.sh

# Figure out a reasonable version name, and check that it doesn't already
# exist.
REV=$(git rev-parse --short HEAD)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ -z "$1" -a -e dl/*-$REV ]; then
  echo $REV has already been built.
  exit 0
fi

export RENPY_NIGHTLY="renpy-nightly-$(date +%Y-%m-%d)-$BRANCH-$REV"

# Generate source.
. /home/tom/.virtualenvs/nightlyrenpy/bin/activate

export RENPY_CYTHON=cython
export RENPY_DEPS_INSTALL=/usr::/usr/lib/x86_64-linux-gnu/

try ./run.sh tutorial quit

# Build Ren'Py for real.
try /home/tom/ab/renpy-deps/scripts/build_all.py -p nightly-renpy

# Build the documentation.
try cd /home/tom/ab/nightly-renpy/sphinx
try ./build.sh

# Run some basic tests.
try cd /home/tom/ab/nightly-renpy

export RENPY_AUTOTEST=1

try ./renpy.sh tutorial lint
try ./renpy.sh testcases

if [ -n "$1" ]; then
    exit
fi

# Build the distribution.
try cd /home/tom/ab/nightly-renpy
try ln -s /home/tom/ab/WWW.nightly dl
try python -O distribute.py --fast "$RENPY_NIGHTLY"

# Upload everything to the server.
try rsync -av /home/tom/magnetic/ab/WWW.nightly/ tom@erika.onegeek.org:/home/tom/WWW.nightly --delete


