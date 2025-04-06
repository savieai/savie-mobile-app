// ignore_for_file: always_specify_types

import 'package:flutter_quill/quill_delta.dart';

import '../../domain/domain.dart';
import '../infrastructure.dart';
import 'link_mapper.dart';

sealed class MessageMapper {
  static Message toDomain(MessageDTO dto) {
    if (dto.voiceMessages?.firstOrNull != null) {
      return Message.audio(
        tempId: dto.tempId,
        id: dto.id,
        date: dto.createdAt.toLocal(),
        isPending: false,
        audioInfo: AudioInfo(
          name: dto.voiceMessages!.first.name,
          signedUrl: dto.voiceMessages!.first.signedUrl,
          localFullPath: null,
          messageId: dto.voiceMessages!.first.messageId,
          duration: Duration(seconds: dto.voiceMessages!.first.duration),
          peaks: dto.voiceMessages!.first.peaks,
        ),
        transcription: dto.voiceMessages!.firstOrNull?.transcriptionText,
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
      originalTextContents: dto.deltaContent == null
          ? null
          : TextContent.fromDelta(parseDelta(dto.deltaContent!)),
      images: images,
      isPending: false,
      links: links,
      improvedTextContents: dto.enhancedDeltaContent == null
          ? null
          : TextContent.fromDelta(parseDelta(dto.enhancedDeltaContent!)),
    );
  }

  static Delta parseDelta(Map<String, dynamic> deltaContent) {
    final Delta delta = Delta.fromJson(deltaContent['ops'] as List<dynamic>);
    if (delta.isEmpty) {
      return Delta()..insert('\n');
    }

    if (!(delta.last.data! as String).endsWith('\n')) {
      delta.insert('\n');
    }

    return delta;
  }
}
