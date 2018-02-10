#!/bin/sh

set -ex

if [ -z "$1" ]; then
    echo "Need an atom version on the command line."
    exit
fi

VERSION="v$1"

rm -Rf atom-windows
rm -Rf Atom.app
rm -Rf atom-linux-x86_64

mkdir -p "dl/$VERSION"

download () {
    fn="dl/$VERSION/$1"
    if [ ! -e "$fn" ]; then
        wget -O "$fn" "https://github.com/atom/atom/releases/download/$VERSION/$1"
    fi
}

download atom-amd64.tar.gz
download atom-windows.zip
download atom-mac.zip

unzip "dl/$VERSION/atom-windows.zip"
mv Atom atom-windows

unzip "dl/$VERSION/atom-mac.zip"

tar xaf "dl/$VERSION/atom-amd64.tar.gz"
mv "atom-$1-amd64" "atom-linux-x86_64"
