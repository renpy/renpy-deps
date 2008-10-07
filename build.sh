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

export CFLAGS="$CFLAGS -O3 -fPIC -I$INSTALL/include -I$INSTALL/include/freetype2"
export CXXFLAGS="$CXXFLAGS -O3 -fPIC -I$INSTALL/include -I$INSTALL/include/freetype2"
export LDFLAGS="-fPIC -O3 -L$INSTALL/lib $LDFLAGS"


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

if [ \! -e built.sdl ]; then

   try tar xzf "$SOURCE/SDL-1.2.11.tar.gz"
   try cd "$BUILD/SDL-1.2.11"

   try patch -p0 < $SOURCE/sdl-windows-title.diff

  # for i in $SOURCE/sdl-patches/*.diff; do
   #    try patch -p1 < $i
   # done

   if [ "x$NOALTIVEC" != "x" ]; then
       echo Disabling altivec support...
       try sed -e "s/-faltivec//g" configure > configure.new
       try cat configure.new > configure
   fi

   try ./configure --prefix="$INSTALL"  --disable-debug --disable-video-dummy
   
   try make
   try make install
   cd "$BUILD"
   touch built.sdl
fi

if [ "x$NOSMPEG" = "x" -a \! -e built.smpeg ]; then
   try $CP "$SOURCE/smpeg" "$BUILD"
   try cd "$BUILD/smpeg"
   try sh ./configure --prefix="$INSTALL" --disable-opengl-player --disable-gtk-player --disable-gtktest --enable-mmx
   # libtool
   # cp ../SDL-1.2.11/libtool .

   if [ $MAC = no ] ; then
       try make CXXLD="${CXXLD:-g++} -no-undefined"
   else
       try make CXXLD="${CXXLD:-g++}"
   fi

   try make install
   cd "$BUILD"

   touch built.smpeg
fi

if [ \! -e built.zlib ]; then
   try tar xvzf "$SOURCE/zlib-1.2.3.tar.gz"
   try cd "$BUILD/zlib-1.2.3"
   try ./configure --prefix="$INSTALL"
   try make
   try make install
   cd "$BUILD"
   touch built.zlib
fi

# if [ \! -e built.freetype ]; then
#    try tar xvjf "$SOURCE/freetype-2.1.10.tar.bz2"
#    cd "$BUILD/freetype-2.1.10"
#    for i in bdf cff otvalid pcf pfr psaux pshinter psnames type1 type42 winfonts; do
#        rm -Rf src/$i
#    done
   
#    cp "$SOURCE/ftmodule.h" include/freetype/config
      
#    try ./configure --prefix="$INSTALL"
#    try make
#    try make install
#    cd "$BUILD"
#    touch built.freetype
# fi

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
   try ./configure --prefix="$INSTALL" --enable-static --disable-shared
   try make
   try make install
   cd "$BUILD"
   touch built.png
fi

if [ \! -e built.sdl_image ]; then
   try tar xvzf "$SOURCE/SDL_image-1.2.5.tar.gz"
   try cd "$BUILD/SDL_image-1.2.5"
   try ./configure --prefix="$INSTALL" --disable-tif --disable-jpg-shared --disable-png-shared
   try make
   try make install
   cd "$BUILD"
   touch built.sdl_image
fi

if [ \! -e built.ogg ]; then
   try tar xvzf "$SOURCE/libogg-1.1.3.tar.gz"
   try cd "$BUILD/libogg-1.1.3"
   try ./configure --prefix="$INSTALL" --disable-shared
   try make
   try make install
   cd "$BUILD"
   touch built.ogg
fi

if [ \! -e built.vorbis ]; then
   try tar xvzf "$SOURCE/libvorbis-1.1.2.tar.gz"
   try cd "$BUILD/libvorbis-1.1.2"
   try ./configure --prefix="$INSTALL" --with-ogg-libraries="$INSTALL/lib" --with-ogg-includes="$INSTALL/include" --disable-shared
   try make
   try make install
   cd "$BUILD"
   touch built.vorbis
fi

if [ \! -e built.speex ]; then
   try tar xvzf "$SOURCE/speex-1.0.5.tar.gz"
   try cd "$BUILD/speex-1.0.5"
   try ./configure --prefix="$INSTALL" --with-ogg-libraries="$INSTALL/lib" --with-ogg-includes="$INSTALL/include" --disable-shared
   try patch -p0 < "$SOURCE/speex.patch"
   try make
   try make install
   cd "$BUILD"
   touch built.speex
fi

if [ \! -e built.sdl_mixer ]; then
   try tar xvzf "$SOURCE/SDL_mixer-1.2.6.tar.gz"
   try patch -p0 < "$SOURCE/SDL_mixer.patch"
   try cd "$BUILD/SDL_mixer-1.2.6"
   try ./configure --prefix="$INSTALL" --disable-music-midi
   try make
   try make install
   cd "$BUILD"
   touch built.sdl_mixer
fi


# Flac

# if [ \! -e built.flac ]; then
#    try tar xvzf "$SOURCE/flac-1.1.2.tar.gz"
#    try cd "$BUILD/flac-1.1.2"
#    try ./configure --prefix="$INSTALL" --disable-shared --disable-asm-optimizations
#    try make
#    try make install
#    cd "$BUILD"
#    touch built.flac
# fi


if [ \! -e built.modplug ]; then
   try tar xvzf "$SOURCE/libmodplug-0.7.tar.gz"
   try cd "$BUILD/libmodplug-0.7"
   try ./configure --prefix="$INSTALL" --disable-shared
   try make
   try make install
   cd "$BUILD"
   touch built.modplug
fi

if [ \! -e built.sdl_sound ]; then
   try $CP "$SOURCE/SDL_sound-1.0.1" . 
   try cd "$BUILD/SDL_sound-1.0.1"

# cp "$SOURCE/SDL_sound.configure" ./configure

   export CPPFLAGS="-DSDLSOUND_MINGW_FIX -I$INSTALL/include -I$INSTALL/include/libmodplug" 
   export LDFLAGS="$LDFLAGS -L$INSTALL/lib"

   MIDI=`python "$SOURCE/midi_flag.py"`

   try ./configure --prefix="$INSTALL" --disable-mikmod --disable-smpeg --enable-mpglib $MIDI --disable-flac  --disable-shared

   # try make clean SED=sed
   try make SED=sed
   try make install

   unset CPPFLAGS
   LDFLAGS="$OLD_LDFLAGS"

   cd "$BUILD"
   touch built.sdl_sound
fi

# unset MACOSX_DEPLOYMENT_TARGET

if [ \! -e built.pygame ]; then
    
   SDL=`sdl-config --cflags --libs | python -c 'import sys; sys.stdout.write(sys.stdin.read().replace("\n", " ").replace("-mwindows", ""))'`
   SMPEG=`smpeg-config --cflags --libs | python -c 'import sys; sys.stdout.write(sys.stdin.read().replace("\n", " ").replace("-mwindows", ""))'`

   try tar xvzf "$SOURCE/pygame-1.8.1release.tar.gz"
   try cd "$BUILD/pygame-1.8.1release"

   try cp "$SOURCE/movie.c" src/
   try cp "$SOURCE/rwobject.c" src/
   # try cp "$SOURCE/sysfont.py" lib/
   try cp "$SOURCE/pygame-setup.py" setup.py
   # try cp "$SOURCE/alphablit.c" src/alphablit.c
   # try cp "$SOURCE/display.c" src/display.c
   try cp "$SOURCE/macosx.py" lib/macosx.py
   # try cp "$SOURCE/config"*.py .

   if [ "x$NOSMPEG" = "x" ] ; then
       try sed -e "s|@SDL@|$SDL|g" -e "s|@SMPEG@|$SMPEG|g" -e "s|@INSTALL@|$INSTALL|g"  "$SOURCE/Setup" > Setup
   else
       try sed -e "s|@SDL@|$SDL|g" -e "s|@SMPEG@|$SMPEG|g" "$SOURCE/Setup.nosmpeg" > Setup
   fi


   #   export SDL_CONFIG="$INSTALL/bin/sdl-config"
   # export SMPEG_CONFIG="$INSTALL/bin/smpeg-config"

   # try python config.py --auto
   # try touch config_msys.py

   # try rm mingw32*.py

   if [ "x$MSYSTEM" != "x" ]; then
       # try python setup.py build --compiler=mingw32 install_lib -d "$INSTALL/python"
       echo $CFLAGS
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

# if [ \! -e built.ffmpeg ]; then
#    try $CP "$SOURCE/ffmpeg" . 
#    try cd "$BUILD/ffmpeg"

#    try ./configure --prefix="$INSTALL" \
#        --disable-encoders --disable-muxers \
#        --enable-static --disable-shared \
#        --disable-v4l --disable-v4l2 --disable-bktr \
#        --disable-dv1394  --disable-network \
#        --enable-libogg --enable-vorbis --enable-memalign-hack

#    try make
#    try make install
#    cd "$BUILD"
#    touch built.ffmpeg
# fi


# if [ "x$MSYSTEM" != "x" ]; then
#     echo
#     echo To install pygame globally, run:
#     echo
#     echo . env.sh
#     echo "cd '$BUILD/pygame-1.7.1release'"
#     echo python setup.py build --compiler=mingw32 install
#     echo "cd ../.."
#     echo
#     echo unset PYTHONPATH to use it. Remember to strip the .pyds before
#     echo distributing them.
# fi

echo
cat ../env.sh

