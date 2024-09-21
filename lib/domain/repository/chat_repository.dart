import '../domain.dart';

abstract class ChatRepository {
  Future<(Pagination, List<Message>)> fetchMessagesByPage({
    required int page,
    required int pageSize,
  });

  Future<(Pagination, List<Message>)> fetchMessagesByMessageId({
    required String messageId,
    required int pageSize,
  });

  Future<void> createTextMessage({
    required String tempId,
    required String? text,
    required List<Attachment> images,
  });

  Future<void> createFileMessage({
    required String tempId,
    required Attachment file,
  });

  Future<void> createAudioMessage({
    required String tempId,
    required AudioInfo audioInfo,
  });

  Future<List<SearchResult>> searchMessages({
    required String query,
    required SearchResultType type,
  });

  Future<(Pagination, List<Message>)> searchInMessages({
    required String query,
    required int page,
    required int pageSize,
  });

  Future<void> removeMessage({
    required String messageId,
  });

  Future<void> editMessage({
    required String messageId,
    required String textContent,
  });
}
