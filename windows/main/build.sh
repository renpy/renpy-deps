set -e

CFLAGS="$(sdl2-config --cflags)"
LDFLAGS="$(sdl2-config --libs)"

gcc -o main main.c $CFLAGS $LDFLAGS
cp main.exe /t/ab/renpy/lib/windows-i686/renpy.exe
/t/ab/renpy/lib/windows-i686/renpy.exe

# ./main.exe
