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
    required bool isFixed,
  }) = _Recording;
}

extension RecordingStateExtension on RecordingState {
  double get peek => map(
        idle: (_) => 0,
        recording: (_) => _.peek,
      );

  int get seconds => map(
        idle: (_) => 0,
        recording: (_) => _.seconds,
      );

  bool get isRecording => mapOrNull(recording: (_) => true) ?? false;

  bool get isFixed => mapOrNull(recording: (_) => _.isFixed) ?? false;
}
