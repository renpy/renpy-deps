#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    char jar[4096];
    char **args = new char *[argc + 2];

    args[0] = (char *) "javaw.exe";
    args[1] = (char *) "org.gjt.sp.jedit.jEdit";

    strncpy(jar, "CLASSPATH=", 4096);
    strncat(jar, argv[0], 4096);
    
    int jarlen = strlen(jar);
                
    jar[jarlen - 3] = 'j';
    jar[jarlen - 2] = 'a';
    jar[jarlen - 1] = 'r';

    putenv(jar);
        
    for (int i = 1; i < argc; i++) {
        args[i + 1] = argv[i];
    }
    args[argc + 1] = NULL;

    execvp("javaw.exe", args);
}

