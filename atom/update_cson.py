#!/usr/bin/env python3

import os

D = os.path.dirname(__file__)


def main():
    src = os.path.join(D, "language-renpy", "source", "renpy.tmpl.cson")
    dst = os.path.join(D, "language-renpy", "grammars", "renpy.cson")

    with open(src) as f:
        data = f.read()

    with open(dst, "w") as f:
        f.write(data)


if __name__ == "__main__":
    main()
