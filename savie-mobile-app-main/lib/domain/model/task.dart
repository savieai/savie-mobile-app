import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String title,
    required String type,
    required String details,
  }) = _Task;

  const Task._();
}
