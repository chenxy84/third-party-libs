#FFmpeg common options
FFMPEG_COMMON_OPTIONS=
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-gpl"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-nonfree"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-version3"

FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --disable-doc"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --disable-runtime-cpudetect"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-optimizations"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --disable-debug"

FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --disable-avdevice"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --disable-postproc"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --disable-everything"

FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-network"

FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-decoder=aac"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-decoder=aac_latm"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-decoder=mp3"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-decoder=h264"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-decoder=hevc"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-decoder=flv"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-decoder=pcm_alaw"

FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-decoder=vp8"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-decoder=vp9"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-decoder=opus"

FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-demuxer=aac"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-demuxer=mp3"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-demuxer=mov"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-demuxer=hevc"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-demuxer=hls"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-demuxer=mpegts"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-demuxer=rtsp"

FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-demuxer=flv"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-demuxer=dash"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-demuxer=live_flv"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-demuxer=m4v"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-demuxer=matroska"
  
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-muxer=adts"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-muxer=mov"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-muxer=mp4"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-muxer=mpegts"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-muxer=rtp"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-muxer=rtsp"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-muxer=flv"
# FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-muxer=h264"
# FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-muxer=hevc"

FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-parser=aac"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-parser=h264"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-parser=mpegaudio"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-parser=hevc"

FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-parser=vp8"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-parser=vp9"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-parser=opus"

# FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocols"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocol=file"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocol=tcp"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocol=udp"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocol=hls"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocol=http"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocol=https"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocol=rtmp"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocol=rtp"

# FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocol=rtmp"
# FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocol=tcp"
# FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocol=tls"
# FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocol=srtp"
# FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-protocol=udp"

# FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-bsfs"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-bsf=h264_metadata"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-bsf=h264_mp4toannexb"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-bsf=hevc_metadata"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-bsf=hevc_mp4toannexb"
FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-bsf=aac_adtstoasc"

FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-openssl"

FFMPEG_COMMON_OPTIONS="$FFMPEG_COMMON_OPTIONS --enable-filter=aresample"

export FFMPEG_COMMON_OPTIONS=${FFMPEG_COMMON_OPTIONS}

#FFmpeg common options ends
