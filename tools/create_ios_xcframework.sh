#!/bin/bash
set -e

cd build
./GenerateXMPToolkitSDK_mac.sh 4

xcodebuild -project xcode/static/ios/XMPToolkitSDK.xcodeproj/ -scheme ALL_BUILD -destination "generic/platform=iOS Simulator" -configuration Release ARCHS="x86_64 arm64"
xcodebuild -project xcode/static/ios/XMPToolkitSDK.xcodeproj/ -scheme ALL_BUILD -destination "generic/platform=iOS" -configuration Release ARCHS=arm64
cd ..

mkdir -p output/
libtool -static -o output/libXMP_simulator.a "public/libraries/ios/x86_64 arm64/Release/libXMPFilesStatic.a" "public/libraries/ios/x86_64 arm64/Release/libXMPFilesStatic.a"
libtool -static -o output/libXMP.a "public/libraries/ios/arm64/Release/libXMPFilesStatic.a" "public/libraries/ios/arm64/Release/libXMPFilesStatic.a"

mkdir -p output/ios/XMP.framework/Headers
mv output/libXMP.a output/ios/XMP.framework/XMP
cp -r public/include/* output/ios/XMP.framework/Headers
find output/ios/XMP.framework/Headers/ -type f -exec sed -i '' 's/#include\ \"/#include\ \"XMP\//g' {} \;

mkdir -p output/ios_simulator/XMP.framework/Headers
mv output/libXMP_simulator.a output/ios_simulator/XMP.framework/XMP
cp -r public/include/* output/ios_simulator/XMP.framework/Headers
find output/ios_simulator/XMP.framework/Headers -type f -exec sed -i '' 's/#include\ \"/#include\ \"XMP\//g' {} \;

xcodebuild -create-xcframework -framework output/ios/XMP.framework -framework output/ios_simulator/XMP.framework -output output/XMP.xcframework

zip --symlinks -r xmp.zip output/XMP.xcframework
