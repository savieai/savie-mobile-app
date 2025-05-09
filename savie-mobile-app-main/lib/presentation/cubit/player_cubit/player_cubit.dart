// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../application/application.dart';
import '../../../domain/domain.dart';

part 'player_state.dart';
part 'player_cubit.freezed.dart';

@Injectable()
class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit(
    this._trackUseActivityUseCase,
  ) : super(PlayerState(audio: null)) {
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
  final TrackUseActivityUseCase _trackUseActivityUseCase;

  Future<void> toggleAudio(AudioInfo audioInfo) async {
    //  TODO: track user activity

    if (audioInfo.messageId != state.audio?.audioInfo.messageId) {
      await _player.stop();
      // TODO: create aduio repo
      await _playAudio(audioInfo);
    } else {
      switch (_nativeState) {
        case audio.PlayerState.stopped:
          _playAudio(audioInfo);
        case audio.PlayerState.completed:
        case audio.PlayerState.paused:
          _player.resume();
        case audio.PlayerState.playing:
          _player.pause();
        case audio.PlayerState.disposed:
          break;
      }
    }

    emit(
      state.copyWith(
        audio: PlayingAudio(
          audioInfo: audioInfo,
          duration: _position,
          isPlaying: _nativeState == audio.PlayerState.playing,
        ),
      ),
    );
  }

  String? _lastDownloadingAudioId;
  Future<void> _playAudio(AudioInfo audioMessage) async {
    _lastDownloadingAudioId = audioMessage.messageId;
    final File file = await getIt.get<GetFileUseCase>().execute(
          signedUrl: audioMessage.signedUrl,
          localFullPath: audioMessage.localFullPath,
          name: audioMessage.name,
        );

    if (_lastDownloadingAudioId == audioMessage.messageId) {
      await _player.setSourceDeviceFile(file.path);
      _player.resume();
    }
  }

  @override
  Future<void> close() {
    _nativeStateSubscription.cancel();
    _positionSubscription.cancel();
    return super.close();
  }
}
