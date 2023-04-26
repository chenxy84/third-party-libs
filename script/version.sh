#!/usr/bin/env bash

export OPENSSL_VERSION=1.1.1t
export FFMPEG_VERSION=5.1.3
export X264_VERSION=master
export CURL_VERSION=8.0.1

#https://git.ffmpeg.org/ffmpeg.git
export FFMPEG_GIT_URL=git@github.com:chenxy84/ffmpeg.git
export FFMPEG_GIT_BRANCH=dev/chenxiangyu/release_5.1

export X264_GIT_URL=https://code.videolan.org/videolan/x264.git
export X264_GIT_BRANCH=stable

export PATCHES_GIT_URL=git@github.com:chenxy84/third-party-libs-patches.git
export PATCHES_GIT_BRANCH=main