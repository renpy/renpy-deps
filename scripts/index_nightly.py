#!/usr/bin/env python

import os
import argparse
from jinja2 import Environment, FileSystemLoader, select_autoescape


def main():

    env = Environment(
        loader=FileSystemLoader(os.path.join(os.path.dirname(__file__), "templates")),
        autoescape=select_autoescape(['html', 'xml']),
    )

    ap = argparse.ArgumentParser()
    ap.add_argument("nightly")
    args = ap.parse_args()

    dirs = [ ]

    for i in os.listdir(args.nightly):
        if i.startswith("nightly-"):
            dirs.append(i)

    dirs.sort()
    dirs.reverse()

    tmpl = env.get_template("root.html")
    html = tmpl.render(dirs=dirs)

    with open(os.path.join(args.nightly, "index.html"), "w") as f:
        f.write(html)


if __name__ == "__main__":
    main()
