import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../domain/domain.dart';
import '../infrastructure.dart';

@Injectable(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._chatApi);

  final ChatApi _chatApi;

  @override
  Future<List<Message>> fetchMessages({
    required int page,
    required int pageSize,
  }) async {
    final HttpResponse<GetMessagesResponse> response =
        await _chatApi.getMessages(page: page, pageSize: pageSize);

    return response.data.data.messages.map(MessageMapper.toDomain).toList();
  }

  @override
  Future<void> createAudioMessage({
    required String tempId,
    required AudioInfo audioInfo,
  }) async {
    final CreateMessageRequest request = CreateMessageRequest(
      tempId: tempId,
      fileAttachments: null,
      images: null,
      textContent: null,
      voiceMessage: VoiceMessageRequestDTO(
        url: audioInfo.name,
        name: audioInfo.name,
        duration: audioInfo.duration.inSeconds,
        peaks: audioInfo.peaks,
      ),
    );

    await _chatApi.createMessage(jsonEncode(request));
  }

  @override
  Future<void> createFileMessage({
    required String tempId,
    required Attachment file,
  }) async {
    final CreateMessageRequest request = CreateMessageRequest(
      tempId: tempId,
      fileAttachments: <FileAttachmentRequestDTO>[
        FileAttachmentMapper.toDto(file),
      ],
      images: null,
      textContent: '',
      voiceMessage: null,
    );
    await _chatApi.createMessage(jsonEncode(request));
  }

  @override
  Future<void> createTextMessage({
    required String tempId,
    required String? text,
    required List<Attachment> images,
  }) async {
    final CreateMessageRequest request = CreateMessageRequest(
      tempId: tempId,
      fileAttachments: null,
      images: images.isEmpty
          ? null
          : images.map(FileAttachmentMapper.toDto).toList(),
      textContent: text ?? '',
      voiceMessage: null,
    );
    await _chatApi.createMessage(jsonEncode(request));
  }

  @override
  Future<List<SearchResult>> searchMessages({
    required String query,
    required SearchResultType type,
  }) async {
    // TODO: dont use enum name
    final HttpResponse<void> response =
        await _chatApi.searchMessages(query, type.name);

    final List<dynamic> data =
        response.response.data as List<dynamic>? ?? <dynamic>[];

    return switch (type) {
      SearchResultType.image => data
          .map((dynamic data) =>
              ImageSearchResultDTO.fromJson(data as Map<String, dynamic>))
          .map(SearchResultMapper.imageToDomain)
          .toList(),
      SearchResultType.file => data
          .map((dynamic data) =>
              FileSearchResultDTO.fromJson(data as Map<String, dynamic>))
          .map(SearchResultMapper.fileToDomain)
          .toList(),
      SearchResultType.link => data
          .map((dynamic data) =>
              LinkSearchResultDTO.fromJson(data as Map<String, dynamic>))
          .map(SearchResultMapper.linkToDomain)
          .toList(),
    };
  }

  @override
  Future<void> removeMessage({
    required String messageId,
  }) =>
      _chatApi.deleteMessage(messageId);
}
