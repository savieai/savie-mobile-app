import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_attachment_request_dto.freezed.dart';
part 'file_attachment_request_dto.g.dart';

@freezed
class FileAttachmentRequestDTO with _$FileAttachmentRequestDTO {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory FileAttachmentRequestDTO({
    required String name,
    required String url,
    required String? placeholderUrl,
  }) = _FileAttachmentRequestDTO;

  const FileAttachmentRequestDTO._();

  factory FileAttachmentRequestDTO.fromJson(Map<String, Object?> json) =>
      _$FileAttachmentRequestDTOFromJson(json);
}
