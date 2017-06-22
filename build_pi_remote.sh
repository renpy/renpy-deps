#!/bin/bash

set -e

ROOT="$(readlink -f $(dirname $0))"
PIUSER="$1"


if [ -z "$PIUSER" ]; then
    echo "usage: $0 <pi user>@<pi host>"
    exit 1
fi

ssh "$PIUSER" mkdir -p "~/newbuild"

rsync -aP "$ROOT" "$PIUSER:~/newbuild"

rsync -aP "/home/tom/ab/pygame_sdl2" "$PIUSER:~/newbuild"

for i in module renpy renpy.sh run.sh renpy.py launcher tutorial tutorial_7 the_question; do
    rsync -aP "/home/tom/ab/renpy/$i" "$PIUSER:~/newbuild/renpy"
done

ssh "$PIUSER" "~/newbuild/renpy-deps/build_pi.sh"
