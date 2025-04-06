import 'package:flutter_quill/quill_delta.dart';

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
    required Delta? deltaContent,
    required List<Attachment> images,
  });

  Future<void> createFileMessage({
    required String tempId,
    required Attachment file,
    required String? placeholderUrl,
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

  Future<void> editMessageTextContent({
    required String messageId,
    required Delta deltaContent,
  });

  Future<void> editMessahe({
    required Message message,
  });
}
