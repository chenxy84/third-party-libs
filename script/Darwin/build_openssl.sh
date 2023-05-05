#!/usr/bin/env bash

#ref: https://github.com/x2on/OpenSSL-for-iPhone/blob/master/build-libssl.sh

SCRIPT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
ROOT_PATH=${SCRIPT_PATH}/../..
source ${ROOT_PATH}/script/common.sh

#-showsdks
export DEVELOPER=$(xcode-select -print-path)

echo "xcode developer path: $DEVELOPER"

if [ "${DEVELOPER}" == "" ]; then
  echo "XCODE DEVELOPER not set"
  exit 1;
fi

export OPENSSL_LOCAL_CONFIG_DIR="${SCRIPT_PATH}/config"
export IOS_MIN_SDK_VERSION="9.0"
export MACOSX_MIN_SDK_VERSION="10.14"

build() {
  SDKVERSION=

  export CROSS_COMPILE=
  export CROSS_TOP=
  export CROSS_SDK=
  export CC=

  OPENSSL_TARGET=$1
  echo "======== > Start build $OPENSSL_TARGET"
  case ${OPENSSL_TARGET} in
  iOS_arm64)
    PLATFORM=iPhoneOS
    SDKVERSION=$(xcrun -sdk iphoneos --show-sdk-version)
    OPENSSL_OS=ios-cross-arm64
    ;;
  iOS_Simulator_x86_64)
    PLATFORM=iPhoneSimulator
    SDKVERSION=$(xcrun -sdk iphonesimulator --show-sdk-version)
    OPENSSL_OS=ios-sim-cross-x86_64
    ;;
  macOS_x86_64)
    PLATFORM=MacOSX
    SDKVERSION=$(xcrun --show-sdk-version)
    OPENSSL_OS=macos-x86_64
    ;;
  esac

  export SDKVERSION=$SDKVERSION
  export PLATFORM=$PLATFORM

  # export ARCH=$(echo "${TARGET}" | sed -E 's|^.*\-([^\-]+)$|\1|g')

  echo "-------- > Start build configuration $OPENSSL_TARGET"
  
  if [ "${OPENSSL_TARGET}" == "macOS_x86_64" ]; then
    export CC="$(xcrun clang)"
  else
    export CROSS_COMPILE="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
    export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
    export CROSS_SDK="${PLATFORM}${SDKVERSION}.sdk"

    echo "SDK: ${CROSS_TOP}/SDKs/${CROSS_SDK}"
  fi

  temp_dir=${TEMP_PATH}/${BUILD_TARGET}/${OPENSSL_TARGET}/openssl
  if [ -d "${temp_dir}" ]; then
    rm -rf ${temp_dir}
  fi

  mkdir -p ${temp_dir}
  cp -rf ${OPENSSL_REPO_PATH} ${temp_dir}/../

  pushd ${temp_dir}

  ./Configure ${OPENSSL_OS} --prefix=$PREFIX/$OPENSSL_TARGET no-deprecated no-async no-shared no-tests \
  || exit 1

  echo "-------- > Start make $OPENSSL_TARGET with -j${BUILD_THREADS}"
  make -j${BUILD_THREADS} || exit 1
  echo "++++++++ > make and install $OPENSSL_TARGET complete."

  echo "-------- > Start install $OPENSSL_TARGET"
  make install || exit 1
  echo "++++++++ > make and install $OPENSSL_TARGET complete."

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
