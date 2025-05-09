import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination.freezed.dart';

@freezed
class Pagination with _$Pagination {
  const factory Pagination({
    required int currentPage,
    required int pageSize,
    required int totalPages,
  }) = _Pagination;

  const Pagination._();
}
