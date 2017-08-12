#!/bin/bash

set -e

IDENTITY="$1"
APP="$2"
APPBASE=$(basename $2)
APPDIR=$(dirname $2)
APPDIRBASE=$(basename $APPDIR)

TARBALL=$APPDIRBASE.tar

pushd $APPDIR
tar cf /tmp/$TARBALL $APPBASE
rsync -a /tmp/$TARBALL tom@mary12:/tmp

ssh -t tom@mary12.local "'/Users/tom/ab/renpy-deps/mac/mac_sign_server.sh' '$IDENTITY' '$TARBALL' '$APPBASE'"

rsync -a tom@mary12.local:/tmp/signed-$TARBALL /tmp
tar xf /tmp/signed-$TARBALL
popd


