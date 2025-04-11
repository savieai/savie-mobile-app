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

  Future<String> createTextMessage({
    required String tempId,
    required Delta? deltaContent,
    required List<Attachment> images,
  });

  Future<String> createFileMessage({
    required String tempId,
    required Attachment file,
    required String? placeholderUrl,
  });

  Future<String> createAudioMessage({
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
    required TextEditingTarget target,
  });

  Future<void> undoTextImprovement({
    required String messageId,
  });

  Future<void> editMessage({
    required Message message,
  });
}
