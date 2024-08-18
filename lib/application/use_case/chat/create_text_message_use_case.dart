import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/domain.dart';

@Injectable()
class CreateTextMessageUseCase {
  CreateTextMessageUseCase(
    this._chatRepository,
    this._cacheRepository,
  );

  final ChatRepository _chatRepository;
  final CacheRepository _cacheRepository;

  Future<void> execute(TextMessage message) async {
    final List<String> fileNames = await Future.wait(
      message.images.map((Attachment a) => a).nonNulls.map(
        (Attachment a) async {
          final String fileName = a.name;

          await _cacheRepository.cacheFile(
            url: File(a.localUrl!).uri.toString(),
            key: fileName,
            file: File(a.localUrl!),
          );

          await Supabase.instance.client.storage
              .from('message_attachments')
              .upload(fileName, File(a.localUrl!));

          return fileName;
        },
      ),
    );

    await _chatRepository.createTextMessage(
      text: message.text,
      images: fileNames.map(
        (String fileName) {
          return Attachment(
            name: fileName,
            remoteUrl: null,
            localUrl: null,
          );
        },
      ).toList(),
    );
  }
}
