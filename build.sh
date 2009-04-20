#!/bin/bash

SOURCE=`dirname "$0"`
PWD=`pwd`
BUILD=$PWD/build
INSTALL=$PWD/install
export PATH="$INSTALL/bin:$PATH"
export LD_LIBRARY_PATH="$INSTALL/lib:/usr/local/lib"
export DYLIB_LIBRARY_PATH="$INSTALL/lib"
export DYLD_FRAMEWORK_PATH="$INSTALL/frameworks"

if python -c 'import sys; print sys.version; sys.exit(0)'; then
    echo "Python works."
else
    echo "Python could not be found. Please add the directory containing"
    echo "the python program to your PATH."
    exit 1
fi

# The xes are required to prevent msys from interpreting these as
# paths.
SOURCE=`python $SOURCE/norm_source.py "x$PWD" "x$SOURCE"`

CP='cp -pR'

echo
echo Source: $SOURCE
echo Build: $BUILD
echo Install: $INSTALL
echo

mkdir -p $BUILD
mkdir -p $INSTALL

# export CFLAGS="$CFLAGS -ggdb -I$INSTALL/include -I$INSTALL/include/freetype2"
# export CXXFLAGS="$CXXFLAGS -ggdb -I$INSTALL/include -I$INSTALL/include/freetype2"
# export LDFLAGS="-fPIC -ggdb -L$INSTALL/lib $LDFLAGS"

export CFLAGS="$CFLAGS -O3 -I$INSTALL/include -I$INSTALL/include/freetype2"
export CXXFLAGS="$CXXFLAGS -O3 -I$INSTALL/include -I$INSTALL/include/freetype2"
export LDFLAGS="-O3 -L$INSTALL/lib $LDFLAGS"


if [ "x$MSYSTEM" != "x" ]; then
  export CFLAGS="$CFLAGS -fno-strict-aliasing"
  export CXXFLAGS="$CXXFLAGS -fno-strict-aliasing"
fi

OLD_CC="$CC"
OLD_LD="$LD"
OLD_CXX="$CXX"
OLD_CXXLD="$CXXLD"
OLD_CFLAGS="$CFLAGS"
OLD_CXXFLAGS="$CXXFLAGS"
OLD_LDFLAGS="$LDFLAGS"
OLD_CXXLDFLAGS="$CXXLDFLAGS"

if [ `uname` = 'Darwin' ]; then
    MAC=yes
    NOALTIVEC=yes
else
    MAC=no
fi

export SED=sed
export RENPY_DEPS_INSTALL=$INSTALL

try () {
    "$@" || exit -1
}

libtool() {
    cp /usr/local/bin/libtool .
}

cd $BUILD

cat <<EOF > ../env.sh
export PATH="$PATH"
export RENPY_DEPS_INSTALL="$INSTALL"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export DYLIB_LIBRARY_PATH="$DYLIB_LIBRARY_PATH"
export DYLD_FRAMEWORK_PATH="$DYLD_FRAMEWORK_PATH"
export PYTHONPATH="$INSTALL/python"
EOF

# try cp "$SOURCE/gcc_version.c" "$BUILD"
# try gcc -c "$BUILD/gcc_version.c"

if [ \! -e built.sdl ]; then

   try mkdir -p "$INSTALL/include/asm"
   try touch "$INSTALL/include/asm/page.h"

   try tar xzf "$SOURCE/SDL-1.2.11.tar.gz"
   try cd "$BUILD/SDL-1.2.11"

   try patch -p0 < $SOURCE/sdl-windows-title.diff
   try patch -p0 < $SOURCE/sdl-staticgray.diff
   try patch -p0 < $SOURCE/sdl-no-asm-stretch.diff

   try ./configure --prefix="$INSTALL"  --disable-debug --disable-video-dummy --disable-video-fbcon

   try make
   try make install
   cd "$BUILD"
   touch built.sdl
fi


# This will be built shared on Linux and Mac by build_python, and 
# static on windows here.
if [ \! -e built.zlib ]; then
   try tar xvzf "$SOURCE/zlib-1.2.3.tar.gz"
   try cd "$BUILD/zlib-1.2.3"
   try ./configure --prefix="$INSTALL"
   try make
   try make install
   cd "$BUILD"
   touch built.zlib
fi


if [ \! -e built.freetype ]; then
   try tar xjf "$SOURCE/freetype-2.3.7.tar.bz2"
   try cd "$BUILD/freetype-2.3.7"

   try cp "$SOURCE/ftmodules.cfg" ./modules.cfg

   try ./configure --prefix="$INSTALL"

   try make modules
   try make
   try make install prefix="$INSTALL"
   cd "$BUILD"
   touch built.freetype
fi

if [ \! -e built.sdl_ttf ]; then
   try tar xvzf "$SOURCE/SDL_ttf-2.0.8.tar.gz"
   try cd "$BUILD/SDL_ttf-2.0.8"
   try ./configure --prefix="$INSTALL"

   try patch -p1 < "$SOURCE/no_freetype_internals.dpatch"

   try make
   try make install
   cd "$BUILD"
   touch built.sdl_ttf
fi


if [ \! -e built.jpeg ]; then
   try tar xvzf "$SOURCE/jpegsrc.v6b.tar.gz"
   try cd "$BUILD/jpeg-6b"
   try ./configure --prefix="$INSTALL"
   try make
   try make install-lib
   ranlib "$INSTALL/lib/libjpeg.a"
   cd "$BUILD"
   touch built.jpeg
fi


if [ \! -e built.png ]; then
   try tar xvzf "$SOURCE/libpng-1.2.8-config.tar.gz"
   try cd "$BUILD/libpng-1.2.8-config"
   try ./configure --prefix="$INSTALL" --enable-static -disable-shared
   try make
   try make install
   cd "$BUILD"
   touch built.png
fi

if [ \! -e built.sdl_image ]; then
   try tar xvzf "$SOURCE/SDL_image-1.2.7.tar.gz"
   try cd "$BUILD/SDL_image-1.2.7"
   try ./configure --prefix="$INSTALL" --disable-tif --enable-static --disable-shared --disable-jpg-shared --disable-png-shared
   try make
   try make install
   cd "$BUILD"
   touch built.sdl_image
fi


if [ \! -e built.pygame ]; then
    
   SDL=`sdl-config --cflags --libs | python -c 'import sys; sys.stdout.write(sys.stdin.read().replace("\n", " ").replace("-mwindows", ""))'`

   try tar xvf "$SOURCE/pygame-1.8.1release.tar.gz"
   try cd "$BUILD/pygame-1.8.1release"

   # try cp "$SOURCE/movie.c" src/
   try cp "$SOURCE/rwobject.c" src/
   try cp "$SOURCE/surflock.c" src/
   # try cp "$SOURCE/transform.c" src/
   # try cp "$SOURCE/sysfont.py" lib/
   try cp "$SOURCE/pygame-setup.py" setup.py
   # try cp "$SOURCE/alphablit.c" src/alphablit.c
   # try cp "$SOURCE/display.c" src/display.c
   try cp "$SOURCE/macosx.py" lib/macosx.py
   try cp "$SOURCE/pygame_init.py" lib/__init__.py
   # try cp "$SOURCE/config"*.py .

   try grep -v "install_parachute ()" src/base.c > src/base.c.new
   try mv src/base.c.new src/base.c

   try python "$SOURCE/edit.py" "$SOURCE/Setup" Setup @SDL@ "$SDL" @INSTALL@ "$INSTALL"
   
   if [ "x$MSYSTEM" != "x" ]; then
       try python setup.py build --compiler=mingw32 install_lib -d "$INSTALL/python"
       try cp "$INSTALL/bin/"*.dll "$INSTALL/python/pygame"
       try strip "$INSTALL/python/pygame/"*.dll
       try strip "$INSTALL/python/pygame/"*.pyd
   else
       try python setup.py build install_lib -d "$INSTALL/python"
   fi
   
   try cp lib/*.ico "$INSTALL/python/pygame"
   try cp lib/*.icns "$INSTALL/python/pygame"
   try cp lib/*.tiff "$INSTALL/python/pygame"
   try cp lib/*.ttf "$INSTALL/python/pygame"
   try cp lib/*.bmp "$INSTALL/python/pygame"

   try python setup.py install_headers -d "$INSTALL/include/pygame"

   cd "$BUILD"
   touch built.pygame
fi

if [ \! -e built.ffmpeg ]; then
   try tar xjf "$SOURCE/ffmpeg-0.5.tar.bz2" 
   try cd "$BUILD/ffmpeg-0.5"

   try patch -p0 < "$SOURCE/ffmpeg-ogg-size.patch"

   export CFLAGS="$CFLAGS -fno-common"
   export CXXFLAGS="$CXXFLAGS -fno-common"
   MEM_ALIGN_HACK="--enable-memalign-hack"

   try ./configure --prefix="$INSTALL" \
       --cc="${CC:-gcc}" \
       $FFMPEGFLAGS \
       $MEM_ALIGN_HACK \
       --enable-shared \
       --disable-encoders \
       --disable-muxers \
       --disable-bzlib \
       --disable-demuxers \
       --enable-demuxer=au \
       --enable-demuxer=avi \
       --enable-demuxer=flac \
       --enable-demuxer=m4v \
       --enable-demuxer=matroska \
       --enable-demuxer=mov \
       --enable-demuxer=mp3 \
       --enable-demuxer=mpegps \
       --enable-demuxer=mpegts \
       --enable-demuxer=mpegtsraw \
       --enable-demuxer=mpegvideo \
       --enable-demuxer=ogg \
       --enable-demuxer=wav \
       --disable-decoders \
       --enable-decoder=flac \
       --enable-decoder=mp2 \
       --enable-decoder=mp3 \
       --enable-decoder=mp3on4 \
       --enable-decoder=mpeg1video \
       --enable-decoder=mpeg2video \
       --enable-decoder=mpegvideo \
       --enable-decoder=msmpeg4v1 \
       --enable-decoder=msmpeg4v2 \
       --enable-decoder=msmpeg4v3 \
       --enable-decoder=mpeg4 \
       --enable-decoder=pcm_dvd \
       --enable-decoder=pcm_s16be \
       --enable-decoder=pcm_s16le \
       --enable-decoder=pcm_s8 \
       --enable-decoder=pcm_u16be \
       --enable-decoder=pcm_u16le \
       --enable-decoder=pcm_u8 \
       --enable-decoder=theora \
       --enable-decoder=vorbis \
       --enable-decoder=vp3 \
       --disable-parsers \
       --enable-parser=mpegaudio \
       --enable-parser=mpegvideo \
       --enable-parser=mpeg4video \
       --enable-parser=vp3 \
       --disable-protocols \
       --enable-protocol=file \
       --disable-devices \
       --disable-vdpau \
       --disable-vhook \
       --disable-bsfs 
       

   try make
   try make install

   try mkdir -p "$INSTALL/include/libswscale"
   try cp libswscale/swscale.h  "$INSTALL/include/libswscale"

   cd "$BUILD"
   touch built.ffmpeg
fi

echo
cat ../env.sh

