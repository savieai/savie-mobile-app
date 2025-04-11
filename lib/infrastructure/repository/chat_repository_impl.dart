import 'dart:convert';

import 'package:flutter_quill/quill_delta.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../domain/domain.dart';
import '../infrastructure.dart';

@Injectable(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._chatApi);

  final ChatApi _chatApi;

  @override
  Future<(Pagination, List<Message>)> fetchMessagesByPage({
    required int page,
    required int pageSize,
  }) async {
    final HttpResponse<GetMessagesResponse> response =
        await _chatApi.getMessagesByPage(
      page: page,
      pageSize: pageSize,
    );

    return (
      PaginationMapper.toDomain(response.data.data.pagination),
      response.data.data.messages.map(MessageMapper.toDomain).toList()
    );
  }

  @override
  Future<(Pagination, List<Message>)> fetchMessagesByMessageId({
    required String messageId,
    required int pageSize,
  }) async {
    final HttpResponse<GetMessagesResponse> response =
        await _chatApi.getMessagesByMessageId(
      messageId: messageId,
      pageSize: pageSize,
    );

    return (
      PaginationMapper.toDomain(response.data.data.pagination),
      response.data.data.messages.map(MessageMapper.toDomain).toList()
    );
  }

  @override
  Future<String> createAudioMessage({
    required String tempId,
    required AudioInfo audioInfo,
  }) async {
    final CreateMessageRequest request = CreateMessageRequest(
      tempId: tempId,
      fileAttachments: null,
      images: null,
      deltaContent: null,
      voiceMessage: VoiceMessageRequestDTO(
        url: audioInfo.name,
        name: audioInfo.name,
        duration: audioInfo.duration.inSeconds,
        peaks: audioInfo.peaks.toString(),
      ),
      placeholderUrl: null,
    );

    final HttpResponse<void> response =
        await _chatApi.createMessage(jsonEncode(request));

    return (response.response.data as Map<String, dynamic>)['id'] as String;
  }

  @override
  Future<String> createFileMessage({
    required String tempId,
    required Attachment file,
    required String? placeholderUrl,
  }) async {
    final CreateMessageRequest request = CreateMessageRequest(
      tempId: tempId,
      fileAttachments: <FileAttachmentRequestDTO>[
        FileAttachmentMapper.toDto(file),
      ],
      images: null,
      deltaContent: <String, dynamic>{
        'ops': <Map<String, String>>[
          <String, String>{'insert': ''},
        ],
      },
      voiceMessage: null,
      placeholderUrl: placeholderUrl,
    );

    final HttpResponse<void> response =
        await _chatApi.createMessage(jsonEncode(request));

    return (response.response.data as Map<String, dynamic>)['id'] as String;
  }

  @override
  Future<String> createTextMessage({
    required String tempId,
    required Delta? deltaContent,
    required List<Attachment> images,
  }) async {
    final CreateMessageRequest request = CreateMessageRequest(
      tempId: tempId,
      fileAttachments: null,
      images: images.isEmpty
          ? null
          : images.map(FileAttachmentMapper.toDto).toList(),
      deltaContent: deltaContent == null
          ? null
          : <String, dynamic>{
              'ops': deltaContent.toJson(),
            },
      voiceMessage: null,
      placeholderUrl: null,
    );

    final HttpResponse<void> response =
        await _chatApi.createMessage(jsonEncode(request));

    return (response.response.data as Map<String, dynamic>)['id'] as String;
  }

  @override
  Future<List<SearchResult>> searchMessages({
    required String query,
    required SearchResultType type,
  }) async {
    final HttpResponse<GetMessagesResponse> response = await _chatApi
        .searchMessages(query: query, type: type.name, page: 1, pageSize: 100);

    final List<Message> messages =
        response.data.data.messages.map(MessageMapper.toDomain).toList();

    switch (type) {
      case SearchResultType.image:
        final List<(Attachment, Message)> images = messages
            .where((Message m) => m is TextMessage && m.images.isNotEmpty)
            .expand((Message m) =>
                (m as TextMessage).images.map((Attachment a) => (a, m)))
            .toList();

        return images
            .map(((Attachment, Message) image) => SearchResult.image(
                  messageId: image.$2.id,
                  date: image.$2.date,
                  image: image.$1,
                ))
            .toList();

      case SearchResultType.file:
        final List<FileMessage> fileMessages =
            messages.whereType<FileMessage>().toList();

        return fileMessages
            .map((FileMessage fileMessage) => SearchResult.file(
                  messageId: fileMessage.id,
                  date: fileMessage.date,
                  file: fileMessage.file,
                ))
            .toList();

      case SearchResultType.link:
        final List<(Link, Message)> links = messages
            .where((Message m) => m is TextMessage && m.links.isNotEmpty)
            .expand(
                (Message m) => (m as TextMessage).links.map((Link l) => (l, m)))
            .toList();

        return links
            .map(((Link, Message) link) => SearchResult.link(
                  messageId: link.$2.id,
                  date: link.$2.date,
                  url: link.$1.url,
                ))
            .toList();

      case SearchResultType.voice:
        final List<AudioMessage> audioMessages =
            messages.whereType<AudioMessage>().toList();

        return audioMessages
            .map((AudioMessage audioMessage) => SearchResult.audio(
                  messageId: audioMessage.id,
                  date: audioMessage.date,
                  audioMessage: audioMessage,
                ))
            .toList();
    }
  }

  @override
  Future<void> removeMessage({
    required String messageId,
  }) =>
      _chatApi.deleteMessage(messageId);

  @override
  Future<(Pagination, List<Message>)> searchInMessages({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    final HttpResponse<GetMessagesResponse> response =
        await _chatApi.searchMessages(
      query: query,
      type: null,
      page: page,
      pageSize: pageSize,
    );

    return (
      PaginationMapper.toDomain(response.data.data.pagination),
      response.data.data.messages.map(MessageMapper.toDomain).toList()
    );
  }

  @override
  Future<void> editMessageTextContent({
    required String messageId,
    required Delta deltaContent,
    required TextEditingTarget target,
  }) {
    return _chatApi.updateMessage(
      messageId,
      <String, dynamic>{
        'ops': deltaContent.toJson(),
      },
      switch (target) {
        TextEditingTarget.enhanced => 'enhanced',
        TextEditingTarget.original => 'original',
      },
    );
  }

  @override
  Future<void> editMessage({required Message message}) {
    // TODO: implement editMessahe
    throw UnimplementedError();
  }

  @override
  Future<void> undoTextImprovement({
    required String messageId,
  }) =>
      _chatApi.undoTextImprovement(messageId);
}
