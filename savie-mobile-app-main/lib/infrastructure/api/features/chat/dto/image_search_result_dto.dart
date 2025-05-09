import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_search_result_dto.freezed.dart';
part 'image_search_result_dto.g.dart';

@freezed
class ImageSearchResultDTO with _$ImageSearchResultDTO {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory ImageSearchResultDTO({
    required String id,
    required DateTime createdAt,
    required String name,
    required String messageId,
  }) = _ImageSearchResultDTO;

  const ImageSearchResultDTO._();

  factory ImageSearchResultDTO.fromJson(Map<String, Object?> json) =>
      _$ImageSearchResultDTOFromJson(json);
}
