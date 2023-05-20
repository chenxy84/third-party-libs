#!/usr/bin/env bash

#ref git@github.com:kewlbear/FFmpeg-iOS-build-script.git

SCRIPT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
ROOT_PATH=${SCRIPT_PATH}/../..
source ${ROOT_PATH}/script/common.sh
source ${ROOT_PATH}/script/ffmpeg_modules.sh

build() {

  EXTRA_OPTIONS=
  if [[ -d "/usr/local/cuda/include" ]]; then
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-cuda"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-cuvid"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-nvdec"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-nvenc"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-nonfree"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-libnpp"

    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-decoder=h264_cuvid"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-decoder=hevc_cuvid"

    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-hwaccel=h264_nvdec"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-hwaccel=hevc_nvdec"

    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-encoder=h264_nvenc"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-encoder=hevc_nvenc"

    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-encoder=aac"

    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-filter=scale"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-filter=scale_npp"

    EXTRA_CFLAGS="$EXTRA_CFLAGS -I/usr/local/cuda/include"
    EXTRA_LDFLAGS="$EXTRA_LDFLAGS -L/usr/local/cuda/lib64"

    # patch wavs filter
    if [[ -f "${FFMPEG_REPO_PATH}/libavfilter/vf_wavs.c" ]]; then
      CONFIGURATION="$CONFIGURATION --enable-filter=wavs"
    fi

  else
    EXTRA_OPTIONS="$EXTRA_OPTIONS --disable-nonfree"
  fi

  FFMPEG_TARGET=$1
  echo "======== > Start build $FFMPEG_TARGET"
  case ${FFMPEG_TARGET} in
  Linux_x86_64)
    ARCH=x86_64
    ;;
  esac

  # EXTRA_CFLAGS="$EXTRA_CFLAGS -I$PREFIX/$FFMPEG_TARGET/include"
  # EXTRA_LDFLAGS="$EXTRA_LDFLAGS -L$PREFIX/$FFMPEG_TARGET/lib"

  CONFIGURATION=
  CONFIGURATION="$CONFIGURATION $FFMPEG_COMMON_OPTIONS"
  CONFIGURATION="$CONFIGURATION $EXTRA_OPTIONS"

  CONFIGURATION="$CONFIGURATION --logfile=${LOG_PATH}/ffmpeg_config_$FFMPEG_TARGET.log"
  CONFIGURATION="$CONFIGURATION --prefix=$PREFIX/$FFMPEG_TARGET"
  CONFIGURATION="$CONFIGURATION --target-os=linux"
  CONFIGURATION="$CONFIGURATION --arch=$ARCH"

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
  --cc="$CC" \
  --as="$AS" \
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
  build "Linux_x86_64"
}

echo "-------- Start --------"
build_all
echo "-------- End --------"
