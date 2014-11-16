#!/bin/bash


ROOT="$(dirname $0)"
INSTALL="$RENPY_DEPS_INSTALL"

set -e

cd $ROOT

gcc -E -xc-header -I. EGL/egl.h > preprocessed_egl.h
pexports -h preprocessed_egl.h -o libegl.dll > libEGL.def
dlltool -d libEGL.def -l"$INSTALL/lib/libEGL.a" -k

gcc -E -xc-header -I. GLES2/gl2.h > preprocessed_gl2.h
pexports -h preprocessed_gl2.h -o libglesv2.dll > libGLESv2.def
dlltool -d libGLESv2.def -l"$INSTALL/lib/libGLESv2.a" -k

# These headers don't change very often.
if [ ! -e "$INSTALL/include/EGL" ]; then
    cp -r EGL KHR GLES2 GLSLANG "$INSTALL/include"
fi

cp *.dll "$INSTALL/bin"

gcc -o test.exe test.c -I$INSTALL/include -lGLESv2 -lEGL `sdl2-config --cflags --libs` -mconsole

