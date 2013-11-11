#!/bin/bash

cd /home/tom/ab/renpy-deps/scripts

if ./build_nightly.sh > /tmp/renpy_nightly.txt 2>&1; then
    true
else
    echo "Ren'Py nightly build failed."
    tail -20 /tmp/renpy_nightly.txt
fi
