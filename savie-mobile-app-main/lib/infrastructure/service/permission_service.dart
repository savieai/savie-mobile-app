import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Unified permission result for the UI layer.
enum SaviePermissionStatus {
  granted,
  deniedTemporary,
  deniedForever,
}

abstract class PermissionService {
  Future<SaviePermissionStatus> checkAndRequest(Permission permission);
  Future<void> openSettings();
  Future<bool> setupAudioSession();
}

@LazySingleton(as: PermissionService)
class PermissionServiceImpl implements PermissionService {
  static const MethodChannel _audioSessionChannel =
      MethodChannel('com.savie.app/audio_session');

  // Add a flag to track if we've attempted to set up the audio session
  bool _audioSessionSetupAttempted = false;
  
  @override
  Future<SaviePermissionStatus> checkAndRequest(Permission permission) async {
    print('PERMISSION_SERVICE: checkAndRequest for $permission');

    // Special handling for microphone on iOS
    if (permission == Permission.microphone && Platform.isIOS) {
      print('PERMISSION_SERVICE: iOS detected for microphone permission');
      
      // Check if we're on simulator in debug mode
      if (await _isSimulator()) {
        print('PERMISSION_SERVICE: iOS SIMULATOR detected, always returning GRANTED');
        
        // Always grant on simulator to bypass iOS simulator permission issues
        return SaviePermissionStatus.granted;
      }
      
      // On real device, setup audio session before proceeding
      if (!_audioSessionSetupAttempted) {
        await setupAudioSession();
      }
      
      // On real device, proceed with normal flow
      print('PERMISSION_SERVICE: iOS physical device detected');
    }

    // Initial status check
    print('PERMISSION_SERVICE: Checking permission status');
    PermissionStatus status = await permission.status;
    print('PERMISSION_SERVICE: Initial status: $status');
    
    if (status.isGranted) {
      print('PERMISSION_SERVICE: Already granted');
      return SaviePermissionStatus.granted;
    }

    // If we're on iOS and checking microphone, double-check with the native code
    if (permission == Permission.microphone && Platform.isIOS && !await _isSimulator()) {
      try {
        final bool hasActualPermission =
            await _audioSessionChannel.invokeMethod<bool>('checkActualPermission') ??
                false;
        print('PERMISSION_SERVICE: Native permission check: $hasActualPermission');
        if (hasActualPermission) {
          print('PERMISSION_SERVICE: Native code reports permission IS granted');
          return SaviePermissionStatus.granted;
        }
      } catch (e) {
        print('PERMISSION_SERVICE: Native permission check failed: $e');
      }
    }

    // Request once
    print('PERMISSION_SERVICE: Requesting permission');
    status = await permission.request();
    print('PERMISSION_SERVICE: Request result: $status');

    if (status.isGranted) {
      print('PERMISSION_SERVICE: Permission granted after request');
      return SaviePermissionStatus.granted;
    }

    // On Android the user can mark "Don't ask again" which returns permanentlyDenied.
    if (status.isPermanentlyDenied) {
      print('PERMISSION_SERVICE: Permission permanently denied');
      return SaviePermissionStatus.deniedForever;
    }

    // iOS returns `denied` repeatedly for microphone after the first refusal; treat as temporary so we can
    // decide in the UI when to nudge the user to Settings instead of looping automatically.
    print('PERMISSION_SERVICE: Permission denied temporarily');
    return SaviePermissionStatus.deniedTemporary;
  }

  @override
  Future<void> openSettings() => openAppSettings();

  @override
  Future<bool> setupAudioSession() async {
    print('PERMISSION_SERVICE: Setting up audio session');
    _audioSessionSetupAttempted = true;
    
    if (!Platform.isIOS) {
      print('PERMISSION_SERVICE: Not iOS, skipping audio session setup');
      return true;
    }
    
    try {
      print('PERMISSION_SERVICE: Calling native setupAudioSession');
      final bool result = await _audioSessionChannel.invokeMethod<bool>('setupAudioSession') ?? false;
      print('PERMISSION_SERVICE: Native audio session setup result: $result');
      return result;
    } catch (e) {
      print('PERMISSION_SERVICE: Error setting up audio session: $e');
      return false;
    }
  }

  /// Detect if we're running on iOS simulator
  Future<bool> _isSimulator() async {
    if (!Platform.isIOS) return false;

    // In debug mode, check if we're on simulator
    if (kDebugMode) {
      try {
        // In real TestFlight builds, this should correctly identify physical devices
        final String model = await _getDeviceModel();
        print('PERMISSION_SERVICE: Device model: $model');
        final bool isSimulator = model.toLowerCase().contains('simulator');
        print('PERMISSION_SERVICE: Is simulator based on model: $isSimulator');
        return isSimulator;
      } catch (e) {
        print('PERMISSION_SERVICE: Error detecting simulator: $e');
        // If we can't detect, assume it's not a simulator in production
        final bool isTestFlight = await _isTestFlightBuild();
        print('PERMISSION_SERVICE: Is TestFlight build: $isTestFlight');
        return !isTestFlight;
      }
    }
    
    return false; // In production, assume physical device
  }
  
  Future<String> _getDeviceModel() async {
    try {
      final String model = await _audioSessionChannel.invokeMethod<String>('getDeviceModel') ??
          (Platform.isIOS ? 'unknown_ios_device' : 'unknown_device');
      return model;
    } catch (e) {
      // Fallback if method channel fails
      return Platform.isIOS ? 'unknown_ios_device' : 'unknown_device';
    }
  }
  
  Future<bool> _isTestFlightBuild() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      // TestFlight builds usually have a specific pattern in their build number
      return packageInfo.packageName.toLowerCase().contains('testflight') ||
          (await _audioSessionChannel.invokeMethod<bool>('isTestFlightBuild') ?? false);
    } catch (e) {
      print('PERMISSION_SERVICE: Error checking TestFlight status: $e');
      return false;
    }
  }
} 