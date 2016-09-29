#!/bin/bash

# This is called after each build is complete, to combine them into a single
# lib directory.


try () {
    "$@" || exit 1
}


DEPS="/home/tom/ab/renpy-deps"
RENPY="${1:-/home/tom/ab/renpy}"

set -ex

python -O "$DEPS/renpython/merge.py" \
    "$RENPY" \
    linux-x86_64 \
    linux-i686 \
    darwin-x86_64 \
    windows-i686

WINLIB="$RENPY/lib/windows-i686"

cp "$DEPS/windows/zsync.exe" "$WINLIB"
cp "$DEPS/windows/zsyncmake.exe" "$WINLIB"
cp "$DEPS/windows/dxwebsetup.exe" "$WINLIB"
cp "$DEPS/windows/say.vbs" "$WINLIB"

CONTENTS="$RENPY/renpy.app/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

if [ -e "$RENPY/renpy.app" ]; then
    rm -Rf "$RENPY/renpy.app"
fi

mkdir -p "$MACOS/lib"
mkdir -p "$RESOURCES"

cp -a "$RENPY/renpy.sh" "$MACOS/renpy"

cp -a "$RENPY/lib/darwin-x86_64" "$MACOS/lib"
mv "$MACOS/lib/darwin-x86_64/lib/python2.7" "$MACOS/lib/darwin-x86_64/Lib"
rmdir "$MACOS/lib/darwin-x86_64/lib"
mkdir -p "$MACOS/lib/darwin-x86_64/Modules"
echo "This file forces python to search Lib." > "$MACOS/lib/darwin-x86_64/Modules/Setup"

cp -a "$DEPS/mac/icon.icns" "$RESOURCES"
cp -a "$DEPS/mac/Info.plist" "$CONTENTS"
