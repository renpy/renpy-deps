%.o: %.rc %.ico
	i586-mingw32msvc-windres -o $*.o $*.rc

renpy.exe: launch.c renpy_icon.ico
	i586-mingw32msvc-gcc -o renpy.exe launch.c renpy_icon.o -mwindows

install: renpy.exe		
	cp renpy.exe /home/tom/ab/renpy
		