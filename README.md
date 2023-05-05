# media thirdparty library build script
## include ffmpeg、x264、openssl、etc.

# build requirement

## Android
### Android Studio Version:
https://redirector.gvt1.com/edgedl/android/studio/install/2022.1.1.21/android-studio-2022.1.1.21-mac.dmg

## Darwin (iOS & macOS):
xcode 14.2

brew install nasm yasm

## Windows
Visual Studio Community 2022
Mingw:

# ffmpeg
## list what u need, and modify ffmpeg_modules.
./configure --list-decoders          show all available decoders
./configure --list-encoders          show all available encoders
./configure --list-hwaccels          show all available hardware accelerators
./configure --list-demuxers          show all available demuxers
./configure --list-muxers            show all available muxers
./configure --list-parsers           show all available parsers
./configure --list-protocols         show all available protocols
./configure --list-bsfs              show all available bitstream filters
./configure --list-indevs            show all available input devices
./configure --list-outdevs           show all available output devices
./configure --list-filters           show all available filters


