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

import '../../../domain/domain.dart';

part 'recording_state.dart';
part 'recording_cubit.freezed.dart';

@Injectable()
class RecordingCubit extends Cubit<RecordingState> {
  RecordingCubit()
      : super(RecordingState.idle(
          lastRecordingResult: RecordingResult.none,
        ));

  final AudioRecorder _recorder = AudioRecorder();

  StreamSubscription<Amplitude>? _amplitudeSubscription;
  Timer? _timer;
  final List<double> _peeks = <double>[];
  int _seconds = 0;

  Future<void> startRecording() async {
    final bool hasPemrission = await Permission.microphone.isGranted;

    if (!hasPemrission) {
      await Permission.microphone.request();
    } else {
      emit(
        RecordingState.recording(
          startTime: DateTime.now(),
          peek: 0,
          seconds: _seconds,
          isFixed: false,
        ),
      );

      final Directory tempDir = await getApplicationCacheDirectory();
      int counter = 0;

      _amplitudeSubscription = _recorder
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

      await _recorder.start(
        const RecordConfig(),
        path: '${tempDir.path}/${const Uuid().v4()}.m4a',
      );
    }
  }

  Future<AudioInfo?> finishRecording() async {
    _cancelEverything();

    final String? path = await _recorder.stop();
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

    await _recorder.cancel();

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
