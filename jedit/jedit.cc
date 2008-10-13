#include <stdio.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char **argv) {
    char **args = new char *[argc + 3];

    args[0] = (char *) "javaw.exe";
    args[1] = (char *) "-jar";
    
    char *a2 = strdup(argv[0]);
    int a2len = strlen(a2);
                
    a2[a2len - 3] = 'j';
    a2[a2len - 2] = 'a';
    a2[a2len - 1] = 'r';

    args[2] = a2;

    for (int i = 1; i < argc; i++) {
        args[i + 2] = argv[i];
    }
    args[argc + 2] = NULL;

    execvp("javaw.exe", args);
}

