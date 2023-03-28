#!/usr/bin/env bash

SCRIPT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
ROOT_PATH=${SCRIPT_PATH}/../..
source ${ROOT_PATH}/script/common.sh

build() {
  EXTRA_OPTIONS=
  X264_TARGET=$1

  echo "======== > Start build $X264_TARGET"
  
  case ${X264_TARGET} in
  x86_64)
    ARCH="x86_64"
    EXTRA_CFLAGS="$EXTRA_CFLAGS -static"
    EXTRA_LDFLAGS="$LDFLAG $EXTRA_CFLAGS"
    # EXTRA_OPTIONS="$EXTRA_OPTIONS --disable-programs"
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
  echo "-------- > with option --extra-cflags=${EXTRA_CFLAGS} --extra-cxxflags=${EXTRA_CXXFLAGS} --extra-ldflags=${EXTRA_LDFLAGS}"

./configure ${CONFIGURATION} \
  --prefix=$PREFIX/$X264_TARGET $HOST \
  --enable-static --enable-pic --disable-cli \
  --extra-cflags="$EXTRA_CFLAGS" \
  --extra-ldflags="$EXTRA_LDFLAGS" \
  || exit 1

  echo "-------- > Start make $X264_TARGET with -j${BUILD_THREADS}"
  make -j${BUILD_THREADS} || exit 1

  echo "-------- > Start install $X264_TARGET"
  make install || exit 1
  echo "++++++++ > make and install $X264_TARGET complete."

  popd

}

build_all() {
  build "x86_64"
}

echo "-------- Start --------"
build_all
echo "-------- End --------"
