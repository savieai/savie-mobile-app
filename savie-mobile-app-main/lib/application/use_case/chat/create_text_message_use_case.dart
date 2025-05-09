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

  Future<String> execute(TextMessage message) async {
    final Directory tempDir = await getTemporaryDirectory();

    final List<(String, String)> fileNames = await Future.wait(
      message.images.map((Attachment a) => a).nonNulls.map(
        (Attachment a) async {
          final String fileName = a.name;
          final File originalFile = File(a.localFullPath!);
          
          // Instead of always resizing, maintain original quality for most images
          // Only resize if the image is extremely large (over 5000px)
          Uint8List imageBytes;
          final String extension = fileName.split('.').last.toLowerCase();
          
          if (extension == 'png' || extension == 'gif') {
            // For PNG or GIF formats, just use the original file
            imageBytes = await originalFile.readAsBytes();
          } else {
            // For JPEG and other formats, use our processor but with high quality
            imageBytes = await _resizeImageUseCase.execute(
              a.localFullPath!,
              5000, // Much higher threshold, effectively keeping most images original size
            );
          }

          // Get the processed bytes and save them to a temporary file
          final String tempPath = '${tempDir.path}/processed_$fileName';
          final File processedFile = File(tempPath)
            ..writeAsBytesSync(imageBytes);

          // Cache and upload the image
          await _cacheRepository.cacheFile(
            url: Supabase.instance.client.storage
                .from('message_attachments')
                .getAuthenticatedUrl(fileName),
            key: fileName,
            file: processedFile,
          );

          // Use multipart form uploads for larger files to prevent timeout issues
          await Supabase.instance.client.storage
              .from('message_attachments')
              .upload(
                fileName, 
                processedFile,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                ),
              );

          final String signedUrl = await Supabase.instance.client.storage
              .from('message_attachments')
              .createSignedUrl(fileName, 7200); // Increase signed URL expiration

          return (fileName, signedUrl);
        },
      ),
    );

    return _chatRepository.createTextMessage(
      tempId: message.tempId!,
      deltaContent: message.originalDeltaContent,
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
