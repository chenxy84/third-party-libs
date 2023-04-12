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
API=21

TOOLCHAINS="$NDK_PATH/toolchains/llvm/prebuilt/$HOST_PLATFORM"
SYSROOT="$NDK_PATH/toolchains/llvm/prebuilt/$HOST_PLATFORM/sysroot"

CFLAG="-Os -fPIC -DANDROID "
LDFLAG="-lc -lm -ldl -llog "


build() {
  OPENSSL_TARGET=$1
  echo "======== > Start build openssl for $OPENSSL_TARGET"
  case ${OPENSSL_TARGET} in
  armeabi-v7a)
    ARCH="arm"
    SYSROOT_PREFIX=$ARCH-linux-androideabi
    TOOLCHAINS_PREFIX=armv7a-linux-androideabi
    OPENSSL_OS=android-arm
    ;;
  arm64-v8a)
    ARCH="aarch64"
    SYSROOT_PREFIX=$ARCH-linux-android
    TOOLCHAINS_PREFIX=$SYSROOT_PREFIX
    OPENSSL_OS=android-arm64
    ;;
  x86)
    ARCH="i686"
    SYSROOT_PREFIX=$ARCH-linux-android
    TOOLCHAINS_PREFIX=$SYSROOT_PREFIX
    OPENSSL_OS=android-x86
    ;;
  x86_64)
    ARCH="x86_64"
    SYSROOT_PREFIX=$ARCH-linux-android
    TOOLCHAINS_PREFIX=$SYSROOT_PREFIX
    OPENSSL_OS=android-x86_64
    ;;
  esac

  CC="$TOOLCHAINS/bin/$TOOLCHAINS_PREFIX$API-clang"
  CXX="$TOOLCHAINS/bin/$TOOLCHAINS_PREFIX$API-clang++"

  echo "-------- > Start build configuration $OPENSSL_TARGET"

  export PATH=$TOOLCHAINS/bin:$PATH
  export CC=$CC
  export CXX=$CXX
  export RANLIB="$TOOLCHAINS/bin/llvm-ranlib"
  export AR="$TOOLCHAINS/bin/llvm-ar"
  export ANDROID_API=$API

  temp_dir=${TEMP_PATH}/${BUILD_TARGET}/${OPENSSL_TARGET}/openssl-${OPENSSL_VERSION}
  if [ -d "${temp_dir}" ]; then
    rm -rf ${temp_dir}
  fi

  mkdir -p ${temp_dir}
  cp -rf ${OPENSSL_REPO_PATH} ${temp_dir}/../

  pushd ${temp_dir}

  #./Configure $OPENSSL_OS --prefix=$PREFIX/$OPENSSL_TARGET -D__ANDROID_API__=$API no-shared
  ./Configure $OPENSSL_OS --prefix=$PREFIX/$OPENSSL_TARGET -D__ANDROID_API__=$API no-shared \
  || exit 1

  echo "-------- > Start make $OPENSSL_TARGET with -j16"
  make -j${BUILD_THREADS} || exit 1
  echo "++++++++ > make and install $OPENSSL_TARGET complete."

  echo "-------- > Start install $OPENSSL_TARGET"
  make install || exit 1
  echo "++++++++ > make and install $OPENSSL_TARGET complete."

  popd
}

build_all() {
  # build "armeabi-v7a"
  build "arm64-v8a"
  # build "x86"
  # build "x86_64"
}

echo "-------- Start --------"
build_all
echo "-------- End --------"
