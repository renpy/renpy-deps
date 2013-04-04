#!/bin/bash

SOURCE=`dirname "$0"`/source
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
export CFLAGS="$CFLAGS -O3 -I$INSTALL/include -I$INSTALL/include/freetype2 -I$INSTALL/include/SDL"
export LDFLAGS="-O3 -L$INSTALL/lib $LDFLAGS"

PLATFORM=linux

if [ "x$MSYSTEM" != "x" ]; then
    export CFLAGS="$CFLAGS -fno-strict-aliasing "
    export CXXFLAGS="$CXXFLAGS -fno-strict-aliasing "
    PLATFORM="windows"
else
    if [ `uname` = 'Darwin' ]; then
       PLATFORM="mac"
    fi
    
    if [ `arch` = "x86_64" ]; then
        export CFLAGS="-fPIC $CFLAGS"
        export CXXFLAGS="-fPIC $CXXFLAGS"
        export LDFLAGS="-fPIC $LDFLAGS"
    fi
fi

export CPPFLAGS="$CFLAGS"
export CXXFLAGS="$CFLAGS"

OLD_CC="$CC"
OLD_LD="$LD"
OLD_CXX="$CXX"
OLD_CXXLD="$CXXLD"
OLD_CFLAGS="$CFLAGS"
OLD_CXXFLAGS="$CXXFLAGS"
OLD_LDFLAGS="$LDFLAGS"
OLD_CXXLDFLAGS="$CXXLDFLAGS"

export SED=sed
export RENPY_DEPS_INSTALL=$INSTALL

try () {
    "$@" || exit 1
}

libtool() {
    cp /usr/local/bin/libtool .
}

try mkdir -p "$INSTALL/lib"
rm -Rf "$INSTALL/lib64"
try ln -s "$INSTALL/lib" "$INSTALL/lib64"

cd $BUILD

cat <<EOF > ../env.sh
export RENPY_ORIGINAL_PATH="\$PATH"
export RENPY_ORIGINAL_PYTHONPATH="\$PYTHONPATH"
export RENPY_ORIGINAL_LD_LIBRARY_PATH="\$LD_LIBRARY_PATH"
export RENPY_ORIGINAL_DYLIB_LIBRARY_PATH="\$DYLIB_LIBRARY_PATH"
export RENPY_ORIGINAL_DYLD_FRAMEWORK_PATH="\$DYLD_FRAMEWORK_PATH"

export RENPY_DEPS_INSTALL="$INSTALL"

export PATH="$PATH"
export PYTHONPATH="$INSTALL/python"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export DYLIB_LIBRARY_PATH="$DYLIB_LIBRARY_PATH"
export DYLD_FRAMEWORK_PATH="$DYLD_FRAMEWORK_PATH"
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

if [ $PLATFORM != "windows" ]; then

    if [ \! -e built.yasm ]; then
        try tar xzf "$SOURCE/yasm-1.2.0.tar.gz"
        try cd "$BUILD/yasm-1.2.0"
        try ./configure --prefix="$INSTALL"
        try make
        try make install
        cd "$BUILD"
        try touch built.yasm
    fi
    
else

    # A source-built yasm doesn't seem to work on my computer. So
    # use the prebuilt version.
    try cp "$SOURCE/yasm-1.2.0-win32.exe" "$INSTALL/bin/yasm.exe"

fi


    
if [ \! -e built.sdl ]; then

   # try mkdir -p "$INSTALL/include/asm"
   # try touch "$INSTALL/include/asm/page.h"

   try tar xzf "$SOURCE/SDL-1.2.15.tar.gz"
   try cd "$BUILD/SDL-1.2.15"

   # On windows, we have the problem that maximizing causes the start
   # button to overlap the GL window, making performance lousy, so we
   # disable maximize.
   try patch -p0 < $SOURCE/sdl-no-windows-maximize.diff 

   if [ $PLATFORM = "mac" ]; then
       SDL_EXTRA="--disable-video-x11"
   else
       SDL_EXTRA=""
   fi
   
   try ./configure --prefix="$INSTALL" --disable-debug --disable-video-dummy --disable-video-fbcon --disable-video-directfb --disable-nas $SDL_EXTRA $SDL_ASM

   try make
   try make install
   cd "$BUILD"
   touch built.sdl
fi

# This will be built shared on Linux and Mac by build_python, and 
# on windows here.
if [ \! -e built.zlib ]; then
   try tar xvzf "$SOURCE/zlib-1.2.6.tar.gz"
   try cd "$BUILD/zlib-1.2.6"
   if [ "x$MSYSTEM" != "x" ]; then
       try make -f win32/Makefile.gcc

       try make -f win32/Makefile.gcc install \
           INCLUDE_PATH="$INSTALL/include" \
           LIBRARY_PATH="$INSTALL/lib" \
           BINARY_PATH="$INSTALL/bin" \
           SHARED_MODE=1

   else
       try ./configure --prefix="$INSTALL" 
       try make
       try make install
   fi
       
   cd "$BUILD"
   touch built.zlib
fi


if [ \! -e built.freetype ]; then
   try tar xjf "$SOURCE/freetype-2.4.11.tar.bz2"
   try cd "$BUILD/freetype-2.4.11"

   try patch -p1 < "$SOURCE/freetype-2.2.1-enable-valid.patch"

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
    try tar xzf "$SOURCE/libjpeg-turbo-1.2.0.tar.gz"
    try cd "$BUILD/libjpeg-turbo-1.2.0"
    try ./configure --prefix="$INSTALL" $JPEG_ASM
    try make
    try make install
    cd "$BUILD"
    try touch built.jpegturbo
fi

if [ \! -e built.png ]; then

   if [ $PLATFORM != "mac" ]; then
       export CFLAGS="$CFLAGS -DPNG_NO_WRITE_tIME"
   fi
   
   try tar xvzf "$SOURCE/libpng-1.2.49.tar.gz"
   try cd "$BUILD/libpng-1.2.49"
   try ./configure --prefix="$INSTALL" --enable-shared --disable-static
   try make
   try make install
   cd "$BUILD"

   touch built.png
fi

if [ $PLATFORM = "windows" ]; then
   try cp "$INSTALL/lib/libpng.dll.a" "$INSTALL/lib/libpng12.dll.a"
fi

if [ \! -e built.sdl_image ]; then
   export LIBS="-lz"
   try tar xvzf "$SOURCE/SDL_image-1.2.12.tar.gz"
   try cd "$BUILD/SDL_image-1.2.12"
   try ./configure --prefix="$INSTALL" --disable-tif --disable-imageio --enable-shared --disable-static --disable-jpg-shared --disable-png-shared --disable-webp --disable-xcf
   try make
   try make install
   cd "$BUILD"
   touch built.sdl_image
fi

if [ \! -e built.pygame ]; then

   try mkdir -p "$INSTALL/lib/msvcr90"
   
   try tar xzf "$SOURCE/pygame-1.9.1release.tar.gz"
   try cd "$BUILD/pygame-1.9.1release"

   try patch -p0 < "$SOURCE/pygame-blit-release-gil.diff"

   try cp "$SOURCE/pygame-setup.py" setup.py
   try python "$SOURCE/write_pygame_setup.py" "$INSTALL" > Setup

   if [ $PLATFORM = "windows" ]; then
       try python setup.py build --compiler=mingw32 install_lib -d "$INSTALL/python"
       try cp "$INSTALL/bin/"*.dll "$INSTALL/python/pygame"
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

LIBAV_FLAGS=

if [ $PLATFORM = "windows" ]; then
   LIBAV_FLAGS="--disable-pthreads --enable-w32threads"
fi

if [ \! -e built.av ]; then
   try tar xzf "$SOURCE/libav-0.7.6.tar.gz" 
   try cd "$BUILD/libav-0.7.6"

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
       $LIBAV_FLAGS \
       $MEM_ALIGN_HACK \
       --enable-runtime-cpudetect \
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
       --enable-demuxer=webm \
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
       --enable-decoder=vp8 \
       --disable-parsers \
       --enable-parser=mpegaudio \
       --enable-parser=mpegvideo \
       --enable-parser=mpeg4video \
       --enable-parser=vp3 \
       --enable-parser=vp8 \
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

if [ -n "$RENPY_BUILD_ALT" ]; then

    mkdir -p "$BUILD/alt"

    if [ \! -e built.avalt ]; then
        try tar xzf "$SOURCE/libav-0.7.5.tar.gz" -C "$BUILD/alt" 
        try cd "$BUILD/alt/libav-0.7.5"
        
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
            --enable-runtime-cpudetect \
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
            --enable-demuxer=webm \
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
            --enable-decoder=vp8 \
            --disable-parsers \
            --enable-parser=vp3 \
            --enable-parser=vp8 \
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

export CC=${CC:=gcc}
export CXX=${CXX:=g++}
export LD=${LD:=gcc}
export CXXLD=${CXXLD:=g++}

if [ \! -e built.glew ]; then

   try tar xzf "$SOURCE/glew-1.7.0.tgz"
   try cd "$BUILD/glew-1.7.0"

   try make install OPT="$CFLAGS $LDFLAGS" CC="$CC" LD="$LD" GLEW_DEST=$INSTALL
   
   cd "$BUILD"
   touch built.glew
fi


if [ $PLATFORM != "windows" ] ; then 
  if [ \! -e built.zsync ] ; then
    try tar xjf "$SOURCE/zsync-0.6.2.tar.bz2"
    try cd "$BUILD/zsync-0.6.2"

    try patch -p1 < "$SOURCE/zsync-no-isatty.diff"
    
    try "./configure" --prefix="$INSTALL"
    try make
    try make install

    cd "$BUILD"
    touch built.zsync
  fi
fi

if [ $PLATFORM = "linux" -a \! -e built.patchelf ]; then
    try tar xzf "$SOURCE/patchelf-0.6.tar.gz"
    try cd "$BUILD/patchelf-0.6"

    try "./configure" --prefix="$INSTALL"
    try make
    try make install

    cd "$BUILD"
    touch built.patchelf
fi


echo
cat ../env.sh

