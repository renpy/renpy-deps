#!/usr/bin/env python

import argparse

# This script merges multiple renpython builds into a single lib directory.
# Files are taken from the first platform they appear in.

def main():
    
    ap = argparse.ArgumentParser()
    ap.add_argument("renpy", help="The path to Ren'Py.")
    ap.add_argument("platform", action="append")
    args = ap.parse_args()
    
    


if __name__ == "__main__":
    main()