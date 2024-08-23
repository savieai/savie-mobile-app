part of 'player_cubit.dart';

@freezed
class PlayerState with _$PlayerState {
  factory PlayerState({
    required PlayingAudio? audio,
  }) = _PlayerState;
}

@freezed
class PlayingAudio with _$PlayingAudio {
  factory PlayingAudio({
    required AudioInfo audioInfo,
    required Duration duration,
    required bool isPlaying,
  }) = _PlayingAudio;
}
