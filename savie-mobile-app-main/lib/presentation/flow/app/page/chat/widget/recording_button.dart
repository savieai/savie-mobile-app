import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' show Colors, SnackBar, SnackBarAction, ScaffoldMessenger, Text, showDialog, AlertDialog, TextButton;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

import '../../../../../presentation.dart';
import '../../../../../../application/application.dart';
import '../../../../../../domain/domain.dart';
import '../../../../../../infrastructure/service/permission_service.dart';

class RecordingButton extends StatelessWidget {
  const RecordingButton({super.key});

  @override
  Widget build(BuildContext context) {
    // In debug mode on iOS simulator, use simplified button
    if (kDebugMode && Platform.isIOS) {
      // Use the simulator-friendly version during development
      return _SimulatorFriendlyRecordingButton();
    }

    // Production version for real devices
    return XGestureDetector(
      longPressTimeConsider: 200,
      onLongPress: (_) async {
        // Handle long press gesture
        _handleRecordingAction(context, isLongPress: true);
      },
      onLongPressEnd: () {
        if (context.read<RecordingCubit>().state.isRecording) {
          print('RECORDING_DEBUG: Ending recording on long press end');
          context.read<RecordingCubit>().finishRecording();
        }
      },
      onTap: (_) async {
        // Handle tap gesture
        _handleRecordingAction(context, isLongPress: false);
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocBuilder<RecordingCubit, RecordingState>(
          builder: (context, state) {
            // Show feedback when recording
            return state.isRecording 
              ? Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Assets.icons.mic24.svg(
                    colorFilter: const ColorFilter.mode(
                      Colors.red,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : Assets.icons.mic24.svg(
                  colorFilter: const ColorFilter.mode(
                    AppColors.iconSecodary,
                    BlendMode.srcIn,
                  ),
                );
          },
        ),
      ),
    );
  }
  
  Future<void> _handleRecordingAction(BuildContext context, {required bool isLongPress}) async {
    print('RECORDING_DEBUG: ${isLongPress ? "Long press" : "Tap"} detected');
    
    // Access recorder cubit and check recording state
    final recordingCubit = context.read<RecordingCubit>();
    final isRecording = recordingCubit.state.isRecording;
    
    // If already recording, stop it
    if (isRecording) {
      print('RECORDING_DEBUG: Already recording, stopping now');
      recordingCubit.finishRecording();
      return;
    }
    
    // First, set up audio session (only needed for iOS)
    if (Platform.isIOS) {
      print('RECORDING_DEBUG: iOS detected, ensuring audio session is ready');
      final permissionService = getIt<PermissionService>();
      try {
        final bool setupSuccess = await permissionService.setupAudioSession();
        print('RECORDING_DEBUG: Audio session setup result: $setupSuccess');
        if (!setupSuccess) {
          _showPermissionError(context, "Could not set up audio session");
          return;
        }
      } catch (e) {
        print('RECORDING_DEBUG: Audio session setup error: $e');
        // Continue and let the permission check handle specific issues
      }
    }
    
    // Check current permission status
    final PermissionStatus status = await Permission.microphone.status;
    print('RECORDING_DEBUG: Current permission status: $status');
    
    if (status.isPermanentlyDenied) {
      // User has permanently denied, show dialog to open settings
      _showOpenSettingsDialog(context);
      return;
    }
    
    if (!status.isGranted) {
      // Need to request permission
      print('RECORDING_DEBUG: Permission not granted, requesting now');
      final PermissionStatus result = await Permission.microphone.request();
      print('RECORDING_DEBUG: Permission request result: $result');
      
      if (!result.isGranted) {
        // Permission denied, show error
        _showPermissionError(context, "Microphone permission required to record voice notes");
        return;
      }
      
      // Permission just granted, add a small delay to let iOS UI settle
      if (Platform.isIOS) {
        print('RECORDING_DEBUG: Permission newly granted on iOS, small delay before recording');
        await Future.delayed(Duration(milliseconds: 300));
      }
    }
    
    // Permission is granted, start recording
    print('RECORDING_DEBUG: Permission granted, starting recording');
    HapticFeedback.mediumImpact();
    getIt.get<TrackUseActivityUseCase>().execute(AppEvents.chat.voiceButtonClicked);
    recordingCubit.startRecording();
  }
  
  void _showPermissionError(BuildContext context, String message) {
    print('RECORDING_DEBUG: Showing permission error: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  }
  
  void _showOpenSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Microphone Access Required'),
        content: Text('Please enable microphone access in your device settings to record voice notes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

/// A simplified recording button that works reliably on the iOS simulator
/// by using regular tap gestures instead of long-press that can conflict
/// with the permission dialog.
class _SimulatorFriendlyRecordingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if recording is active
    final bool isRecording = context.select(
      (RecordingCubit cubit) => cubit.state.isRecording,
    );

    return GestureDetector(
      // Use simple onTap to avoid gesture gate issues
      onTap: () async {
        print('SIMULATOR: Tap detected on simulator-friendly button');
        
        if (isRecording) {
          // If already recording, stop it
          print('SIMULATOR: Stopping recording');
          await context.read<RecordingCubit>().finishRecording();
        } else {
          // Start recording - no permission check, simulator always grants
          print('SIMULATOR: Starting recording');
          HapticFeedback.mediumImpact();
          
          // Bypass permission checking in debug mode for simulator
          // This uses the already-modified PermissionService that always
          // returns granted for microphone on iOS simulator
          context.read<RecordingCubit>().startRecording();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // Visual feedback to show recording state
          color: isRecording ? Colors.red.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Assets.icons.mic24.svg(
          colorFilter: ColorFilter.mode(
            isRecording ? Colors.red : AppColors.iconSecodary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
