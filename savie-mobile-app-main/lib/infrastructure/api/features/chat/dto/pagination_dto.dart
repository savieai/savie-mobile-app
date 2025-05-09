import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_dto.freezed.dart';
part 'pagination_dto.g.dart';

@freezed
class PaginationDTO with _$PaginationDTO {
  @JsonSerializable(
    fieldRename: FieldRename.snake,
    explicitToJson: true,
  )
  const factory PaginationDTO({
    required int currentPage,
    required int pageSize,
    required int totalPages,
  }) = _PaginationDTO;

  const PaginationDTO._();

  factory PaginationDTO.fromJson(Map<String, Object?> json) =>
      _$PaginationDTOFromJson(json);
}
