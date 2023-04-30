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
    tar zxvf ${ARCHS_PATH}/${OPENSSL_FILE_NAME}.tar.gz -C ${REPO_PATH}
    mv ${REPO_PATH}/${OPENSSL_FILE_NAME} ${OPENSSL_REPO_PATH}
  fi

  if [ ! -d "${X264_REPO_PATH}" ]; then
    # pushd ${REPO_PATH}
    #   git clone --branch $X264_GIT_BRANCH --depth=1 $X264_GIT_URL
    # popd
    tar zxvf ${ARCHS_PATH}/${X264_FILE_NAME}.tar.bz2 -C ${REPO_PATH}
    mv ${REPO_PATH}/${X264_FILE_NAME} ${X264_REPO_PATH}
  fi

  if [ ! -d "${FFMPEG_REPO_PATH}" ]; then
    # pushd ${REPO_PATH}
    #   git clone --branch $FFMPEG_GIT_BRANCH --depth=1 $FFMPEG_GIT_URL ffmpeg
    # popd
    tar zxvf ${ARCHS_PATH}/${FFMPEG_FILE_NAME}.tar.gz -C ${REPO_PATH}
    mv ${REPO_PATH}/${FFMPEG_FILE_NAME} ${FFMPEG_REPO_PATH}
  fi

  # TODO apply patches
  if [ ! -d "${PATCHES_REPO_PATH}" ]; then
    pushd ${REPO_PATH}
      git clone --branch $PATCHES_GIT_BRANCH --depth=1 $PATCHES_GIT_URL patches
    popd
    bash ${PATCHES_REPO_PATH}/do.sh
  fi
}

build_main()
{
  
  start=$(date +%s)

  export BUILD_TARGET=${BUILD_TARGET}
  
  echo "Build ${BUILD_PROJECT} for ${BUILD_TARGET}, with debug option is ${IS_DEBUG}"

  echo "shell: ${SCRIPT_PATH}/${BUILD_TARGET}/build_${BUILD_PROJECT}.sh"
  echo "log: ${LOG_PATH}/build_${BUILD_PROJECT}_${BUILD_TARGET}.log"

  (bash ${SCRIPT_PATH}/${BUILD_TARGET}/build_${BUILD_PROJECT}.sh > ${LOG_PATH}/build_${BUILD_PROJECT}_${BUILD_TARGET}.log 2>&1) & spinner

  end=$(date +%s)
  cost=$(( end - start ))
  echo "Build ${BUILD_PROJECT} for ${BUILD_TARGET} End, cost time = ${cost}s"

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
export ROOT_PATH=$(cd "${SCRIPT_PATH}/.." && pwd)
export ARCHS_PATH=${ROOT_PATH}/archs

PROJECTS="[ffmpeg|openssl|libx264|libx265|libcurl]"
TARGETS="[Darwin|Android|Windows|Linux]"

BUILD_PROJECT=
BUILD_TARGET=
IS_DEBUG=false

print_usage() 
{
    echo "Usage: base ${0} \n" \
         "\t -p ${PROJECTS} \n" \
         "\t -t ${TARGETS} \n" \
         "\t -d (optional, debug build) \n"
    echo "Example: bash ${0} ffmpeg darwin"
}

while getopts ":p:t:d" opt; do
  case $opt in
    p)
      #echo "-p arg:$OPTARG index:$OPTIND"
      BUILD_PROJECT=$OPTARG
    ;;
    t)
      BUILD_TARGET=$OPTARG
    ;;
    d)
      IS_DEBUG=true
    ;;
    :)
      echo "Option -$OPTARG requires an arguement."
      print_usage
    ;;
    ?)
      echo "Invalid option: -$OPTARG index:$OPTIND"
      print_usage
    ;;
  esac
done

if [[ ! "$PROJECTS" =~ "$BUILD_PROJECT" ]] ; then
  print_usage
  exit 1
fi

if [[ ! "$TARGETS" =~ "$BUILD_TARGET" ]] ; then
  print_usage
  exit 1
fi

source ${ROOT_PATH}/script/common.sh

prepare_source
build_main


