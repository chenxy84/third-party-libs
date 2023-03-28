#!/usr/bin/env bash

SCRIPT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
ROOT_PATH=${SCRIPT_PATH}/../..
source ${ROOT_PATH}/script/common.sh

build() {
  EXTRA_OPTIONS=
  FFMPEG_TARGET=$1

  echo "======== > Start build $FFMPEG_TARGET"
  
  case ${FFMPEG_TARGET} in
  x86_64)
    ARCH="x86_64"
    EXTRA_CFLAGS="$EXTRA_CFLAGS -static"
    EXTRA_LDFLAGS="$LDFLAG $EXTRA_CFLAGS"
    # EXTRA_OPTIONS="$EXTRA_OPTIONS --disable-programs"
    ;;
  esac

  CONFIGURATION=
  CONFIGURATION="$CONFIGURATION $FFMPEG_COMMON_OPTIONS"
  CONFIGURATION="$CONFIGURATION $EXTRA_OPTIONS"

  CONFIGURATION="$CONFIGURATION --logfile=$LOG_PATH/ffmpeg_config_$FFMPEG_TARGET.log"
  CONFIGURATION="$CONFIGURATION --prefix=$PREFIX/$FFMPEG_TARGET"
  CONFIGURATION="$CONFIGURATION --arch=$ARCH"
  CONFIGURATION="$CONFIGURATION --target-os=mingw32"
  CONFIGURATION="$CONFIGURATION --pkg-config=pkg-config"
  CONFIGURATION="$CONFIGURATION --enable-pic"

  CONFIGURATION="$CONFIGURATION --enable-libx264"
  CONFIGURATION="$CONFIGURATION --enable-encoder=libx264"

  # wavs filter test
  # CONFIGURATION="$CONFIGURATION --enable-filter=wavs"
  # CONFIGURATION="$CONFIGURATION --enable-filter=scale"

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
  --pkg-config-flags=--static \
  || exit 1

  echo "-------- > Start make $FFMPEG_TARGET with -j${BUILD_THREADS}"
  make -j${BUILD_THREADS} || exit 1

  echo "-------- > Start install $FFMPEG_TARGET"
  make install || exit 1
  echo "++++++++ > make and install $FFMPEG_TARGET complete."

  popd

}

build_all() {
  build "x86_64"
}

echo "-------- Start --------"
build_all
echo "-------- End --------"
