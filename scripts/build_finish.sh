#!/bin/bash

# This is called after each build is complete, to combine them into a single
# lib directory.

python -OO /home/tom/ab/renpy-deps/renpython/merge.py \
  /home/tom/ab/renpy \
  linux-x86_64 \
  linux-i686 \
  darwin-x86_64
  