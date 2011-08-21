#!/bin/bash


try () {
    "$@" || exit -1
}

ROOT="$(dirname $0)"
INSTALL="$RENPY_DEPS_INSTALL"

try cd $ROOT

try dlltool -d libEGL.def -l"$INSTALL/lib/libEGL.a" -k
try dlltool -d libGLESv2.def -l"$INSTALL/lib/libGLESv2.a" -k

# These headers don't change very often.
if [ ! -e "$INSTALL/include/EGL" ]; then 

    try cp -r EGL KHR GLES2 GLSLANG "$INSTALL/include"

fi

try cp *.dll "$INSTALL/bin"

