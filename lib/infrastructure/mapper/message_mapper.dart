import '../../domain/domain.dart';
import '../infrastructure.dart';
import 'link_mapper.dart';

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

    final List<FileAttachmentResponseDTO> fileDtos = dto.attachments.where(
      (FileAttachmentResponseDTO f) {
        return f.attachmentType == FileAttachmentTypeDTO.file;
      },
    ).toList();

    final List<Attachment> files =
        fileDtos.map(FileAttachmentMapper.toDomain).toList();

    if (files.isNotEmpty) {
      return FileMessage(
        isPending: false,
        id: dto.id,
        date: dto.createdAt.toLocal(),
        file: files.first,
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
      final List<Link> links = dto.links.map(LinkMapper.toDomain).toList();

      return Message.text(
        id: dto.id,
        date: dto.createdAt.toLocal(),
        text: dto.textContent,
        images: images,
        isPending: false,
        links: links,
      );
    }

    throw Exception('Unknown message type');
  }
}
