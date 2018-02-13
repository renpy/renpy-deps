#!/usr/bin/env python3

import os
import jinja2


D = os.path.dirname(__file__)


def main():
    env = jinja2.Environment(
        autoescape=jinja2.select_autoescape(default=False),
        block_start_string="<<%",
        block_end_string="%>>",
        variable_start_string="<<<",
        variable_end_string=">>>",
    )

    src = os.path.join(D, "language-renpy", "source", "renpy.tmpl.cson")
    dst = os.path.join(D, "language-renpy", "grammars", "renpy.cson")

    with open(src) as f:
        template = env.from_string(f.read())

    data = template.render()

    with open(dst, "w") as f:
        f.write(data)


if __name__ == "__main__":
    main()
