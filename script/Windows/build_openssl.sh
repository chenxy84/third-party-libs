#!/usr/bin/env bash

SCRIPT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
ROOT_PATH=${SCRIPT_PATH}/../..
source ${ROOT_PATH}/script/common.sh
source ${SCRIPT_PATH}/windows_common.sh

build() {

  OPENSSL_TARGET=$1
  echo "======== > Start build $OPENSSL_TARGET"
  case ${OPENSSL_TARGET} in
  x86_64)
    OPENSSL_OS=mingw64
    # CROSS_PREFIX=x86_64-w64-mingw32-
    ;;
  xxx)
    ;;
  esac

  echo "-------- > Start build configuration $OPENSSL_TARGET"

  temp_dir=${TEMP_PATH}/${BUILD_TARGET}/${OPENSSL_TARGET}/openssl
  if [ -d "${temp_dir}" ]; then
    rm -rf ${temp_dir}
  fi

  mkdir -p ${temp_dir}
  cp -rf ${OPENSSL_REPO_PATH} ${temp_dir}/../

  pushd ${temp_dir}

  ./Configure $OPENSSL_OS no-shared\
  --prefix=$PREFIX/$OPENSSL_TARGET \
  --cross-compile-prefix=$CROSS_PREFIX \
  --openssldir=$PREFIX/$OPENSSL_TARGET/dist \
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
  build x86_64
}

echo "-------- Start --------"
build_all
echo "-------- End --------"
