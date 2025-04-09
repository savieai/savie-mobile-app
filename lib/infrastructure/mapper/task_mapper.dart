import '../../domain/domain.dart';
import '../infrastructure.dart';

sealed class TaskMapper {
  static Task toDomain(TaskDTO dto) => Task(
        title: dto.title,
        details: dto.details,
        type: dto.type,
      );
}
