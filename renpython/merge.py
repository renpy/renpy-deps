#!/usr/bin/env python

import argparse
import shutil
import sys
import os

# This script merges multiple renpython builds into a single lib directory.
# Files are taken from the first platform they appear in.

def recursive_copy(src, dest):
    
    if os.path.isdir(src):
        if not os.path.exists(dest):
            os.mkdir(dest)
            
        for fn in os.listdir(src):
            recursive_copy(
                os.path.join(src, fn),
                os.path.join(dest, fn),
                )
            
        shutil.copystat(src, dest)

    else:
        shutil.copy2(src, dest)


def main():
    
    ap = argparse.ArgumentParser()
    ap.add_argument("renpy", help="The path to Ren'Py.")
    ap.add_argument("platform", nargs='+')
    args = ap.parse_args()
    
    renpy_path = os.path.abspath(args.renpy)
    platforms = list(args.platform)

    # If we reverse the platforms, then the files from the first platform
    # (the highest-priority) will overwrite the files from the second (lowest-priority).
    platforms.reverse()
    
    def renpy(*args):
        return os.path.join(renpy_path, *args)
    
    if not os.path.exists(renpy("renpy.py")):
        print("The first argument needs to be the path to renpy.")
        sys.exist(0)
        
    if os.path.isdir(renpy("lib")):
        shutil.rmtree(renpy("lib"))
        
    for i in platforms:
        recursive_copy(
            renpy("build", i, "lib"),
            renpy("lib"))
        
        


if __name__ == "__main__":
    main()