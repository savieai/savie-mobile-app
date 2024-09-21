import '../../domain/domain.dart';
import '../infrastructure.dart';

sealed class PaginationMapper {
  static Pagination toDomain(PaginationDTO dto) {
    return Pagination(
      currentPage: dto.currentPage,
      pageSize: dto.pageSize,
      totalPages: dto.totalPages,
    );
  }
}
