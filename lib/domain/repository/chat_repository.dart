import '../domain.dart';

abstract class ChatRepository {
  Future<List<Message>> fetchMessages();
  Future<void> createMessage({
    required String? text,
    required List<Attachment> images,
  });
}
