#define UNICODE

#include <wchar.h>
#include <stdlib.h>
#include <malloc.h>
#include <windows.h>
#include <stdlib.h>

#ifndef PYTHON_DIR
#define PYTHON_DIR L"\\lib\\windows-i686\\"
#endif

#ifndef SCRIPT_DIR
#define SCRIPT_DIR L"\\"
#endif

#define PATHLEN 65536

/**
 * Quotes s so that it can be passed via the windows command line.
 */
wchar_t *quote(const wchar_t *s) {
	wchar_t *rv = (wchar_t *) malloc(sizeof(wchar_t) * 2 * wcslen(s));

	const wchar_t *src = s;
	wchar_t *dst = rv;

	*dst++ = L'"';

	while(*src) {
		if(*src == L'\\' || *src == L'"') {
			*dst++ = L'\\';
		}

		*dst++ = *src++;
	}

	*dst++ = L'"';
	*dst++ = 0;

	return rv;
}

int wmain(int argc, wchar_t **argv) {

	wchar_t *dirname = L".";
	wchar_t *basename;

	/* Compute dirname from argv0. */
	{
		wchar_t *argv0_copy;
		wchar_t *c;
		wchar_t *endc = NULL;

		argv0_copy = wcsdup(argv[0]);
		c = argv0_copy;
		basename = argv0_copy;

		while (*c) {
			if (*c == L'\\' || *c == L'/') {
				dirname = argv0_copy;
				endc = c;
			}

			c++;
		}

		if (endc) {
			*endc = 0;
			basename = endc + 1;
		}
	}

	/* If the basename ends with .exe, remove that. */
	{
		int dot = wcslen(basename) - 4;

		if (basename[dot] == L'.') {
			basename[dot] = 0;
		}
	}

	/* Figure out the path to python. */
	int dirnamelen = wcslen(dirname);
	wchar_t python[PATHLEN];

	wcscpy(python, dirname);
	wcscat(python, PYTHON_DIR);

#ifdef PYTHON
	wcscat(python, PYTHON);
#else
	wcscat(python, basename);
	wcscat(python, L".exe");
#endif

	/* Figure out the python script. */
	wchar_t script[PATHLEN];

	{
		wcscpy(script, dirname);
		wcscat(script, SCRIPT_DIR);

#ifdef SCRIPT
		wcscat(script, SCRIPT);
#else
		wcscat(script, basename);
		wcscat(script, L".py");
#endif
	}

	/* Set up the new arguments. */
	wchar_t *newargs[argc + 3];

	{
		int i;

		newargs[0] = quote(python);
		newargs[1] = quote(L"-EOO");
		newargs[2] = quote(script);

		for (i = 1; i < argc; i++) {
			newargs[2 + i] = quote(argv[i]);
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

	{
		wchar_t message[PATHLEN];
		wsprintf(message, L"Could not execute %ls. Is it missing?", python);

		MessageBoxW(
				NULL,
				message,
				argv[0],
				0);
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
