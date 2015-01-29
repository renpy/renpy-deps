#include <stdio.h>
#include <stdarg.h>
#include <libgen.h>
#include <stdlib.h>

#include <windows.h>

#include <SDL.h>
#include <SDL_main.h>

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

int main(int argc, char **argv) {
	/* Store argv0 so the other functions can use it. */
	argv0 = argv[0];

	char *py_filename = find_py();

	FILE *py_f = fopen(py_filename, "rb");
	if (! py_f) {
		error("Could not open %s.", py_filename);
	}

	char *py_argv[argc + 1];

    py_argv[0] = py_filename;

    for (int i = 1; i < argc; i++) {
    	py_argv[i] = argv[i];
    }

    py_argv[argc] = NULL;

    Py_IgnoreEnvironmentFlag++;
    Py_OptimizeFlag++;

	Py_SetProgramName(argv0);
	Py_Initialize();
	PySys_SetArgvEx(argc, py_argv, 1);
    PyEval_InitThreads();

    return PyRun_SimpleFileEx(py_f, py_filename, 1);
}
