import '../../domain/domain.dart';
import '../infrastructure.dart';

sealed class MessageMapper {
  static Message toDomain(MessageDTO dto) {
    if (dto.voiceMessageUrlSigned.isNotEmpty &&
        dto.voiceMessageUrl.isNotEmpty) {
      return Message.audio(
        id: dto.id,
        date: dto.createdAt.toLocal(),
        remoteUrl: dto.voiceMessageUrlSigned,
        localUrl: null,
        isPending: false,
        name: dto.voiceMessageUrl,
      );
    }

    if (dto.textContent != null) {
      final List<FileAttachmentResponseDTO> imageDtos = dto.attachments.where(
        (FileAttachmentResponseDTO f) {
          return f.attachmentType == FileAttachmentTypeDTO.image;
        },
      ).toList();

      final List<Attachment> images =
          imageDtos.map(FileAttachmentMapper.toDomain).toList();

      return Message.text(
        id: dto.id,
        date: dto.createdAt.toLocal(),
        text: dto.textContent,
        images: images,
        isPending: false,
      );
    }

    throw Exception('Unknown message type');
  }
}
