#!/bin/bash

try () {
    "$@" || exit -1
}

INSTALL="$RENPY_DEPS_INSTALL"


try dlltool -d libEGL.def -l"$INSTALL/lib/libEGL.a" -k
try dlltool -d libGLESv2.def -l"$INSTALL/lib/libGLESv2.a" -k

rm -Rf "$INSTALL/include/EGL"
rm -Rf "$INSTALL/include/KHR"
rm -Rf "$INSTALL/include/GLES2"
rm -Rf "$INSTALL/include/GLSLANG"

try cp -r EGL KHR GLES2 GLSLANG "$INSTALL/include"
try cp *.dll "$INSTALL/bin"

# gcc -o test test.c \
#     -I/newbuild/install/include -I. -L/newbuild/install/lib \
#     -lmingw32 -lSDLmain -lSDL -mconsole \
#     -L. -lEGL -lGLESv2
