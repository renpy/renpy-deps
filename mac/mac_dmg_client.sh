#!/bin/bash

set -e

IDENTITY="$1"
VOLNAME="$2"
DMGDIR="$3"
DMGDIRBASE=$(basename $3)
DMG="$4"
DMGBASE=$(basename $4)

TARBALL=$DMGDIRBASE.tar

pushd $(dirname $DMGDIR)
tar cf /tmp/$TARBALL $DMGDIRBASE
popd

rsync -a /tmp/$TARBALL tom@mary12:/tmp

ssh -t tom@mary12 "'/Users/tom/ab/renpy-deps/mac/mac_dmg_server.sh' '$IDENTITY' '$VOLNAME' '$DMGDIRBASE' '$DMGBASE'"

rsync -a tom@mary12:/tmp/$DMGBASE $DMG


