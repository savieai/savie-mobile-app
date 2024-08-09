import 'package:dio/dio.dart';
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
    try {
      final HttpResponse<GetMessagesResponse> response =
          await _chatApi.getMessages();

      return response.data.map(MessageMapper.toDomain).toList();
    } on DioException catch (e) {
      print(e.response?.data);

      rethrow;
    }
  }

  @override
  Future<void> createMessage({
    required String? text,
    required List<Attachment> images,
  }) async {
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
  }
}
