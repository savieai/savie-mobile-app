import '../../../domain/domain.dart';
import '../api/chat/dto/file_attachment_dto.dart';

sealed class FileAttachmentMapper {
  static Attachment toDomain(FileAttachmentDTO dto) {
    return Attachment(name: dto.name, url: dto.url);
  }

  static FileAttachmentDTO toDto(
    Attachment attachment, {
    required FileAttachmentTypeDTO type,
  }) {
    return FileAttachmentDTO(
      name: attachment.name,
      url: attachment.url,
      attachmentType: type,
    );
  }
}
