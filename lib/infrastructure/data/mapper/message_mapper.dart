import '../../../domain/domain.dart';
import '../api/chat/dto/file_attachment_dto.dart';
import '../api/chat/dto/message_dto.dart';
import 'file_attachment_mapper.dart';

sealed class MessageMapper {
  static Message toDomain(MessageDTO dto) {
    if (dto.voiceMessageUrl != null) {
      return Message.audio(
        id: dto.id,
        date: dto.createdAt,
        url: dto.voiceMessageUrl!,
      );
    }

    if (dto.textContent != null) {
      final List<FileAttachmentDTO> imageDtos = dto.attachments.where(
        (FileAttachmentDTO f) {
          return f.attachmentType == FileAttachmentTypeDTO.image;
        },
      ).toList();

      final List<Attachment> images =
          imageDtos.map(FileAttachmentMapper.toDomain).toList();

      return Message.text(
        id: dto.id,
        date: dto.createdAt,
        text: dto.textContent,
        images: images,
      );
    }

    throw Exception('Unknown message type');
  }
}
