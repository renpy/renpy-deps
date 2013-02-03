#!/bin/sh

try () {
    "$@" || exit 1
}

DIR=$1
CPU=$2

mkdir /home/tom/ab/$DIR
try cd /home/tom/ab/$DIR
try /home/tom/ab/renpy-deps/build_python.sh
try /home/tom/ab/renpy-deps/build.sh

. /home/tom/ab/$DIR/env.sh

mkdir -p /home/tom/ab/patentfree/lib/linux-$CPU/lib
cp /home/tom/ab/$DIR/install/alt/lib/libavcodec.so.?? /home/tom/ab/patentfree/lib/linux-$CPU/lib
cp /home/tom/ab/$DIR/install/alt/lib/libavformat.so.?? /home/tom/ab/patentfree/lib/linux-$CPU/lib
cp /home/tom/ab/$DIR/install/alt/lib/libavutil.so.?? /home/tom/ab/patentfree/lib/linux-$CPU/lib
chmod +x /home/tom/ab/patentfree/lib/linux-$CPU/lib/*

echo You still need to build py4renpy.
