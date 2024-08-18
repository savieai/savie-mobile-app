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
  Future<List<Message>> fetchMessages() async {
    final HttpResponse<GetMessagesResponse> response =
        await _chatApi.getMessages();

    return response.data.map(MessageMapper.toDomain).toList();
  }

  @override
  Future<void> createAudioMessage(String voiceMessageUrl) async {
    final CreateMessageRequest request = CreateMessageRequest(
      fileAttachments: null,
      images: null,
      textContent: null,
      voiceMessageUrl: voiceMessageUrl,
    );

    await _chatApi.createMessage(jsonEncode(request));
  }

  @override
  Future<void> createFileMessage(Attachment file) async {
    final CreateMessageRequest request = CreateMessageRequest(
      fileAttachments: <FileAttachmentRequestDTO>[
        FileAttachmentMapper.toDto(file),
      ],
      images: null,
      textContent: '',
      voiceMessageUrl: null,
    );
    await _chatApi.createMessage(jsonEncode(request));
  }

  @override
  Future<void> createTextMessage({
    required String? text,
    required List<Attachment> images,
  }) async {
    final CreateMessageRequest request = CreateMessageRequest(
      fileAttachments: null,
      images: images.isEmpty
          ? null
          : images.map(FileAttachmentMapper.toDto).toList(),
      textContent: text ?? '',
      voiceMessageUrl: null,
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
}
