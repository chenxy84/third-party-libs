#!/bin/bash

SCRIPT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
ROOT_PATH=${SCRIPT_PATH}/../..
source ${ROOT_PATH}/script/common.sh

if [ "${ANDROID_NDK}" == "" ]; then
	echo "ANDROID_NDK not set"
	exit 1;
fi

NDK_PATH=${ANDROID_NDK} # tag1
# macOS $NDK_PATH/toolchains/llvm/prebuilt/
HOST_PLATFORM=darwin-x86_64  #tag1
# minSdkVersion
API=26

TOOLCHAINS="$NDK_PATH/toolchains/llvm/prebuilt/$HOST_PLATFORM"
SYSROOT="$NDK_PATH/toolchains/llvm/prebuilt/$HOST_PLATFORM/sysroot"

CFLAG="-Os -fPIC -DANDROID"
LDFLAG="-lc -lm -ldl -llog -lz"

build() {
  FFMPEG_TARGET=$1

  EXTRA_OPTIONS=
  EXTRA_CFLAGS=
  EXTRA_CXXFLAGS=
  EXTRA_LDFLAGS=

  echo "======== > Start build ffmpeg for $FFMPEG_TARGET"
  case ${FFMPEG_TARGET} in
  armeabi-v7a)
    ARCH="arm"
    CPU="armv7-a"
    MARCH="armv7-a"
    TARGET=armv7a-linux-androideabi
    CC="$TOOLCHAINS/bin/$TARGET$API-clang"
    CXX="$TOOLCHAINS/bin/$TARGET$API-clang++"
    CROSS_PREFIX="$TOOLCHAINS/bin/$TARGET$API-"
    EXTRA_CFLAGS="-mfloat-abi=softfp -mfpu=vfp -marm -march=$MARCH"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-neon --cpu=$CPU "
    ;;
  arm64-v8a)
    ARCH="aarch64"
    MARCH="armv8-a"
    TARGET=$ARCH-linux-android
    CC="$TOOLCHAINS/bin/$TARGET$API-clang"
    CXX="$TOOLCHAINS/bin/$TARGET$API-clang++"
    CROSS_PREFIX="$TOOLCHAINS/bin/$TARGET-"
    EXTRA_CFLAGS="-march=$MARCH"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-neon"
    ;;
  x86)
    ARCH="x86"
    CPU="i686"
    MARCH="i686"
    TARGET=i686-linux-android
    CC="$TOOLCHAINS/bin/$TARGET$API-clang"
    CXX="$TOOLCHAINS/bin/$TARGET$API-clang++"
    CROSS_PREFIX="$TOOLCHAINS/bin/$TARGET-"
    #EXTRA_CFLAGS="$CFLAG -march=$MARCH -mtune=intel -mssse3 -mfpmath=sse -m32"
    EXTRA_CFLAGS="-march=$MARCH  -mssse3 -mfpmath=sse -m32"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --disable-asm"
    ;;
  x86_64)
    ARCH="x86_64"
    CPU="x86-64"
    MARCH="x86_64"
    TARGET=$ARCH-linux-android
    CC="$TOOLCHAINS/bin/$TARGET$API-clang"
    CXX="$TOOLCHAINS/bin/$TARGET$API-clang++"
    CROSS_PREFIX="$TOOLCHAINS/bin/$TARGET-"
    #EXTRA_CFLAGS="$CFLAG -march=$CPU -mtune=intel -msse4.2 -mpopcnt -m64"
    EXTRA_CFLAGS="-march=$CPU -msse4.2 -mpopcnt -m64"
    ;;
  esac

  EXTRA_CFLAGS="$CFLAG $EXTRA_CFLAGS"
  EXTRA_CXXFLAGS="$EXTRA_CXXFLAGS $EXTRA_CFLAGS"
  EXTRA_LDFLAGS="$LDFLAG $EXTRA_LDFLAGS"

  CONFIGURATION=
  CONFIGURATION="$CONFIGURATION $FFMPEG_COMMON_OPTIONS"
  CONFIGURATION="$CONFIGURATION $EXTRA_OPTIONS"

  CONFIGURATION="$CONFIGURATION --target-os=android"
  CONFIGURATION="$CONFIGURATION --disable-vulkan"
  
  CONFIGURATION="$CONFIGURATION --enable-cross-compile"
  CONFIGURATION="$CONFIGURATION --enable-optimizations"

  CONFIGURATION="$CONFIGURATION --enable-jni"
  CONFIGURATION="$CONFIGURATION --enable-mediacodec"
  CONFIGURATION="$CONFIGURATION --enable-decoder=h264_mediacodec"
  CONFIGURATION="$CONFIGURATION --enable-decoder=hevc_mediacodec"
  
  CONFIGURATION="$CONFIGURATION --logfile=${LOG_PATH}/ffmpeg_config_$FFMPEG_TARGET.log"
  CONFIGURATION="$CONFIGURATION --prefix=$PREFIX/$FFMPEG_TARGET"
  CONFIGURATION="$CONFIGURATION --pkg-config=pkg-config"
  CONFIGURATION="$CONFIGURATION --cross-prefix=$CROSS_PREFIX"
  CONFIGURATION="$CONFIGURATION --arch=$ARCH"
  CONFIGURATION="$CONFIGURATION --sysroot=$SYSROOT"
  CONFIGURATION="$CONFIGURATION --cc=$CC"
  CONFIGURATION="$CONFIGURATION --cxx=$CXX"
  CONFIGURATION="$CONFIGURATION --as=$CC"
  CONFIGURATION="$CONFIGURATION --ld=$CC"
  CONFIGURATION="$CONFIGURATION --enable-pic"
  #tools
  CONFIGURATION="$CONFIGURATION --ranlib=$TOOLCHAINS/bin/llvm-ranlib"
  CONFIGURATION="$CONFIGURATION --ar=$TOOLCHAINS/bin/llvm-ar"
  CONFIGURATION="$CONFIGURATION --nm=$TOOLCHAINS/bin/llvm-nm"
  CONFIGURATION="$CONFIGURATION --strip=$TOOLCHAINS/bin/llvm-strip"

  export PKG_CONFIG_PATH=$PREFIX/$FFMPEG_TARGET/lib/pkgconfig

  temp_dir=${TEMP_PATH}/${BUILD_TARGET}/${FFMPEG_TARGET}/ffmpeg
  if [ -d "${temp_dir}" ]; then
    rm -rf ${temp_dir}
  fi

  mkdir -p ${temp_dir}
  cp -rf ${FFMPEG_REPO_PATH} ${temp_dir}/../

  pushd ${temp_dir}

  echo "-------- > Start config makefile with $CONFIGURATION"
  echo "-------- > with option --extra-cflags=${EXTRA_CFLAGS} --extra-cxxflags=${EXTRA_CXXFLAGS} --extra-ldflags=${EXTRA_LDFLAGS}"
  echo "-------- > with pkgconfig $PKG_CONFIG_PATH"

  ./configure ${CONFIGURATION} \
  --extra-cflags="$EXTRA_CFLAGS" \
  --extra-ldflags="$EXTRA_LDFLAGS" \
  || exit 1

  echo "-------- > Start make $FFMPEG_TARGET with -j${BUILD_THREADS}"
  make -j${BUILD_THREADS} || exit 1

  echo "-------- > Start install $FFMPEG_TARGET"
  make install || exit 1
  echo "++++++++ > make and install $FFMPEG_TARGET complete."
  popd

  echo "-------- > Generate libffmpeg.so"

  pushd $PREFIX/$FFMPEG_TARGET/lib

  echo "-------- >SO_PATH: $PREFIX/$FFMPEG_TARGET/lib"
  echo "-------- >CMD: $CC $EXTRA_CFLAGS"
  echo "-------- >LDFLAG: $CC $EXTRA_CFLAGS"

  $CC $EXTRA_CFLAGS \
  -shared -o libffmpeg.so \
  -Wl,--whole-archive -Wl,-Bsymbolic \
  libavcodec.a libavformat.a libswresample.a libavfilter.a libavutil.a libswscale.a \
  libssl.a libcrypto.a \
  -Wl,--no-whole-archive \
  $EXTRA_LDFLAGS \
  || exit 1

  #mv so to jni libs
  android_jnilibs=${ROOT_PATH}/projects/Android/ffmpeg/library/libs/${FFMPEG_TARGET}
  if [ ! -d "${android_jnilibs}" ]; then
    mkdir -p ${android_jnilibs}
  fi
  
  cp libffmpeg.so ${android_jnilibs}/

  popd

  echo "++++++++ > Generate $FFMPEG_TARGET/libffmpeg.so complete."

}

build_all() {
  build "armeabi-v7a"
  build "arm64-v8a"
  build "x86"
  build "x86_64"

  pushd ${ROOT_PATH}/projects/Android/ffmpeg
  echo "sdk.dir=${ANDROID_SDK}" > local.properties
  ./gradlew assemble
  popd

}

echo "-------- Start --------"
build_all
echo "-------- End --------"