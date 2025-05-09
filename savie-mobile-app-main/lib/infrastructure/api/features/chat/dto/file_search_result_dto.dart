import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_search_result_dto.freezed.dart';
part 'file_search_result_dto.g.dart';

@freezed
class FileSearchResultDTO with _$FileSearchResultDTO {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory FileSearchResultDTO({
    required String id,
    required DateTime createdAt,
    required String name,
    required String messageId,
  }) = _FileSearchResultDTO;

  const FileSearchResultDTO._();

  factory FileSearchResultDTO.fromJson(Map<String, Object?> json) =>
      _$FileSearchResultDTOFromJson(json);
}
