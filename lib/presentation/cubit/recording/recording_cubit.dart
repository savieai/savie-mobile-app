import 'dart:async';
import 'dart:io';

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

@Singleton()
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
      final Directory tempDir = await getApplicationCacheDirectory();

      await _recorder.start(
        const RecordConfig(),
        path: '${tempDir.path}/${const Uuid().v4()}.m4a',
      );

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

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (state is _Recording) {
          _seconds++;
          emit((state as _Recording).copyWith(seconds: _seconds));
        }
      });

      emit(
        RecordingState.recording(
          startTime: DateTime.now(),
          peek: 0,
          seconds: _seconds,
        ),
      );
    }
  }

  Future<AudioMessage?> finishRecording() async {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    _timer?.cancel();
    _timer = null;

    final String? path = await _recorder.stop();
    AudioMessage? audioMessage;

    if (path != null) {
      audioMessage = AudioMessage(
        peeks: _peeks.toList(),
        path: path,
        seconds: _seconds,
      );
    }

    _peeks.clear();
    _seconds = 0;

    emit(RecordingState.idle(
      lastRecordingResult: RecordingResult.finish,
    ));

    return audioMessage;
  }

  Future<void> cancelRecording() async {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;

    await _recorder.cancel();

    emit(RecordingState.idle(
      lastRecordingResult: RecordingResult.cancel,
    ));
  }
}
