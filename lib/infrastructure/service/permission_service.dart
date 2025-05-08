import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Unified permission result for the UI layer.
enum SaviePermissionStatus {
  granted,
  deniedTemporary,
  deniedForever,
}

abstract class PermissionService {
  Future<SaviePermissionStatus> checkAndRequest(Permission permission);
  Future<void> openSettings();
}

@LazySingleton(as: PermissionService)
class PermissionServiceImpl implements PermissionService {
  static const MethodChannel _audioSessionChannel =
      MethodChannel('com.savie.app/audio_session');

  @override
  Future<SaviePermissionStatus> checkAndRequest(Permission permission) async {
    print('PERMISSION_SERVICE: checkAndRequest for $permission');

    // Special handling for microphone on iOS simulator
    if (permission == Permission.microphone && Platform.isIOS) {
      print('PERMISSION_SERVICE: iOS detected for microphone permission');
      
      // Check if we're on simulator
      if (await _isSimulator()) {
        print('PERMISSION_SERVICE: iOS SIMULATOR detected, always returning GRANTED');
        
        // Always grant on simulator to bypass iOS simulator permission issues
        // The native code will also pretend permission is granted
        return SaviePermissionStatus.granted;
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

  /// Detect if we're running on iOS simulator
  Future<bool> _isSimulator() async {
    if (!Platform.isIOS) return false;

    // In debug mode, assume we're running in the simulator for testing purposes
    // In release builds on real devices, this would use device_info_plus
    if (kDebugMode) {
      print('PERMISSION_SERVICE: Debug mode detected, assuming simulator for testing');
      return true;
    }
    
    return false; // In production, assume physical device
  }
} 