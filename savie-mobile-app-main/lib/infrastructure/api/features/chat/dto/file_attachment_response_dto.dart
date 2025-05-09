import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_attachment_response_dto.freezed.dart';
part 'file_attachment_response_dto.g.dart';

enum FileAttachmentTypeDTO {
  image,
  file;
}

@freezed
class FileAttachmentResponseDTO with _$FileAttachmentResponseDTO {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory FileAttachmentResponseDTO({
    required String name,
    @Default('') String signedUrl,
    String? placeholderUrl,
    required FileAttachmentTypeDTO attachmentType,
  }) = _FileAttachmentResponseDTO;

  const FileAttachmentResponseDTO._();

  factory FileAttachmentResponseDTO.fromJson(Map<String, Object?> json) =>
      _$FileAttachmentResponseDTOFromJson(json);
}
