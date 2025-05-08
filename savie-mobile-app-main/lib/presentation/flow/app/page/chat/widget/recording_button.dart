import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../../../../../presentation.dart';
import '../../../../../../application/application.dart';
import '../../../../../../domain/domain.dart';

class RecordingButton extends StatelessWidget {
  const RecordingButton({super.key});

  @override
  Widget build(BuildContext context) {
    // On simulator, use a simplified recording button
    if (kDebugMode && Platform.isIOS) {
      return _SimulatorFriendlyRecordingButton();
    }

    // Regular implementation for normal devices
    return XGestureDetector(
      longPressTimeConsider: 200,
      onLongPress: (_) async {
        final PermissionStatus raw = await Permission.microphone.status;
        print('RECORDING_DEBUG: Long-press permission status: $raw');
        if (raw.isGranted) {
          print('RECORDING_DEBUG: Permission IS granted, starting recording');
          HapticFeedback.mediumImpact();
          getIt
              .get<TrackUseActivityUseCase>()
              .execute(AppEvents.chat.voiceButtonClicked);
          context.read<RecordingCubit>().startRecording();
        } else {
          print('RECORDING_DEBUG: Permission NOT granted, ignoring long-press');
          // Ignore long-press when permission not yet granted; a prior tap will handle it.
        }
      },
      onLongPressEnd: () {
        if (context.read<RecordingCubit>().state.isRecording) {
          print('RECORDING_DEBUG: Ending recording');
          context.read<RecordingCubit>().finishRecording();
        }
      },
      onTap: (_) async {
        print('RECORDING_DEBUG: Tap detected, current status: ${await Permission.microphone.status}');
        // Single tap requests permission if needed, otherwise toggles recording quickly.
        final status = await Future.delayed(const Duration(milliseconds: 50), () async {
          print('RECORDING_DEBUG: Requesting microphone permission');
          return await Permission.microphone.request();
        });
        
        print('RECORDING_DEBUG: Permission request result: $status');

        if (!status.isGranted) {
          // User denied; no further action.
          print('RECORDING_DEBUG: Permission denied, aborting');
          return;
        }

        // Permission is granted now. Give UIKit a moment to close the alert before any long-press.
        print('RECORDING_DEBUG: Permission granted, proceeding');
        HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 300));
        print('RECORDING_DEBUG: Delay complete, can proceed with recording');

        if (!context.read<RecordingCubit>().state.isRecording) {
          // Optional: start immediate recording on tap if UX wants.
          // comment out the next line if you strictly want long-press only.
          print('RECORDING_DEBUG: Starting recording on tap');
          context.read<RecordingCubit>().startRecording();
        } else {
          print('RECORDING_DEBUG: Ending recording on tap');
          context.read<RecordingCubit>().finishRecording();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Assets.icons.mic24.svg(
          colorFilter: const ColorFilter.mode(
            AppColors.iconSecodary,
            BlendMode.srcIn,
          ),
        ),
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
