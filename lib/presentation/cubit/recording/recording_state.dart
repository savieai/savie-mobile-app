part of 'recording_cubit.dart';

enum RecordingResult {
  cancel,
  finish,
  none;
}

@unfreezed
class RecordingState with _$RecordingState {
  factory RecordingState.idle({
    required RecordingResult lastRecordingResult,
  }) = _Idle;

  factory RecordingState.recording({
    required DateTime startTime,
    required double peek,
    required int seconds,
  }) = _Recording;
}

extension RecordingStateExtension on RecordingState {
  double get peek => when(
        idle: (_) => 0,
        recording: (_, double peek, __) => peek,
      );

  int get seconds => when(
        idle: (_) => 0,
        recording: (_, __, int seconds) => seconds,
      );

  bool get isRecording => mapOrNull(recording: (_) => true) ?? false;
}
