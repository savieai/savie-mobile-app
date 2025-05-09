import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_dto.freezed.dart';
part 'task_dto.g.dart';

@freezed
class TaskDTO with _$TaskDTO {
  const factory TaskDTO({
    required String title,
    required String type,
    required String details,
  }) = _TaskDTO;

  const TaskDTO._();

  factory TaskDTO.fromJson(Map<String, Object?> json) =>
      _$TaskDTOFromJson(json);
}
