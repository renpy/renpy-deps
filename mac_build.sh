# Note: For this to work, you need to symlink the build directory into
# /Developer/SDKs/MacOSX10.3.9.sdk

export MACOSX_DEPLOYMENT_TARGET=10.3
FLAGS="-isysroot /Developer/SDKs/MacOSX10.3.9.sdk  -fno-use-cxa-atexit -fno-common"

export CFLAGS="$FLAGS"
export CXXFLAGS="$FLAGS"
export LDFLAGS="$FLAGS"
export NOALTIVEC=1

. `dirname $0`/build.sh
