import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';
import '../api/chat/chat_api.dart';
import '../api/chat/dto/file_attachment_dto.dart';
import '../api/chat/request/create_message_request.dart';
import '../api/chat/response/get_messages_response.dart';
import '../api/mapper/file_attachment_mapper.dart';
import '../api/mapper/message_mapper.dart';

@Injectable(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._chatApi);

  final ChatApi _chatApi;

  @override
  Future<List<Message>> fetchMessages() async {
    final Response<dynamic> rawResponse = await _chatApi.getMessages();
    final GetMessagesResponse response =
        GetMessagesResponse.fromJson(rawResponse.data as List<dynamic>);

    return response.messages.map(MessageMapper.toDomain).toList();
  }

  @override
  Future<void> createMessage({
    required String? text,
    required List<Attachment> images,
  }) async {
    try {
      await _chatApi.createMessage(
        CreateMessageRequest(
          fileAttachments: <FileAttachmentDTO>[],
          images: images
              .map((Attachment a) => FileAttachmentMapper.toDto(
                    a,
                    type: FileAttachmentTypeDTO.image,
                  ))
              .toList(),
          textContent: text ?? '',
          voiceMessageUrl: null,
        ),
      );
    } on DioException catch (e) {
      print(e.response?.data);
    }
  }
}
