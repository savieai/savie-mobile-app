import 'dart:io';

abstract interface class AiRepository {
  Future<String> transcribe(File audioFile);

  Future<String> improveText(String text);
}
