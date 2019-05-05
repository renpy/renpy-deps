#!/bin/bash

set -xe

cd ${1:-/home/tom/ab/nightly-renpyweb}
renpyweb=${2:-/home/tom/ab/renpyweb}

git pull

rm -Rf build
cp -a $renpyweb/build build

cp -a $renpyweb/cache/* cache

rm -Rf python-emscripten
cp -a $renpyweb/python-emscripten .

rm -Rf install
cp -a $renpyweb/install .

