%.o: %.rc %.ico
	i586-mingw32msvc-windres -o $*.o $*.rc

renpy.exe: launch.c renpy_icon.o
	i586-mingw32msvc-gcc -o renpy.exe launch.c renpy_icon.o -mwindows
	i586-mingw32msvc-strip renpy.exe

editra.exe: launch.c editra_icon.o
	i586-mingw32msvc-gcc -o editra.exe launch_editra.c editra_icon.o -DEDITRA -DSCRIPT_DIR=L\"\\\\Editra\\\\\" -DSCRIPT=L\"editra\" -DPYTHON=L\"pythonw.exe\" -mwindows
	i586-mingw32msvc-strip editra.exe
	
install: renpy.exe editra.exe
	cp renpy.exe /home/tom/ab/renpy
	cp editra.exe /home/tom/ab/renpy/editra
		
clean:
	-rm renpy.exe
	-rm editra.exe
	