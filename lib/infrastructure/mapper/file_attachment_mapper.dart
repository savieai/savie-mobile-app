import '../../domain/domain.dart';
import '../infrastructure.dart';

sealed class FileAttachmentMapper {
  static Attachment toDomain(FileAttachmentResponseDTO dto) {
    return Attachment(
      name: dto.name,
      remoteStorageName: null,
      signedUrl: dto.signedUrl,
      localFullPath: null,
      placeholderUrl: dto.placeholderUrl,
    );
  }

  static FileAttachmentRequestDTO toDto(Attachment attachment) {
    return FileAttachmentRequestDTO(
      name: attachment.name,
      url: attachment.remoteStorageName!,
      placeholderUrl: attachment.placeholderUrl,
    );
  }
}
