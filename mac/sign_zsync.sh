#!/bin/bash
set -e

mkdir -p zsync
cp ~/newbuild/install/bin/zsync zsync/zsync
cp ~/newbuild/install/bin/zsyncmake zsync/zsyncmake
xcrun codesign --options=runtime --timestamp --verbose -s "Developer ID Application: Tom Rothamel (XHTE5H7Z79)" -f --deep --no-strict zsync/*

cp zsync/zsync ~/newbuild/install/bin/zsync
cp zsync/zsyncmake ~/newbuild/install/bin/zsyncmake

# zip -r zsync.zip zsync
#
# xcrun altool --verbose --notarize-app --primary-bundle-id "org.renpy.zsync" -f zsync.zip --asc-provider XHTE5H7Z79 -u tom@rothamel.us -p "@keychain:altool"
