#!/usr/bin/env bash

#ref git@github.com:kewlbear/FFmpeg-iOS-build-script.git

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


#need fix
# sed -i .tmp "s/s\+({/s\+(\\\\{/g;s/s\*})/s\*\\\\})/g" ./script/Darwin/tools/gas-preprocessor.pl
#
# if [ ! `which gas-preprocessor.pl` ]
# then
#   echo 'gas-preprocessor.pl not found. Trying to install...'
#   (curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl \
#     -o /usr/local/bin/gas-preprocessor.pl \
#     && chmod +x /usr/local/bin/gas-preprocessor.pl) \
#     || exit 1
# fi

export PATH=${SCRIPT_PATH}/tools:$PATH

IOS_DEPLOYMENT_TARGET="9.0"
MACOS_DEPLOYMENT_TARGET="10.14"

build() {
  FFMPEG_TARGET=$1

  EXTRA_OPTIONS=
  EXTRA_CFLAGS=
  EXTRA_CXXFLAGS=
  EXTRA_LDFLAGS=

  echo "======== > Start build $FFMPEG_TARGET"

  case ${FFMPEG_TARGET} in
  iOS_arm64)
    PLATFORM=iPhoneOS
    ARCH=arm64
    CC="xcrun -sdk iphoneos clang"
    AS="gas-preprocessor.pl -arch aarch64 -- $CC"
    EXTRA_CFLAGS="-arch $ARCH -mios-version-min=$IOS_DEPLOYMENT_TARGET  -fembed-bitcode"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-cross-compile"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --disable-programs"
    ;;
  iOS_Simulator_x86_64)
    PLATFORM=iPhoneSimulator
    ARCH=x86_64
    CC="xcrun -sdk iphonesimulator clang"
    AS="gas-preprocessor.pl -- $CC"
    EXTRA_CFLAGS="$CFLAGS -mios-simulator-version-min=$IOS_DEPLOYMENT_TARGET"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-cross-compile"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --disable-programs"
    ;;
  macOS_x86_64)
    PLATFORM=MacOSX
    ARCH=x86_64
    CC="xcrun clang"
    # AS="gas-preprocessor.pl -- $CC"
    AS="$CC"
    EXTRA_CFLAGS="$CFLAGS -target x86_64-apple-macos -arch x86_64 -mmacosx-version-min=$MACOS_DEPLOYMENT_TARGET"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-parser=vp8"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-parser=vp9"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-decoder=vp8"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-decoder=vp9"
    EXTRA_OPTIONS="$EXTRA_OPTIONS --enable-demuxer=matroska"
    ;;
  esac

  EXTRA_CFLAGS="$EXTRA_CFLAGS"
  EXTRA_CXXFLAGS="$EXTRA_CXXFLAGS $EXTRA_CFLAGS"
  EXTRA_LDFLAGS="$EXTRA_LDFLAGS $EXTRA_CFLAGS"

  # OPENSSL_LIB=$PREFIX/$FFMPEG_TARGET
  # EXTRA_CFLAGS="$EXTRA_CFLAGS -I$OPENSSL_LIB/include"
  # EXTRA_LDFLAGS="$EXTRA_LDFLAGS -L$OPENSSL_LIB/lib"

  CONFIGURATION=
  CONFIGURATION="$CONFIGURATION $FFMPEG_COMMON_OPTIONS"
  CONFIGURATION="$CONFIGURATION $EXTRA_OPTIONS"

  CONFIGURATION="$CONFIGURATION --logfile=${LOG_PATH}/ffmpeg_config_$FFMPEG_TARGET.log"
  CONFIGURATION="$CONFIGURATION --prefix=$PREFIX/$FFMPEG_TARGET"
  CONFIGURATION="$CONFIGURATION --target-os=darwin"
  CONFIGURATION="$CONFIGURATION --arch=$ARCH"
  CONFIGURATION="$CONFIGURATION --pkg-config=pkg-config"

  CONFIGURATION="$CONFIGURATION --enable-audiotoolbox"
  CONFIGURATION="$CONFIGURATION --enable-videotoolbox"

  CONFIGURATION="$CONFIGURATION --enable-encoder=h264_videotoolbox"
  CONFIGURATION="$CONFIGURATION --enable-encoder=hevc_videotoolbox"

  CONFIGURATION="$CONFIGURATION --enable-libx264"
  CONFIGURATION="$CONFIGURATION --enable-encoder=libx264"
  
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
  || exit 1

  echo "-------- > Start make $FFMPEG_TARGET with -j${BUILD_THREADS}"
  make -j${BUILD_THREADS} || exit 1

  echo "-------- > Start install $FFMPEG_TARGET"
  make install || exit 1
  echo "++++++++ > make and install $FFMPEG_TARGET complete."

  popd

}

build_ios_fat_lib() {

  fat_target_path=$PREFIX/iOS_fat
  if [ -d "${fat_target_path}" ]; then
    rm -rf ${fat_target_path}
  fi

  mkdir -p ${fat_target_path}/lib

  # $PREFIX/iOS_arm64/

  libs=
  libs+=(libavcodec.a)
  libs+=(libavfilter.a)
  libs+=(libavformat.a)
  libs+=(libavutil.a)
  libs+=(libswresample.a)
  libs+=(libswscale.a)
  libs+=(libcrypto.a)
  libs+=(libssl.a)
  libs+=(libx264.a)

  for lib in ${libs[@]}
  do
    echo "create fat lib $lib"
    lipo -create \
    $PREFIX/iOS_arm64/lib/${lib} \
    $PREFIX/iOS_Simulator_x86_64/lib/${lib} \
    -output ${fat_target_path}/lib/${lib}
  done

  cp -rf $PREFIX/iOS_arm64/include ${fat_target_path}/
  cp -f ${FFMPEG_REPO_PATH}/libavformat/avc.h ${fat_target_path}/include/libavformat/

  # lipo -create 

}

build_all() {
  # build "iOS_arm64"
  # build "iOS_Simulator_x86_64"
  build "macOS_x86_64" 

  build_ios_fat_lib
}

echo "-------- Start --------"
build_all
echo "-------- End --------"
