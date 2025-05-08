// ignore_for_file: body_might_complete_normally_nullable

import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

import '../../../domain/domain.dart';
import '../../../infrastructure/service/permission_service.dart';

part 'recording_state.dart';
part 'recording_cubit.freezed.dart';

@Injectable()
class RecordingCubit extends Cubit<RecordingState> {
  RecordingCubit(this._permissionService)
      : super(RecordingState.idle(
          lastRecordingResult: RecordingResult.none,
        ));

  AudioRecorder? _recorder;
  final PermissionService _permissionService;

  StreamSubscription<Amplitude>? _amplitudeSubscription;
  Timer? _timer;
  final List<double> _peeks = <double>[];
  int _seconds = 0;

  static const MethodChannel _audioSessionChannel =
      MethodChannel('com.savie.app/audio_session');

  Future<void> startRecording() async {
    print('RECORDING_CUBIT: startRecording called');
    
    // First check if already recording to prevent duplicate calls
    if (state is _Recording) {
      print('RECORDING_CUBIT: Already recording, ignoring duplicate call');
      return;
    }
    
    // Check microphone permission using the unified service
    print('RECORDING_CUBIT: Checking permission via service');
    final SaviePermissionStatus permissionStatus =
        await _permissionService.checkAndRequest(Permission.microphone);
    print('RECORDING_CUBIT: Permission service returned: $permissionStatus');

    if (permissionStatus != SaviePermissionStatus.granted) {
      print('RECORDING_CUBIT: Permission not granted, aborting');
      // We simply abort recording here. The UI can decide whether to show
      // a dialog/snackbar suggesting the user to open Settings.
      return;
    }
    
    print('RECORDING_CUBIT: Permission granted, proceeding with recording setup');
    // Lazily create recorder (avoids mic prompt on app launch)
    _recorder ??= AudioRecorder();
    print('RECORDING_CUBIT: Recorder initialized');

    // Emit recording state immediately to update UI
    emit(
      RecordingState.recording(
        startTime: DateTime.now(),
        peek: 0,
        seconds: _seconds,
        isFixed: false,
      ),
    );
    print('RECORDING_CUBIT: Emitted Recording state');

    // Start directory setup and recorder initialization in a fire-and-forget manner
    _setupRecorderAsync();
    print('RECORDING_CUBIT: Called _setupRecorderAsync()');
  }

  // Separate method to handle async operations without blocking the UI
  Future<void> _setupRecorderAsync() async {
    try {
      print('RECORDING_CUBIT: Setting up recorder...');
      // Ensure iOS audio session is configured before interacting with the recorder.
      if (Platform.isIOS) {
        print('RECORDING_CUBIT: iOS platform detected, configuring audio session');
        try {
          print('RECORDING_CUBIT: Invoking native setupAudioSession');
          await _audioSessionChannel.invokeMethod('setupAudioSession');
          print('RECORDING_CUBIT: Native setupAudioSession completed successfully');
        } catch (e) {
          print('RECORDING_CUBIT: ERROR in setupAudioSession: $e');
          // Non-fatal: fall back to record's own configuration.
          print('Failed to setup iOS audio session via native channel: $e');
        }
      }

      final Directory tempDir = await getApplicationCacheDirectory();
      int counter = 0;

      _amplitudeSubscription = _recorder!
          .onAmplitudeChanged(const Duration(milliseconds: 10))
          .listen((Amplitude amplitude) {
        if (state is _Recording) {
          final double peek =
              1 - (((-amplitude.current).clamp(10, 50)) - 10) / 40;
          if (counter % 10 == 0) {
            _peeks.add(peek);
          }
          emit((state as _Recording).copyWith(peek: peek));
          counter++;
        }
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (state is _Recording) {
          _seconds++;
          emit((state as _Recording).copyWith(seconds: _seconds));
        }
        _timer = timer;
      });

      // Start recorder with path
      print('RECORDING_CUBIT: Starting recorder with path');
      await _recorder!.start(
        const RecordConfig(),
        path: '${tempDir.path}/${const Uuid().v4()}.m4a',
      );
      print('RECORDING_CUBIT: Recorder started successfully');
    } catch (e) {
      // Handle errors gracefully
      print('RECORDING_CUBIT: ERROR starting recorder: $e');
      print('Error setting up recorder: $e');
      cancelRecording();
    }
  }

  Future<AudioInfo?> finishRecording() async {
    _cancelEverything();

    final String? path = await _recorder?.stop();
    AudioInfo? audioInfo;

    if (path != null) {
      final String ext = path.split('.').last;
      final String remoteStorageName = '${const Uuid().v4()}.$ext';

      audioInfo = AudioInfo(
        messageId: '',
        peaks: _resample(_peeks, 40).toList(),
        localFullPath: path,
        name: remoteStorageName,
        duration: Duration(seconds: _seconds),
        signedUrl: null,
      );
    }

    _peeks.clear();
    _seconds = 0;

    emit(RecordingState.idle(
      lastRecordingResult: RecordingResult.finish,
    ));

    return audioInfo;
  }

  Future<void> cancelRecording() async {
    _cancelEverything();

    await _recorder?.cancel();

    _peeks.clear();
    _seconds = 0;

    emit(RecordingState.idle(
      lastRecordingResult: RecordingResult.cancel,
    ));
  }

  void fixRecording() {
    if (state is _Recording) {
      emit((state as _Recording).copyWith(isFixed: true));
    }
  }

  void _cancelEverything() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    _timer?.cancel();
    _timer = null;
  }

  // TODO: move to an extension
  List<double> _resample(List<double> list, int newLength) {
    if (list.isEmpty) {
      return List<double>.generate(newLength, (_) => 0);
    }

    if (newLength < 0) {
      throw ArgumentError('newLength must be non-negative');
    }

    if (newLength == 0) {
      return List<double>.generate(newLength, (_) => 0);
    }

    final List<double> result = <double>[];
    final double factor = (list.length - 1) / (newLength - 1);

    for (int i = 0; i < newLength; i++) {
      final double index = i * factor;
      final int leftIndex = index.floor();
      final int rightIndex = index.ceil().clamp(0, newLength - 1);

      if (leftIndex == rightIndex) {
        result.add(list[leftIndex]);
      } else {
        final double leftValue = list[leftIndex];
        final double rightValue = list[rightIndex];
        final double interpolatedValue =
            leftValue + (rightValue - leftValue) * (index - leftIndex);
        result.add(interpolatedValue);
      }
    }

    final double max = result.max;

    if (max == 0) {
      return result;
    }

    return result.map((double e) => e / max).toList();
  }
}
