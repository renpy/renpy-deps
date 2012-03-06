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

# Unix debug
# export CFLAGS="$CFLAGS -ggdb -I$INSTALL/include -I$INSTALL/include/freetype2 -fPIC"
# export CXXFLAGS="$CXXFLAGS -ggdb -I$INSTALL/include -I$INSTALL/include/freetype2 -fPIC"
# export LDFLAGS="-ggdb -L$INSTALL/lib $LDFLAGS -fPIC"
# echo warning debug build; sleep 3

# Windows debug
# export CFLAGS="$CFLAGS -gstabs -I$INSTALL/include -I$INSTALL/include/freetype2"
# export CXXFLAGS="$CXXFLAGS -gstabs -I$INSTALL/include -I$INSTALL/include/freetype2"
# export LDFLAGS="-gstabs -L$INSTALL/lib $LDFLAGS"
# echo warning debug build; sleep 3

# Production
export CFLAGS="$CFLAGS -O3 -I$INSTALL/include -I$INSTALL/include/freetype2"
export CXXFLAGS="$CXXFLAGS -O3 -I$INSTALL/include -I$INSTALL/include/freetype2"
export LDFLAGS="-O3 -L$INSTALL/lib $LDFLAGS"

if [ "x$MSYSTEM" != "x" ]; then
    export CFLAGS="$CFLAGS -fno-strict-aliasing "
    export CXXFLAGS="$CXXFLAGS -fno-strict-aliasing "
else
    if [ `arch` = "x86_64" ]; then
        export CFLAGS="-fPIC $CFLAGS"
        export CXXFLAGS="-fPIC $CFLAGS"
        export LDFLAGS="-fPIC $CFLAGS"
    fi
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

try mkdir -p "$INSTALL/lib"
rm -Rf "$INSTALL/lib64"
try ln -s "$INSTALL/lib" "$INSTALL/lib64"

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

if [ \! -e built.nasm ]; then
    try tar xzf "$SOURCE/nasm-2.09.10.tar.gz"
    try cd "$BUILD/nasm-2.09.10"
    try ./configure --prefix="$INSTALL"
    try make
    try make install
    cd "$BUILD"
    try touch built.nasm
fi

if [ \! -e built.yasm ]; then
    try tar xzf "$SOURCE/yasm-1.1.0.tar.gz"
    try cd "$BUILD/yasm-1.1.0"
    try ./configure --prefix="$INSTALL"
    try make
    try make install
    cd "$BUILD"
    try touch built.yasm
fi

if [ \! -e built.sdl ]; then

   try mkdir -p "$INSTALL/include/asm"
   try touch "$INSTALL/include/asm/page.h"

   try tar xzf "$SOURCE/SDL-1.2.13.tar.gz"
   try cd "$BUILD/SDL-1.2.13"

   try patch -p0 < $SOURCE/sdl-windows-title.diff
   try patch -p0 < $SOURCE/sdl-staticgray.diff
   try patch -p0 < $SOURCE/sdl-audio-order.diff

   # On windows, we have the problem that maximizing causes the start
   # button to overlap the GL window, making performance lousy, so we
   # disable maximize.
   try patch -p0 < $SOURCE/sdl-no-windows-maximize.diff 
   
   # try patch -p0 < $SOURCE/sdl-no-asm-stretch.diff

   try ./configure --prefix="$INSTALL" --disable-debug --disable-video-dummy --disable-video-fbcon --disable-nas $SDL_ASM

   try make
   try make install
   cd "$BUILD"
   touch built.sdl
fi


# This will be built shared on Linux and Mac by build_python, and 
# on windows here.
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
   try tar xzf "$SOURCE/freetype-2.3.11.tar.gz"
   try cd "$BUILD/freetype-2.3.11"

   # try cp "$SOURCE/ftmodules.cfg" ./modules.cfg

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

if [ \! -e built.jpegturbo ]; then
    try tar xzf "$SOURCE/libjpeg-turbo-1.1.1.tar.gz"
    try cd "$BUILD/libjpeg-turbo-1.1.1"
    try ./configure --prefix="$INSTALL" $JPEG_ASM
    try make
    try make install
    cd "$BUILD"
    try touch built.jpegturbo
fi

# if [ $MAC = yes -a \! -e built.jpeg ]; then
#    try tar xvzf "$SOURCE/jpegsrc.v6b.tar.gz"
#    try cd "$BUILD/jpeg-6b"
#    try ./configure --prefix="$INSTALL"
#    try make
#    try make install-lib
#    ranlib "$INSTALL/lib/libjpeg.a"
#    cd "$BUILD"
#    touch built.jpeg
# fi


if [ \! -e built.png ]; then
   export CFLAGS="$CFLAGS -DPNG_NO_WRITE_tIME"

   try tar xvzf "$SOURCE/libpng-1.2.8-config.tar.gz"
   try cd "$BUILD/libpng-1.2.8-config"
   try ./configure --prefix="$INSTALL" --enable-shared --enable-static
   try make
   try make install
   cd "$BUILD"
   touch built.png
fi

if [ \! -e built.sdl_image ]; then
   export LIBS="-lz"
   try tar xvzf "$SOURCE/SDL_image-1.2.10.tar.gz"
   try cd "$BUILD/SDL_image-1.2.10"
   try ./configure --prefix="$INSTALL" --disable-tif --enable-shared --enable-static --enable-jpg-shared=no
   try make
   try make install
   cd "$BUILD"
   touch built.sdl_image
fi

if [ \! -e built.pygame ]; then
    
   SDL=`sdl-config --cflags --libs | python -c 'import sys; sys.stdout.write(sys.stdin.read().replace("\n", " ").replace("-mwindows", "").replace("-lSDLmain", "").replace("-Dmain=SDL_main", ""))'`

   echo $SDL
   sleep 10
   
   try tar xvzf "$SOURCE/pygame-1.8.1release.tar.gz"
   try cd "$BUILD/pygame-1.8.1release"

   try patch -p0 src/rwobject.c "$SOURCE/pygame-rwobject.diff"
   
   try cp "$SOURCE/rwobject.c" src/
   try cp "$SOURCE/surflock.c" src/
   ## # try cp "$SOURCE/transform.c" src/
   ## # try cp "$SOURCE/sysfont.py" lib/
   try cp "$SOURCE/pygame-setup.py" setup.py
   ## try cp "$SOURCE/alphablit.c" src/alphablit.c
   ## # try cp "$SOURCE/display.c" src/display.c
   try cp "$SOURCE/macosx.py" lib/macosx.py
   try cp "$SOURCE/pygame_init.py" lib/__init__.py
   ## # try cp "$SOURCE/config"*.py .

   # try grep -v "install_parachute ()" src/base.c > src/base.c.new
   # try mv src/base.c.new src/base.c
    
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

if [ \! -e built.av ]; then
   try tar xzf "$SOURCE/libav-0.7.4.tar.gz" 
   try cd "$BUILD/libav-0.7.4"

   # https://bugzilla.libav.org/show_bug.cgi?id=36
   try patch -p1 < "$SOURCE/libav-map-anonymous.diff"
   
   # My windows libraries don't seem to export fstat. So use _fstat32
   # instead.
   try patch -p1 < "$SOURCE/ffmpeg-fstat.diff"

   # av_cold is also a problem on windows.
   export CFLAGS="$CFLAGS -fno-common -Dav_cold="
   export CXXFLAGS="$CXXFLAGS -fno-common -Dav_cold="
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
       --disable-filters \
       --disable-bsfs 

   try make
   try make install

   try mkdir -p "$INSTALL/include/libswscale"
   try cp libswscale/swscale.h  "$INSTALL/include/libswscale"

   cd "$BUILD"
   touch built.av
fi

mkdir -p "$BUILD/alt"

if [ \! -e built.avalt ]; then
   try tar xzf "$SOURCE/libav-0.7.4.tar.gz" -C "$BUILD/alt" 
   try cd "$BUILD/alt/libav-0.7.4"
   
   # https://bugzilla.libav.org/show_bug.cgi?id=36
   try patch -p1 < "$SOURCE/libav-map-anonymous.diff"

   # My windows libraries don't seem to export fstat. So use _fstat32
   # instead.
   try patch -p1 < "$SOURCE/ffmpeg-fstat.diff"

   # av_cold is also a problem on windows.
   export CFLAGS="$CFLAGS -fno-common -Dav_cold="
   export CXXFLAGS="$CXXFLAGS -fno-common -Dav_cold="
   MEM_ALIGN_HACK="--enable-memalign-hack"

   try ./configure --prefix="$INSTALL/alt" \
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
       --enable-demuxer=matroska \
       --enable-demuxer=mov \
       --enable-demuxer=ogg \
       --enable-demuxer=wav \
       --disable-decoders \
       --enable-decoder=flac \
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
       --enable-parser=vp3 \
       --disable-protocols \
       --enable-protocol=file \
       --disable-devices \
       --disable-vdpau \
       --disable-filters \
       --disable-bsfs 

   try make
   try make install

   # try mkdir -p "$INSTALL/include/libswscale"
   # try cp libswscale/swscale.h  "$INSTALL/include/libswscale"

   cd "$BUILD"
   touch built.avalt
fi


if [ \! -e built.fribidi ]; then

   export CFLAGS="$CFLAGS -DFRIBIDI_CHUNK_SIZE=4080"
   
   try tar xvzf "$SOURCE/fribidi-0.19.2.tar.gz"
   try cd "$BUILD/fribidi-0.19.2"
   try ./configure --prefix="$INSTALL" --enable-static --disable-shared
   
   if [ "x$MSYSTEM" != "x" ]; then
       try patch -p0 < "$SOURCE/fribidi-windows.diff"
       try python "$SOURCE/replace.py" "lib bin doc" "lib doc" Makefile 
       echo Did patch.
   fi

   try make
   try make install
   cd "$BUILD"
   touch built.fribidi
fi

# argparse is so tiny.
cp "$SOURCE/argparse.py" "$INSTALL/python"

export CC=${CC:=gcc}
export CXX=${CXX:=g++}
export LD=${LD:=gcc}
export CXXLD=${CXXLD:=g++}

if [ \! -e built.glew ]; then

   try tar xzf "$SOURCE/glew-1.5.4.tgz"
   try cd "$BUILD/glew-1.5.4"

   try make install OPT="$CFLAGS $LDFLAGS" CC="$CC" LD="$LD" GLEW_DEST=$INSTALL
   
   cd "$BUILD"
   touch built.glew
fi

echo
cat ../env.sh

