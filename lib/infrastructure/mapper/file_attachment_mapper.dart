import '../../domain/domain.dart';
import '../infrastructure.dart';

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
