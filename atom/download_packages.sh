#!/bin/bash

cd "$(dirname $0)"

apm() {
    atom-linux-x86_64/resources/app/apm/bin/apm "$@"
}

export ATOM_HOME="$(pwd)/.atom"


rm -Rf .atom/packages || true
apm install language-renpy renpy-dark-syntax renpy-light-syntax

rm -Rf default-dot-atom/packages|| true
cp -a .atom/packages default-dot-atom

