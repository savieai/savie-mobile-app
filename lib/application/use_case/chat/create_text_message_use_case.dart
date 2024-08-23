import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/domain.dart';
import '../../application.dart';

@Injectable()
class CreateTextMessageUseCase {
  CreateTextMessageUseCase(
    this._chatRepository,
    this._cacheRepository,
  );

  final ChatRepository _chatRepository;
  final CacheRepository _cacheRepository;

  Future<void> execute(TextMessage message) async {
    final List<(String, String)> fileNames = await Future.wait(
      message.images.map((Attachment a) => a).nonNulls.map(
        (Attachment a) async {
          final String fileName = a.name;

          // Use compute to process the image in a background thread
          final Map<String, dynamic> result = await compute(
            processImage,
            <String, String>{
              'imagePath': a.localFullPath!,
              'fileName': fileName,
            },
          );

          // Get the compressed bytes and save them to a temporary file
          final String tempPath =
              '${File(a.localFullPath!).parent.path}/compressed_${result['fileName']}';
          final File compressedFile = File(tempPath)
            ..writeAsBytesSync(result['compressedBytes']! as Uint8List);

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
          );
        },
      ).toList(),
    );
  }
}

Future<Map<String, dynamic>> processImage(Map<String, String> params) async {
  final String imagePath = params['imagePath']!;
  final String fileName = params['fileName']!;

  // Load the image from the file
  final File originalFile = File(imagePath);

  final img.Image? image = img.decodeImage(originalFile.readAsBytesSync());

  if (image != null) {
    // Resize the image if its width is greater than 1080px
    final img.Image resizedImage = img.copyResize(
      image,
      width: image.width > 1080 ? 1080 : image.width,
    );

    // Compress the resized image to reduce file size
    final Uint8List compressedBytes = Uint8List.fromList(
      img.encodeJpg(resizedImage, quality: 85), // Adjust quality as needed
    );

    return <String, dynamic>{
      'fileName': fileName,
      'compressedBytes': compressedBytes,
    };
  } else {
    throw Exception('Failed to load image: $imagePath');
  }
}
