import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_attachment_dto.freezed.dart';
part 'file_attachment_dto.g.dart';

enum FileAttachmentTypeDTO {
  image,
  file;
}

@freezed
class FileAttachmentDTO with _$FileAttachmentDTO {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory FileAttachmentDTO({
    required String name,
    required String url,
    @JsonKey(includeToJson: false)
    required FileAttachmentTypeDTO attachmentType,
  }) = _FileAttachmentDTO;

  factory FileAttachmentDTO.fromJson(Map<String, Object?> json) =>
      _$FileAttachmentDTOFromJson(json);
}
