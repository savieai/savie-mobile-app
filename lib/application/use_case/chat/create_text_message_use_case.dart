import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/domain.dart';
import '../../application.dart';
import 'resize_image_use_case.dart';

@Injectable()
class CreateTextMessageUseCase {
  CreateTextMessageUseCase(
    this._chatRepository,
    this._cacheRepository,
    this._resizeImageUseCase,
  );

  final ChatRepository _chatRepository;
  final CacheRepository _cacheRepository;
  final ResizeImageUseCase _resizeImageUseCase;

  Future<void> execute(TextMessage message) async {
    final Directory tempDir = await getTemporaryDirectory();

    final List<(String, String)> fileNames = await Future.wait(
      message.images.map((Attachment a) => a).nonNulls.map(
        (Attachment a) async {
          final String fileName = a.name;

          final Uint8List resizedImageBytes = await _resizeImageUseCase.execute(
            a.localFullPath!,
            1080,
          );

          // Get the compressed bytes and save them to a temporary file
          final String tempPath = '${tempDir.path}/compressed_$fileName';
          final File compressedFile = File(tempPath)
            ..writeAsBytesSync(resizedImageBytes);

          // Cache and upload the compressed image
          await _cacheRepository.cacheFile(
            url: Supabase.instance.client.storage
                .from('message_attachments')
                .getAuthenticatedUrl(fileName),
            key: fileName,
            file: compressedFile,
          );

          await Supabase.instance.client.storage
              .from('message_attachments')
              .upload(fileName, compressedFile);

          final String signedUrl = await Supabase.instance.client.storage
              .from('message_attachments')
              .createSignedUrl(fileName, 3600);

          return (fileName, signedUrl);
        },
      ),
    );

    await _chatRepository.createTextMessage(
      tempId: message.tempId!,
      text: message.text,
      images: fileNames.map(
        ((String, String) fileName) {
          return Attachment(
            name: fileName.$1,
            remoteStorageName: fileName.$1,
            signedUrl: fileName.$2,
            localFullPath: null,
            placeholderUrl: null,
          );
        },
      ).toList(),
    );
  }
}
