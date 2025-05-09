#!/bin/bash

# Exit on any error
set -e

echo "Starting custom build process..."

# Clean the project
echo "Cleaning previous builds..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Update CocoaPods
echo "Updating CocoaPods..."
cd ios
pod deintegrate
pod setup
pod install

# (removed legacy architecture hacks)
# Add workaround for known issues
echo "Adding workarounds for known issues..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*

# Build for simulator
echo "Building for simulator..."
cd ..
flutter build ios --debug --simulator

echo "Build process completed. Now use 'flutter run' to launch the app." 