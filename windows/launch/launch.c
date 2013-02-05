#include <wchar.h>
#include <stdlib.h>
#include <malloc.h>

#ifndef COMMAND
#define COMMAND L"\\lib\\windows-i686\\pythonw.exe"
#endif


int wmain(int argc, wchar_t **argv) {

	wchar_t *dirname = L".";

	/* Compute dirname from argv0. */
	{
		wchar_t *argv0_copy;
		wchar_t *c;
		wchar_t *endc = NULL;

		argv0_copy = wcsdup(argv[0]);
		c = argv0_copy;

		while (*c) {
			if (*c == L'\\' || *c == L'/') {
				dirname = argv0_copy;
				endc = c;
			}

			c++;
		}

		if (endc) {
			*endc = 0;
		}
	}

	/* Figure out the path to python. */
	int dirnamelen = wcslen(dirname);
	wchar_t python[dirnamelen + 200];

	wcscpy(python, dirname);
	wcscat(python, COMMAND);

	/* Figure out the python script. */
	wchar_t script[wcslen(argv[0]) + 4];

	{
		wcscpy(script, argv[0]);

		int dot = wcslen(script) - 4;

		if (script[dot] == L'.') {
			script[dot] = 0;
		}

		wcscat(script, L".py");
	}

	/* Set up the new arguments. */
	wchar_t *newargs[argc + 3];

	{
		int i;

		newargs[0] = python;
		newargs[1] = L"-OO";
		newargs[2] = script;

		for (i = 1; i < argc; i++) {
			newargs[2 + i] = argv[i];
		}

		newargs[argc + 2] = NULL;
	}

	_wexecv(python, (const wchar_t *const *) newargs);

	wprintf(L"Failed to launch. Arguments are:\n");

	{
		int i;

		for (i = 0; i < argc + 3; i++) {
			if (newargs[i]) {
				wprintf(L"%d %ls\n", i, newargs[i]);
			} else {
				wprintf(L"%d NULL\n", i);
			}
		}
	}


//	wprintf(L"dirname = %ls\n", dirname);
//	wprintf(L"python = %ls\n", python);
//	wprintf(L"script = %ls\n", script);

}

void __wgetmainargs(int*,wchar_t***,wchar_t***,int,int*);
extern int _CRT_glob;

int main() {
	wchar_t **enpv, **argv;
	int argc, si = 0;
	__wgetmainargs(&argc, &argv, &enpv, _CRT_glob, &si); // this also creates the global variable __wargv
	return wmain(argc, argv);
}
