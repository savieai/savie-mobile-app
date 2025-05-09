import 'package:freezed_annotation/freezed_annotation.dart';

part 'link_search_result_dto.freezed.dart';
part 'link_search_result_dto.g.dart';

@freezed
class LinkSearchResultDTO with _$LinkSearchResultDTO {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory LinkSearchResultDTO({
    required String id,
    required DateTime createdAt,
    required String url,
    required String messageId,
  }) = _LinkSearchResultDTO;

  const LinkSearchResultDTO._();

  factory LinkSearchResultDTO.fromJson(Map<String, Object?> json) =>
      _$LinkSearchResultDTOFromJson(json);
}
