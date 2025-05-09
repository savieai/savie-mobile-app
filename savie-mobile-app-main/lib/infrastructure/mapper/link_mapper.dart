import '../../domain/domain.dart';
import '../infrastructure.dart';

sealed class LinkMapper {
  static Link toDomain(LinkDTO dto) => Link(
        url: dto.url,
      );
}
