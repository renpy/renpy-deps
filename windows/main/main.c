#include <stdio.h>
#include <stdarg.h>
#include <libgen.h>
#include <stdlib.h>
#include <string.h>

#include <windows.h>

#include <SDL.h>

#include <Python.h>

static char *argv0;

/* Reports an error message using a dialog box, then quits. */
static void error(const char *message, ...) {
	char message_buf[2048];
	char title_buf[2048];
	va_list args;
	va_start(args, message);

	vsnprintf(message_buf, 2048, message, args);
	snprintf(title_buf, 2048, "%s error", basename(argv0));

	SDL_ShowSimpleMessageBox(
		SDL_MESSAGEBOX_ERROR,
		title_buf,
		message_buf,
		NULL);

	exit(1);
}

/**
 * Finds the .py file. If this is main.exe, the .py file this finds is
 * ..\..\main.py.
 */
static char *find_py() {
	int full_path_size = GetFullPathName(argv0, 0, NULL, NULL);
	char full_path[full_path_size + 1];
	char *basename;
	char *dir;

	GetFullPathName(argv0, full_path_size + 1, full_path, &basename);

	dir = dirname(full_path);
	dir = dirname(dir);
	dir = dirname(dir);

	int i = strlen(basename) - 3;

	basename[i++] = 'p';
	basename[i++] = 'y';
	basename[i++] = 0;

	int rv_len = strlen(dir) + strlen(basename) + 2;
	char *rv = calloc(rv_len, 1);

	snprintf(rv, rv_len, "%s\\%s", full_path, basename);

	return rv;
}

int WINAPI WinMain(
	    HINSTANCE hInstance,      /* handle to current instance */
	    HINSTANCE hPrevInstance,  /* handle to previous instance */
	    LPSTR lpCmdLine,          /* pointer to command line */
	    int nCmdShow              /* show state of window */
	) {

	int argc = __argc;
	char **argv = __argv;

	/* Store argv0 so the other functions can use it. */
	argv0 = argv[0];

	char *py_filename = find_py();

	FILE *py_f = fopen(py_filename, "rb");
	if (! py_f) {
		error("%s: Could not open %s.", argv0, py_filename);
	}

	char *py_argv[argc + 1];

    py_argv[0] = py_filename;

    int py_argc = 1;

    for (int i = 1; i < argc; i++) {

    	// If called with the -EO <script> pattern, skip it. (For compatibility
    	// with upgrades from pre-6.99 Ren'Py.)

    	if (!strcmp(argv[i], "-EO") || !strcmp(argv[i], "-EOO") || !strcmp(argv[i], "-O") || !strcmp(argv[i], "-OO")) {
    		i += 1;
    		continue;
    	}

    	py_argv[py_argc++] = argv[i];
    }

    py_argv[py_argc] = NULL;

    Py_IgnoreEnvironmentFlag++;
    Py_OptimizeFlag++;

	Py_SetProgramName(argv0);
	Py_Initialize();
	PySys_SetArgvEx(py_argc, py_argv, 1);
    PyEval_InitThreads();

    PyRun_SimpleString(
    		"import sys, os\n"
    		"sys.renpy_executable = sys.executable\n"
    		"sys.executable = os.path.dirname(sys.executable) + '\\\\pythonw.exe'\n"
    		);

    return PyRun_SimpleFileEx(py_f, py_filename, 1);
}
