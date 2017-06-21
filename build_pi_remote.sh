#!/bin/bash

set -ex

ROOT="$(readlink -f $(dirname $0))"
PIUSER="$1"


if [ -z PIUSER ]; then
    echo "usage: $0 <pi user>@<pi host>"
    exit 1
fi

ssh "$PIUSER" mkdir -p "~/newbuild"
rsync -av "$ROOT" "$PIUSER:~/newbuild"
ssh "$PIUSER" "~/newbuild/renpy-deps/build_pi.sh"

