import 'dart:io';

import '../domain.dart';

abstract interface class AiRepository {
  Future<String> transcribe({
    required File audioFile,
    required String messageId,
  });

  Future<List<TextContent>> improveText({
    required List<TextContent> textContents,
    required String messageId,
  });

  Future<List<Task>> extractTasks({
    required String plainTextContent,
    required String messageId,
  });
}
