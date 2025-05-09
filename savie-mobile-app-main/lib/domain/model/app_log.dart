import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_log.freezed.dart';

@freezed
class AppLog with _$AppLog {
  const factory AppLog.info({
    required String info,
  }) = InfoLog;

  const factory AppLog.error({
    required Object error,
    String? message,
    StackTrace? stackTrace,
  }) = ErrorLog;

  const AppLog._();
}
