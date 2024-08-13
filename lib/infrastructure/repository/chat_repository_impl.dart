import 'dart:convert';

import 'package:flutter/services.dart';
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

    Clipboard.setData(ClipboardData(text: jsonEncode(response.response.data)));

    return response.data.map(MessageMapper.toDomain).toList();
  }

  @override
  Future<void> createMessage({
    required String? text,
    required List<Attachment> images,
    required String? voiceMessageUrl,
  }) async {
    final CreateMessageRequest request = CreateMessageRequest(
      fileAttachments: null,
      images: images.isEmpty
          ? null
          : images.map(FileAttachmentMapper.toDto).toList(),
      textContent: text ?? '',
      voiceMessageUrl: voiceMessageUrl,
    );
    await _chatApi.createMessage(jsonEncode(request));
  }
}
