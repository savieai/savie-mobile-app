import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/domain.dart';

@Injectable()
class CreateFileMessageUseCase {
  CreateFileMessageUseCase(
    this._chatRepository,
    this._cacheRepository,
  );

  final ChatRepository _chatRepository;
  final CacheRepository _cacheRepository;

  Future<String> execute(FileMessage message) async {
    final String? filePath = message.file.localFullPath;

    if (filePath == null) {
      return '';
    }

    final String fileName = message.file.remoteStorageName!;

    await _cacheRepository.cacheFile(
      url: filePath,
      key: message.file.remoteStorageName!,
      file: File(filePath),
    );

    await Supabase.instance.client.storage
        .from('message_attachments')
        .upload(fileName, File(filePath));

    return _chatRepository.createFileMessage(
      tempId: message.tempId!,
      file: message.file,
      placeholderUrl: message.file.placeholderUrl,
    );
  }
}
