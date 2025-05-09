# iOS Development Guidelines

## Environment Setup

- Xcode 15.2+ on macOS 14+
- Flutter 3.22+ (stable channel)
- CocoaPods 1.13+

## Build Configuration

### Warning Policy

All warnings in iOS builds are treated as errors in our CI/CD pipeline. This helps us maintain a clean, high-quality codebase.

- Local development builds will show warnings but allow compilation
- CI builds use `GCC_TREAT_WARNINGS_AS_ERRORS=YES` and `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`
- Pre-commit hooks will run builds with warnings-as-errors

### Podfile Configuration

Our Podfile uses specific configurations to ensure compatibility with all plugins:

```ruby
# Required configuration
platform :ios, '13.0'
use_frameworks! :linkage => :static
use_modular_headers!

# Warning suppression (only for local development)
installer.pods_project.build_configurations.each do |cfg|
  cfg.build_settings['WARNING_CFLAGS'] = '-Wno-deprecated-declarations'
end
```

### Header Search Paths

The following Flutter header search paths must be maintained for all pods:

```ruby
flutter_header = '${PODS_ROOT}/../Flutter'
config.build_settings['HEADER_SEARCH_PATHS'] = "#{paths} #{flutter_header} #{flutter_header}/Flutter.framework #{flutter_header}/Flutter.framework/Headers"
```

## Common Issues & Solutions

### 'Flutter/Flutter.h' File Not Found

This occurs when a plugin is missing proper header search paths:

1. Make sure the Podfile has the Flutter header search paths for all targets
2. Run `pod deintegrate && pod install --clean-install`
3. If specific plugins fail, check for double-quoted `#import` statements

### Quote Style in Framework Headers

For umbrella header imports, use angle brackets instead of double quotes:

```objective-c
// Correct
#import <MyPlugin/MyPlugin.h>

// Incorrect
#import "MyPlugin.h"
```

### Building for Simulator

- Always use arm64 architecture for Apple Silicon Macs
- Remove any `VALID_ARCHS` settings
- Set `EXCLUDED_ARCHS[sdk=iphonesimulator*]` to empty

## Pre-Commit Checks

Our repository uses Git hooks to enforce quality checks:

1. Flutter analyzer runs to catch Dart/Flutter issues
2. Import sorter runs to maintain consistent imports
3. iOS build check runs to catch iOS-specific issues

To skip hooks in emergencies, use `--no-verify` (but this should be rare).

## Permission Handling

Always include proper usage description keys in Info.plist:

- `NSCameraUsageDescription` - For camera access
- `NSMicrophoneUsageDescription` - For voice recordings
- `NSPhotoLibraryUsageDescription` - For photo picker

Implement proper permission request flows in your code, handling all states:
- Granted
- Denied
- PermanentlyDenied (with Settings redirection)

## Troubleshooting Build Issues

If you encounter build failures:

1. Run `flutter clean`
2. Delete `ios/Pods` and `ios/Podfile.lock`
3. Run `flutter pub get`
4. Run `cd ios && pod install --repo-update && cd ..`
5. Build again with `flutter build ios --no-codesign`

## CI Pipeline Integration

Our CI pipeline runs these checks automatically:
- Format verification 
- Analyzer verification
- iOS build with warnings-as-errors 