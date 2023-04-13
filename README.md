# deps_build


# build requirement
## Android
ndk 25
https://dl.google.com/android/repository/android-ndk-r25c-darwin.zip

## Darwin (iOS & macOS):
xcode 14.2
Windows:
brew install nasm yasm

## Windows
Visual Studio Community 2022
Mingw:

# ffmpeg
## list what u need
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