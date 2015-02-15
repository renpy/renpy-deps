set -ex

CFLAGS="$(sdl2-config --cflags) -Ic:/python27/include"
LDFLAGS="$(sdl2-config --libs) -Lc:/python27/libs -lpython27"

# . /opt/windows_32/bin/win-builds-switch 32

windres -o renpy_icon.o renpy_icon.rc
gcc -c main.c -std=c99 $CFLAGS
gcc -o main renpy_icon.o main.o $LDFLAGS
cp main.exe /t/ab/renpy/lib/windows-i686/renpy.exe
/t/ab/renpy/lib/windows-i686/renpy.exe

# ./main.exe
