#!/usr/bin/env bash

spinner() {
  export pid=$!
  # echo "build shell pid: $pid"
  spinner_pid $pid
}

spinner_pid()
{
  local build_threads=${BUILD_THREADS}
  local pid=$1
  local delay=$(echo "1.0 / $build_threads" | bc)
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c]" "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b"
  done

  wait $pid
  return $?
}

prepare_source()
{
  set +e
  if [ ! -d "${REPO_PATH}" ]; then
    mkdir -p ${REPO_PATH}
  fi

  if [ ! -d "${OPENSSL_REPO_PATH}" ]; then
    tar zxvf ${ARCHS_PATH}/openssl-${OPENSSL_VERSION}.tar.gz -C ${REPO_PATH}
  fi

  if [ ! -d "${X264_REPO_PATH}" ]; then
    pushd ${REPO_PATH}
      git clone --branch $X264_GIT_BRANCH --depth=1 $X264_GIT_URL
    popd
  fi

  if [ ! -d "${FFMPEG_REPO_PATH}" ]; then
    pushd ${REPO_PATH}
      git clone --branch $FFMPEG_GIT_BRANCH --depth=1 $FFMPEG_GIT_URL
    popd
  fi
}

print_usage() 
{
    echo "Build script for ffmpeg and libs"
    echo "Usage: ${0}\n" \
         "with option: ${TARGET_PARAMS} [--with-openssl|--with-x264] "
}

build_main()
{
  
  start=$(date +%s)
  echo "Building for ${BUILD_TARGET}"

  WITH_OPNESSL=false
  WITH_X264=false

  for arg in $*
  do
    if [[ "$arg" == "--with-openssl" ]]; then
      WITH_OPNESSL=true
    elif [[ "$arg" == "--with-x264" ]]; then
      WITH_X264=true
    fi
  done

  if [[ $WITH_OPNESSL == true ]]; then
    echo "Running build openssl script for ${BUILD_TARGET}"
    (bash ${SCRIPT_PATH}/${BUILD_TARGET}/build_openssl.sh > ${LOG_PATH}/build_openssl_${BUILD_TARGET}.log 2>&1) & spinner
  fi

  if [[ $WITH_X264 == true ]]; then
    echo "Running build x264 script for ${BUILD_TARGET}"
    (bash ${SCRIPT_PATH}/${BUILD_TARGET}/build_libx264.sh > ${LOG_PATH}/build_libx264_${BUILD_TARGET}.log 2>&1) & spinner
  fi

  # echo "Running build ffmpeg script for ${BUILD_TARGET}"
  # (bash ${SCRIPT_PATH}/${BUILD_TARGET}/build_ffmpeg.sh > ${LOG_PATH}/build_ffmpeg_${BUILD_TARGET}.log 2>&1) & spinner
  
  end=$(date +%s)
  cost=$(( end - start ))
  echo "Building for ${BUILD_TARGET} End, cost time = ${cost}s"

  exit 0
}

trap 'on_cancel' INT
on_cancel() {
  if [[ "$pid" && "$(ps a | awk '{print $1}' | grep $pid)" ]]; then
    echo ""
    echo "Build cancelled, kill process $pid"
    kill -9 $pid
  fi
  exit 1
}

SCRIPT_PATH=$(cd "$( dirname "${BASH_SOURCE}[0]}" )" && pwd)
export ROOT_PATH="${SCRIPT_PATH}"/..
export ARCHS_PATH=${ROOT_PATH}/archs

export BUILD_TARGET="$1"
TARGET_PARAMS="[Android|Darwin|Windows|Linux]"

export BUILD_WITH_LIBS=false

if [[ ! "$TARGET_PARAMS" =~ "$BUILD_TARGET" ]] ; then
  print_usage
  exit 1
fi

source ${ROOT_PATH}/script/common.sh

prepare_source
build_main $*


