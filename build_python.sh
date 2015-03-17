#!/bin/bash

SOURCE=`dirname "$0"`/source
PWD=`pwd`
BUILD=$PWD/build
INSTALL=$PWD/install

# The xes are required to prevent msys from interpreting these as
# paths. (We use the system python to do this normalization.)
SOURCE=`python $SOURCE/norm_source.py "x$PWD" "x$SOURCE"`

export LD_LIBRARY_PATH="$INSTALL/lib"
export DYLIB_LIBRARY_PATH="$INSTALL/lib"
export DYLD_FRAMEWORK_PATH="$INSTALL/frameworks"

PYFRAMEWORK="$DYLD_FRAMEWORK_PATH/Python.framework/Versions/2.7"

export PATH="$INSTALL/bin:$PATH"

CP='cp -pR'

echo
echo Source: $SOURCE
echo Build: $BUILD
echo Install: $INSTALL
echo

mkdir -p $BUILD
mkdir -p $INSTALL

export CC=${CC:=gcc}
export CXX=${CXX:=g++}
export LD=${LD:=gcc}
export CXXLD=${CXXLD:=g++}

export CFLAGS="$CFLAGS -O3 -I$INSTALL/include"
export CXXFLAGS="$CXXFLAGS -O3 -I$INSTALL/include"
export LDFLAGS="$LDFLAGS -O3 -L$INSTALL/lib"

if [ `arch` = "x86_64" ]; then
    export CFLAGS="-fPIC $CFLAGS"
    export CXXFLAGS="-fPIC $CXXFLAGS"
    export LDFLAGS="-fPIC $LDFLAGS"
fi

# export CFLAGS="$CFLAGS -ggdb -I$INSTALL/include"
# export CXXFLAGS="$CXXFLAGS -ggdb -I$INSTALL/include"
# export LDFLAGS="$LDFLAGS -ggdb -L$INSTALL/lib"
# echo warning debug build; sleep 3

if [ "x$MSYSTEM" != "x" ]; then
  export CFLAGS="$CFLAGS -fno-strict-aliasing"
  export CXXFLAGS="$CXXFLAGS -fno-strict-aliasing"
fi

export SED=sed
export RENPY_DEPS_INSTALL=$INSTALL

if [ `uname` = 'Darwin' ]; then
    MAC=yes
    PATH="$PYFRAMEWORK/bin:$PATH"
else
    MAC=no
fi


try () {
    "$@" || exit 1
}

cd $BUILD

if [ \! -e built.zlib ]; then
   try tar xvzf "$SOURCE/zlib-1.2.6.tar.gz"
   try cd "$BUILD/zlib-1.2.6"
   try ./configure --prefix="$INSTALL" --shared
   try make
   try make install
   cd "$BUILD"
   touch built.zlib
fi

if [ \! -e built.bz2 ]; then

    try tar xvzf "$SOURCE/bzip2-1.0.6.tar.gz"
    try cd "$BUILD/bzip2-1.0.6"

    try make CFLAGS="$CFLAGS -Wall -Winline -D_FILE_OFFSET_BITS=64" LDFLAGS="$LDFLAGS" CC="$CC" LD="$LD" CXX="$CXX" CXXLD="$CXXLD"
    try make install PREFIX="$INSTALL"
    try cd "$BUILD"
    try touch built.bz2
fi

if [ \! -e built.python ]; then

    try tar xzf "$SOURCE/Python-2.7.9.tgz"
    try cd "$BUILD/Python-2.7.9"

    if [ $MAC = "yes" ]; then
        # try ./configure --prefix="$INSTALL" --enable-framework="$DYLD_FRAMEWORK_PATH"
        try ./configure --prefix="$INSTALL" --enable-shared --enable-unicode=ucs4  #-with-universal-archs=x86_64 --enable-universalsdk=$SDKROOT
    else
        try ./configure --prefix="$INSTALL" --enable-shared --enable-unicode=ucs4
    fi

    try make
    try make install
    try cd "$BUILD"
    try touch built.python
fi

hash -r python

set -e

pysetup() {
    name="$1"
    version="$2"

    echo $name

    if [ \! -e built.$name ]; then
	    tar xzf "$SOURCE/$name-$version.tar.gz"
	    cd "$BUILD/$name-$version"

	    python setup.py install

	    cd "$BUILD"
	    touch built.$name
	fi
}

pysetup setuptools 7.0
pysetup pyasn1 0.1.7
pysetup rsa 3.1.4
pysetup altgraph 0.12
pysetup macholib 1.7

exit 0
