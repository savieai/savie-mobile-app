import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain.dart';

part 'task_extraction_state.freezed.dart';

@freezed
class TaskExtractionState with _$TaskExtractionState {
  const factory TaskExtractionState({
    required List<Task> tasks,
    required bool isAddding,
    required bool isAdded,
  }) = _TaskExtractionState;

  const TaskExtractionState._();
}
