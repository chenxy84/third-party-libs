#!/usr/bin/env bash

# ref https://github.com/depthlove/x264-iOS-build-script

SCRIPT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
ROOT_PATH=${SCRIPT_PATH}/../..
source ${ROOT_PATH}/script/common.sh

export DEVELOPER=$(xcode-select -print-path)

echo "xcode developer path: $DEVELOPER"

if [ "${DEVELOPER}" == "" ]; then
  echo "XCODE DEVELOPER not set"
  exit 1;
fi

if [ ! `which yasm` ]
then
  echo 'Yasm not found'
  if [ ! `which brew` ]
  then
    echo 'Homebrew not found. Trying to install...'
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \
    || exit 1
  fi
  echo 'Trying to install Yasm...'
  brew install yasm || exit 1
fi

if [ ! `which nasm` ]
then
  echo 'Yasm not found'
  if [ ! `which brew` ]
  then
    echo 'Homebrew not found. Trying to install...'
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \
    || exit 1
  fi
  echo 'Trying to install Nasm...'
  brew install nasm || exit 1
fi

export PATH=${SCRIPT_PATH}/tools:$PATH

IOS_DEPLOYMENT_TARGET="9.0"
MACOS_DEPLOYMENT_TARGET="10.14"

build() {
  X264_TARGET=$1

  echo "======== > Start build $X264_TARGET"

  CC=

  case ${X264_TARGET} in
  iOS_arm64)
    PLATFORM="iPhoneOS"
    HOST="--host=aarch64-apple-darwin"
    CC="xcrun -sdk iphoneos clang"
    AS="gas-preprocessor.pl -arch aarch64 -- $CC"
    EXTRA_CFLAGS="-mios-version-min=$IOS_DEPLOYMENT_TARGET  -fembed-bitcode"
    ASFLAGS="$EXTRA_CFLAGS"
    ;;
  iOS_Simulator_x86_64)
    PLATFORM="iPhoneSimulator"
    HOST=""
    CC="xcrun -sdk iphonesimulator clang"
    AS="gas-preprocessor.pl -- $CC"
    EXTRA_CFLAGS="-mios-simulator-version-min=$IOS_DEPLOYMENT_TARGET"
    ASFLAGS=
    ;;
  macOS_x86_64)
    PLATFORM="MacOSX"
    HOST=
    CC="xcrun clang"
    AS=
    EXTRA_CFLAGS="-mmacosx-version-min=$MACOS_DEPLOYMENT_TARGET"
    ASFLAGS=
    ;;
  esac

  temp_dir=${TEMP_PATH}/${BUILD_TARGET}/${X264_TARGET}/x264
  if [ -d "${temp_dir}" ]; then
    rm -rf ${temp_dir}
  fi

  mkdir -p ${temp_dir}
  cp -rf ${X264_REPO_PATH} ${temp_dir}/../

  pushd ${temp_dir}

  echo "-------- > Start config makefile with $CONFIGURATION"
  echo "-------- > with option --extra-cflags=${EXTRA_CFLAGS} --extra-cxxflags=${EXTRA_CFLAGS} --extra-ldflags=${EXTRA_CFLAGS}"
  echo "-------- > with pkgconfig $PKG_CONFIG_PATH"

  CFLAGS="$EXTRA_CFLAGS"
  CXXFLAGS="$EXTRA_CFLAGS"
  LDFLAGS="$EXTRA_CFLAGS"
  CC=$CC ./configure ${CONFIGURATION} \
  --prefix=$PREFIX/$X264_TARGET $HOST \
  --enable-static --enable-pic --disable-cli \
  --extra-cflags="$CFLAGS" \
  --extra-asflags="$ASFLAGS" \
  --extra-ldflags="$LDFLAGS" \
  || exit 1

  echo "-------- > Start make $X264_TARGET with -j${BUILD_THREADS}"
  make -j${BUILD_THREADS} || exit 1

  echo "-------- > Start install $X264_TARGET"
  make install || exit 1
  echo "++++++++ > make and install $X264_TARGET complete."

  popd

}

build_all() {
  build "iOS_arm64"
  build "iOS_Simulator_x86_64"
  build "macOS_x86_64"
}

echo "-------- Start --------"
build_all
echo "-------- End --------"
