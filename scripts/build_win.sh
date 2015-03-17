#!/bin/sh

try () {
    "$@" || exit 1
}

export PATH=/c/Python27:/c/Python27/Scripts:$PATH
export MINGW_ROOT_DIRECTORY=/c/mingw

. /opt/windows_32/bin/win-builds-switch 32

try cd /
# rm -Rf newbuild
mkdir -p /newbuild/install/bin
cd newbuild

try /t/ab/renpy-deps/build.sh

. env.sh

try /t/ab/renpy-deps/angle/build.sh

cp /newbuild/install/alt/bin/avcodec-??.dll /t/ab/patentfree/lib/windows-x86
cp /newbuild/install/alt/bin/avformat-??.dll /t/ab/patentfree/lib/windows-x86
cp /newbuild/install/alt/bin/avutil-??.dll /t/ab/patentfree/lib/windows-x86

# try sh /t/ab/build_renpy_win.sh
