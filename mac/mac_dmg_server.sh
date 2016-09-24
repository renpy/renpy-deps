#!/bin/bash

set -e

IDENTITY="$1"
VOLNAME="$2"
DMGDIRBASE="$3"
DMGBASE="$4"

security unlock-keychain -p "$(cat ~/.password)"

pushd /tmp

rm -Rf "$DMGDIRBASE" || true
tar xf "$DMGDIRBASE.tar"

hdiutil create -format UDBZ -ov -volname "$VOLNAME" -srcfolder "$DMGDIRBASE" "$DMGBASE"
codesign --verbose -s "$1" "$DMGBASE"

popd
