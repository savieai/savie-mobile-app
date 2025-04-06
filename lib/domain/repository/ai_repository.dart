import 'dart:io';

abstract interface class AiRepository {
  Future<String> transcribe({
    required File audioFile,
    required String messageId,
  });

  Future<String> improveText(String text);
}
