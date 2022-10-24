#!/bin/bash

set -e

gh api https://api.github.com/repos/madler/zlib/tarball/v1.2.8 | tar -zx --strip-components 1 -C third-party/zlib/

gh release -R libexpat/libexpat download -p expat-2.4.7.tar.gz R_2_4_7
tar -zxf expat-2.4.7.tar.gz --strip-components 1 -C third-party/expat/
rm expat-2.4.7.tar.gz

cd build
./GenerateXMPToolkitSDK_mac.sh 4

xcodebuild -project xcode/static/ios/XMPToolkitSDK.xcodeproj/ -scheme ALL_BUILD -destination "generic/platform=iOS Simulator" -configuration Release ARCHS=x86_64
xcodebuild -project xcode/static/ios/XMPToolkitSDK.xcodeproj/ -scheme ALL_BUILD -destination "generic/platform=iOS" -configuration Release ARCHS=arm64
cd ..

lipo -create public/libraries/ios/arm64/Release/libXMPCoreStatic.a public/libraries/ios/x86_64/Release/libXMPCoreStatic.a -output libXMPCoreStatic.a
lipo -create public/libraries/ios/arm64/Release/libXMPFilesStatic.a public/libraries/ios/x86_64/Release/libXMPFilesStatic.a -output libXMPFilesStatic.a
libtool -static -o libXMP.a libXMPCoreStatic.a libXMPFilesStatic.a

mkdir -p XMP.framework/Headers
mv libXMP.a XMP.framework/XMP
cp -r public/include/* XMP.framework/Headers/
sed -i '' 's/#include\ \"/#include\ \"XMP\//g' $(find XMP.framework/Headers/ -type f)

gem install xcframework_converter
xcfconvert XMP.framework ios
zip --symlinks -r xmp.zip XMP.xcframework

