#!/bin/bash

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

    try cd python-for-android
    try git pull
    try cd ..

else
    rm -Rf nightly-android

    try git clone "git@github.com:renpy/rapt.git" \
        --reference /home/tom/ab/android nightly-android

    try cd nightly-android

    try git clone "git@github.com:renpytom/python-for-android.git" \
        --reference /home/tom/ab/android/python-for-android python-for-android
fi

try git submodule update --init
link /home/tom/ab/android/android-ndk-r8c android-ndk-r8c
link /home/tom/ab/android/android-sdk android-sdk

try cd ..

# Check out Ren'Py.

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

link /home/tom/ab/WWW.nightly dl
link /home/tom/ab/nightly-android android
link /home/tom/ab/nightly-android/dist/renpy rapt
link /home/tom/ab/renpy/editra editra
link /home/tom/ab/renpy/jedit jedit

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
export RENPY_SIMPLE_EXCEPTIONS=1

try ./run.sh tutorial quit

# Copy launcher over.
cp /home/tom/ab/renpy-deps/windows/launch/renpy.exe .

# Build Ren'Py for real.
try /home/tom/ab/renpy-deps/scripts/build_all.py -p nightly-renpy

# Build the documentation.
try cd /home/tom/ab/nightly-renpy/sphinx
try ./build.sh

# Run some basic tests.
try cd /home/tom/ab/nightly-renpy

try /home/tom/ab/renpy-deps/scripts/test_all.py -p nightly-renpy
try ./renpy.sh tutorial lint

if [ -n "$1" ]; then
    exit
fi

# Build the distribution.
try python -O distribute.py "$RENPY_NIGHTLY"

# Create a symlink to the current nightly.
try cd /home/tom/magnetic/ab/WWW.nightly/
rm current
ln -s "$RENPY_NIGHTLY" current

# Upload everything to the server.
try rsync -av /home/tom/magnetic/ab/WWW.nightly/ tom@erika.onegeek.org:/home/tom/WWW.nightly --delete

# Delete old nightlies.
find /home/tom/magnetic/ab/WWW.nightly/ -ctime +30 -delete


