import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain.dart';

part 'attachment.freezed.dart';

@freezed
class Attachment with _$Attachment {
  const factory Attachment({
    required String name,
    required String? remoteStorageName,
    required String? signedUrl,
    required String? localFullPath,
    required String? placeholderUrl,
  }) = _Attachment;

  const Attachment._();
}

extension AttachmentExtension on Attachment {
  FileType get fileType {
    final String extension = name.split('.').last.toLowerCase();
    switch (extension) {
      case 'png' || 'jpeg' || 'jpg' || 'heic':
        return FileType.image;
      case 'pdf':
        return FileType.pdf;
      default:
        return FileType.other;
    }
  }
}
