import 'package:freezed_annotation/freezed_annotation.dart';

part 'link_dto.freezed.dart';
part 'link_dto.g.dart';

@freezed
class LinkDTO with _$LinkDTO {
  @JsonSerializable(
    fieldRename: FieldRename.snake,
    explicitToJson: true,
  )
  const factory LinkDTO({
    required String url,
  }) = _LinkDTO;

  const LinkDTO._();

  factory LinkDTO.fromJson(Map<String, Object?> json) =>
      _$LinkDTOFromJson(json);
}
