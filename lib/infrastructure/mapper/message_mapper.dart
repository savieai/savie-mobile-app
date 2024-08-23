import '../../domain/domain.dart';
import '../infrastructure.dart';
import 'link_mapper.dart';

sealed class MessageMapper {
  static Message toDomain(MessageDTO dto) {
    if (dto.voiceMessage?.firstOrNull != null) {
      return Message.audio(
        tempId: dto.tempId,
        id: dto.id,
        date: dto.createdAt.toLocal(),
        isPending: false,
        audioInfo: AudioInfo(
          name: dto.voiceMessage!.first.name,
          signedUrl: dto.voiceMessage!.first.signedUrl,
          localFullPath: null,
          messageId: dto.voiceMessage!.first.messageId,
          duration: Duration(seconds: dto.voiceMessage!.first.duration),
          peaks: dto.voiceMessage!.first.peaks,
        ),
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
        tempId: dto.tempId,
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
        tempId: dto.tempId,
        date: dto.createdAt.toLocal(),
        text: dto.textContent,
        images: images,
        isPending: false,
        links: links,
      );
    }

    return Message.text(
      isPending: false,
      id: dto.id,
      tempId: dto.tempId,
      date: dto.createdAt,
      text: dto.textContent ?? '',
    );
  }
}
