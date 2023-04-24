#!/usr/bin/env bash

source ${ROOT_PATH}/script/version.sh

export REPO_PATH=${ROOT_PATH}/repos
export TEMP_PATH=${ROOT_PATH}/temp
export DIST_PATH=${ROOT_PATH}/dist

export OPENSSL_REPO_PATH=${REPO_PATH}/openssl-${OPENSSL_VERSION}
export FFMPEG_REPO_PATH=${REPO_PATH}/ffmpeg
export X264_REPO_PATH=${REPO_PATH}/x264

if [ "${BUILD_TARGET}" == "" ]; then
  echo "BUILD_TARGET missing, using export BUILD_TARGET= , to set."
  exit 1
fi

PREFIX=${DIST_PATH}/${BUILD_TARGET}
LOG_PATH=${TEMP_PATH}/${BUILD_TARGET}/log

if [ ! -d "${PREFIX}" ]; then
  mkdir -p ${PREFIX}
fi

if [ ! -d "${LOG_PATH}" ]; then
  mkdir -p ${LOG_PATH}
fi

os=`uname -a`
if [[ "$os" =~ "Darwin" ]];then
  export BUILD_THREADS=$(sysctl hw.ncpu | awk '{print $2}')
else
  export BUILD_THREADS=8
fi
