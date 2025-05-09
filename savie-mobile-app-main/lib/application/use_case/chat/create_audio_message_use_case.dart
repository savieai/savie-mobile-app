import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/domain.dart';

@Injectable()
class CreateAudioMessageUseCase {
  CreateAudioMessageUseCase(
    this._chatRepository,
    this._cacheRepository,
  );

  final ChatRepository _chatRepository;
  final CacheRepository _cacheRepository;

  Future<String> execute(AudioMessage message) async {
    final String? audioPath = message.audioInfo.localFullPath;
    if (audioPath == null) {
      return '';
    }

    final String audioName = message.audioInfo.name;

    await _cacheRepository.cacheFile(
      url: audioPath,
      key: message.audioInfo.name,
      file: File(audioPath),
    );

    await Supabase.instance.client.storage
        .from('voice_messages')
        .upload(audioName, File(audioPath));

    return _chatRepository.createAudioMessage(
      tempId: message.tempId!,
      audioInfo: message.audioInfo,
    );
  }
}
