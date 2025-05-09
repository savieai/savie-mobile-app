import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../infrastructure.dart';

part 'extract_tasks_response.freezed.dart';
part 'extract_tasks_response.g.dart';

@freezed
class ExtractTasksRepsponse with _$ExtractTasksRepsponse {
  const factory ExtractTasksRepsponse({
    required List<TaskDTO> tasks,
  }) = _ExtractTasksRepsponse;

  const ExtractTasksRepsponse._();

  factory ExtractTasksRepsponse.fromJson(Map<String, Object?> json) =>
      _$ExtractTasksRepsponseFromJson(json);
}
