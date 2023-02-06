#!/bin/sh

xcodebuild archive -project LivenessDetection.xcodeproj -scheme LivenessDetection -sdk iphoneos -arch arm64 -configuration Release -archivePath ./ios.xcarchive BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO | xcpretty

xcodebuild archive -project LivenessDetection.xcodeproj -scheme LivenessDetection -sdk iphonesimulator -arch x86_64 -configuration Release -archivePath ./iossimulator.xcarchive BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO | xcpretty

rm -rf LivenessDetection.xcframework

xcodebuild -create-xcframework -framework ./ios.xcarchive/Products/Library/Frameworks/LivenessDetection.framework -framework ./iossimulator.xcarchive/Products/Library/Frameworks/LivenessDetection.framework -output LivenessDetection.xcframework
