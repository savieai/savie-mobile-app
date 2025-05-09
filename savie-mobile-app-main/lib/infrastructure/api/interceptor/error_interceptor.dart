import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/model/app_log.dart';
import '../../infrastructure.dart';

@Injectable()
class ErrorInterceptor extends QueuedInterceptorsWrapper {
  ErrorInterceptor(this._loggingService);

  final LoggingService _loggingService;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _loggingService.addLog(
      ErrorLog(
        error: err,
        message: err.message,
        stackTrace: err.stackTrace,
      ),
    );
    super.onError(err, handler);
  }
}
