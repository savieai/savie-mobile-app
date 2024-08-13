import '../../domain/domain.dart';
import '../infrastructure.dart';

sealed class FileAttachmentMapper {
  static Attachment toDomain(FileAttachmentResponseDTO dto) {
    return Attachment(name: dto.name, url: dto.signedUrl);
  }

  static FileAttachmentRequestDTO toDto(Attachment attachment) {
    return FileAttachmentRequestDTO(
      name: attachment.name,
      url: attachment.url,
    );
  }
}
