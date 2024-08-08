import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/domain.dart';

@Injectable()
class CreateMessageUseCase {
  CreateMessageUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> execute({
    required List<String> imagePaths,
    required String text,
  }) async {
    final List<String> fileNames = await Future.wait(
      imagePaths.map(
        (String localPath) async {
          final String extension = localPath.split('.').last;
          final String fileName = '${const Uuid().v4()}.$extension';
          await Supabase.instance.client.storage
              .from('message_attachments')
              .upload(fileName, File(localPath));

          return fileName;
        },
      ),
    );

    await _chatRepository.createMessage(
      text: text,
      images: fileNames.map(
        (String fileName) {
          return Attachment(name: fileName, url: fileName);
        },
      ).toList(),
    );
  }
}
