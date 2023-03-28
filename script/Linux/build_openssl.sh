#!/usr/bin/env bash

#ref: https://github.com/x2on/OpenSSL-for-iPhone/blob/master/build-libssl.sh

SCRIPT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
ROOT_PATH=${SCRIPT_PATH}/../..
source ${ROOT_PATH}/script/common.sh

build() {
  OPENSSL_TARGET=$1
  echo "======== > Start build $OPENSSL_TARGET"
  case ${OPENSSL_TARGET} in
  Linux_x86_64)
    OPENSSL_OS=linux-x86_64
    ;;
  xxx)
    ;;
  esac

  echo "-------- > Start build configuration $OPENSSL_TARGET"

  temp_dir=${TEMP_PATH}/${BUILD_TARGET}/${OPENSSL_TARGET}/openssl-${OPENSSL_VERSION}
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
  build "Linux_x86_64"
}

echo "-------- Start --------"
build_all
echo "-------- End --------"
