set -ex

CFLAGS="$(sdl2-config --cflags) -Ic:/python27/include"
LDFLAGS="$(sdl2-config --libs) -Lc:/python27/libs -lpython27"

gcc -o main -std=c99 main.c $CFLAGS $LDFLAGS
cp main.exe /t/ab/renpy/lib/windows-i686/renpy.exe
/t/ab/renpy/lib/windows-i686/renpy.exe

# ./main.exe
