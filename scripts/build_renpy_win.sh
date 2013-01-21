#!/bin/sh

try () {
    "$@" || exit -1
}

try cd /newbuild
. env.sh

try cd /t/ab/renpy/module
# rm -Rf build/*win*
try sh ./build_win32.sh

# try cd /t/ab/renpy
# try python build_exe.py

strip_all () {
    if test -e "$1" ; then 
        try cd "$1"
        for i in *.dll; do
            case $i in
                libEGL.dll|libGLESv2.dll)
                    echo "not stripping $i"
                    ;;
                *)
                    echo "stripping $i"
                    if test -e "$i"; then 
                        try strip --only-keep-debug "$i" -o "$2/$i" 
                        try strip -g --keep-file-symbols "$i"
                    fi
                    ;;
            esac
        done
    fi
}

# strip_all /t/ab/renpy/lib/windows-x86 /t/ab/windebug
# strip_all /t/ab/patentfree/lib/windows-x86 /t/ab/windebug-patentfree
# echo done



