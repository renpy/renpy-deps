#!/bin/sh

# Remember to update version in launcher.py.
VERSION=6.7.1

rm -Rf "Ren'Py Launcher $VERSION.i386.app"
rm -Rf "Ren'Py Launcher $VERSION.ppc.app"
rm -Rf "Ren'Py Launcher $VERSION.app"
rm -Rf newapp
rm -Rf "renpy-launcher-$VERSION.zip"
rm -Rf dist/
rm -Rf build/

try() {
    "$@" || exit -1
}

try chmod -R a+rX ~/newbuild.i386/install/
try chmod -R a+rX ~/newbuild.ppc/install/

. ~/newbuild.ppc/env.sh 
try python setup.py py2app
try mv "dist/Ren'Py Launcher.app" "Ren'Py Launcher $VERSION.app"
try macho_standalone "Ren'Py Launcher $VERSION".app
try chmod -R og+rX "Ren'Py Launcher $VERSION.app"
try mv "Ren'Py Launcher $VERSION.app" "Ren'Py Launcher $VERSION.ppc.app"

. ~/newbuild.i386/env.sh 
try python setup.py py2app
try mv "dist/Ren'Py Launcher.app" "Ren'Py Launcher $VERSION.app"
try macho_standalone "Ren'Py Launcher $VERSION".app
try chmod -R og+rX "Ren'Py Launcher $VERSION.app"
try mv "Ren'Py Launcher $VERSION.app" "Ren'Py Launcher $VERSION.i386.app"

try python merge_universal.py "Ren'Py Launcher $VERSION.i386.app" "Ren'Py Launcher $VERSION.ppc.app" newapp

try mv newapp "Ren'Py Launcher $VERSION.app"

ab=/Volumes/shared/ab

zip -9r "renpy-launcher-$VERSION.zip" "Ren'Py Launcher $VERSION.app"
cp "renpy-launcher-$VERSION.zip" $ab/website/renpy/dl/maclaunch
rm -Rf $ab/renpy/renpy.app
cp -Rp "Ren'Py Launcher $VERSION.app" $ab/renpy/renpy.app
chmod +x "$ab/renpy/renpy.app/Contents/MacOS/Ren'Py Launcher"
