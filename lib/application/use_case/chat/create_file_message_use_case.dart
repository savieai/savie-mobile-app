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

  Future<void> execute(FileMessage message) async {
    final String? filePath = message.file.localUrl;

    if (filePath == null) {
      return;
    }

    final String fileName = message.file.name;

    await _cacheRepository.cacheFile(
      url: File(filePath).uri.toFilePath(),
      key: fileName,
      file: File(filePath),
    );

    await Supabase.instance.client.storage
        .from('message_attachments')
        .upload(fileName, File(filePath));

    await _chatRepository.createFileMessage(
      Attachment(
        name: fileName,
        remoteUrl: null,
        localUrl: null,
      ),
    );
  }
}
