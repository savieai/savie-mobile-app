// ignore_for_file: unused_field

import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

part 'player_state.dart';
part 'player_cubit.freezed.dart';

@Injectable()
class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit() : super(PlayerState(audio: null)) {
    _nativeStateSubscription = _player.onPlayerStateChanged.listen(
      (audio.PlayerState nativeState) {
        _nativeState = nativeState;
        emit(state.copyWith(
          audio: state.audio?.copyWith(
            isPlaying: nativeState == audio.PlayerState.playing,
          ),
        ));
      },
    );

    _positionSubscription = _player.onPositionChanged.listen(
      (Duration duration) {
        _position = duration;
        emit(state.copyWith(
          audio: state.audio?.copyWith(
            duration: duration,
          ),
        ));
      },
    );
  }

  final audio.AudioPlayer _player = audio.AudioPlayer();
  audio.PlayerState _nativeState = audio.PlayerState.stopped;
  Duration _position = Duration.zero;
  late final StreamSubscription<audio.PlayerState> _nativeStateSubscription;
  late final StreamSubscription<Duration> _positionSubscription;

  Future<void> toggleAudio(AudioMessage audioMessage) async {
    // TODO: toggle audio
    // if (audioMessage.path != state.audio?.audioPath) {
    //   await _player.stop();
    //   _player.play(DeviceFileSource(audioMessage.path));
    // } else {
    //   switch (_nativeState) {
    //     case audio.PlayerState.stopped:
    //       _player.play(DeviceFileSource(audioMessage.path));
    //     case audio.PlayerState.completed:
    //     case audio.PlayerState.paused:
    //       _player.resume();
    //     case audio.PlayerState.playing:
    //       _player.pause();
    //     case audio.PlayerState.disposed:
    //       break;
    //   }
    // }

    // emit(
    //   state.copyWith(
    //     audio: PlayingAudio(
    //       audioPath: audioMessage.path,
    //       duration: _position,
    //       isPlaying: _nativeState == audio.PlayerState.playing,
    //     ),
    //   ),
    // );
  }

  @override
  Future<void> close() {
    _nativeStateSubscription.cancel();
    _positionSubscription.cancel();
    return super.close();
  }
}
