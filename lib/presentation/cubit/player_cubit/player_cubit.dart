// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../../application/use_case/metrcis/metrics.dart';
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

  Future<void> toggleAudio(AudioMessage audioMessage) async {
    //  TODO: track user activity

    if (audioMessage.name != state.audio?.audioPath) {
      await _player.stop();
      // TODO: create aduio repo
      await _playAudio(audioMessage);
    } else {
      switch (_nativeState) {
        case audio.PlayerState.stopped:
          _playAudio(audioMessage);
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
          audioPath: audioMessage.name,
          duration: _position,
          isPlaying: _nativeState == audio.PlayerState.playing,
        ),
      ),
    );
  }

  Future<void> _playAudio(AudioMessage audioMessage) async {
    final Directory cacheDir = await getApplicationCacheDirectory();
    final String fileName = '${cacheDir.path}/${audioMessage.name}';

    if (!File(fileName).existsSync()) {
      if (audioMessage.localUrl != null) {
        await _player.setSourceDeviceFile(audioMessage.localUrl!);
      } else if (audioMessage.remoteUrl != null) {
        final Response<List<int>> audioBytes = await Dio().get(
          audioMessage.remoteUrl!,
          options: Options(
            responseType: ResponseType.bytes,
          ),
        );
        File(fileName).writeAsBytesSync(audioBytes.data!);
        await _player.setSourceDeviceFile(fileName);
      }
    } else {
      await _player.setSourceDeviceFile(fileName);
    }

    _player.resume();
  }

  @override
  Future<void> close() {
    _nativeStateSubscription.cancel();
    _positionSubscription.cancel();
    return super.close();
  }
}
