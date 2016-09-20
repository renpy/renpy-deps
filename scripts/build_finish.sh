#!/bin/bash

# This is called after each build is complete, to combine them into a single
# lib directory.


try () {
    "$@" || exit 1
}


DEPS="/home/tom/ab/renpy-deps"
RENPY="${1:-/home/tom/ab/renpy}"

set -e

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

MACOS="$RENPY/renpy.app/Contents/MacOS"

rm "$MACOS/renpy" || true
cp -a "$RENPY/renpy.sh" "$MACOS/renpy"

rm -Rf "$MACOS/lib/darwin-x86_64" || true
cp -a "$RENPY/lib/darwin-x86_64" "$MACOS/lib"

mv "$MACOS/lib/darwin-x86_64/lib/python2.7" "$MACOS/lib/darwin-x86_64/Lib"
rmdir "$MACOS/lib/darwin-x86_64/lib"
mkdir "$MACOS/lib/darwin-x86_64/Modules"
echo "This file forces python to search Lib." > "$MACOS/lib/darwin-x86_64/Modules/Setup"
