import '../domain.dart';

abstract class ChatRepository {
  Future<List<Message>> fetchMessages();
  Future<void> createTextMessage({
    required String? text,
    required List<Attachment> images,
  });
  Future<void> createFileMessage(Attachment file);
  Future<void> createAudioMessage(String voiceMessageUrl);
  // Future<List<Message>> searchMessages(String query);
}
