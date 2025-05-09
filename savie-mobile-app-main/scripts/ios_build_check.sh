#!/bin/bash

# ios_build_check.sh
# Builds iOS app with warnings-as-errors to catch issues early

set -e  # Exit on error

echo "🔍 Running iOS build check with warnings-as-errors..."

# Go to project root
cd "$(dirname "$0")/.."

# Check if any iOS build is in progress
if pgrep -x "Xcode" > /dev/null; then
  echo "⚠️ Warning: Xcode is running. Close Xcode before running this script."
  exit 1
fi

# Clean build artifacts
echo "🧹 Cleaning Flutter build cache..."
flutter clean

# Set environment variables for Xcode
export XCODE_XCCONFIG_FILE=$(pwd)/scripts/ios_warnings_as_errors.xcconfig

# Create temp xcconfig if it doesn't exist
if [ ! -f "$XCODE_XCCONFIG_FILE" ]; then
  echo "Creating iOS warnings-as-errors config..."
  cat > "$XCODE_XCCONFIG_FILE" << EOF
// Treat all warnings as errors
GCC_TREAT_WARNINGS_AS_ERRORS = YES
SWIFT_TREAT_WARNINGS_AS_ERRORS = YES
EOF
fi

# Build iOS with warnings as errors
echo "🔨 Building iOS app (no-codesign)..."
flutter build ios --no-codesign --release

# Check build result
if [ $? -eq 0 ]; then
  echo "✅ iOS build passed with warnings-as-errors!"
  exit 0
else
  echo "❌ iOS build failed with warnings-as-errors. Fix the warnings before committing."
  exit 1
fi 