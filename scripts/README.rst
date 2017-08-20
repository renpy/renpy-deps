=======
Scripts
=======

These are the scripts that I use to build Ren'Py on my
computer. They're specific to my computers, insofar as hostnames and
paths are hard-coded. Still, they might be useful for someone else
who wants to build Ren'Py on their computer.

The scripts are:

build_all.py
    A python script that manages the entire build process. This dispatches
    scripts to various computers to run them.

build_finish.sh
    This merges the results of multiple builds into Ren'Py's lib directory.

build_linux_common.sh
    Builds renpy-deps for a single Linux platform.

build_linux.sh
    Invokes build_linux_common.sh to build renpy-deps for PC
    Linux platforms.

build_mac.sh
    Builds renpy-deps for the mac platform.

build_nightly_email.py
    Runs build_nightly.sh and emails the output.

build_nightly.sh
    Creates a nightly build of Ren'Py by checking out Ren'Py and its
    various directories, building them all, testing the builds, building
    a distribution, and uploading it to the server.

build_win.sh
    Builds renpy-deps for the windows platform.

build_renpy_linux_common.sh
    Builds the Ren'Py modules for a single Linux platform.

build_renpy_linux.sh
    Invokes build_renpy_linux_common.sh to build renpy for the PC
    linux platforms.

build_renpy_mac.sh
    Builds the Ren'Py modules for the mac platform.

build_renpy_win.sh
    Builds the Ren'Py modules for the windows platform.

remote.py
    The server that build_all connect to on windows in order to

test_all.py
    Tests Ren'Py by running the testcase game on multiple computers.

