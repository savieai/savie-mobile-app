import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/subjects.dart';

import '../../domain/domain.dart';

@Singleton()
class LoggingService {
  final BehaviorSubject<List<AppLog>> _logsSubject =
      BehaviorSubject<List<AppLog>>.seeded(<AppLog>[]);

  final List<AppLog> _logs = <AppLog>[];
  final Logger _logger = Logger();

  void addLog(AppLog log) {
    _logs.add(log);
    _logsSubject.add(_logs.toList());
    log.map(
      info: (InfoLog log) => _logger.i(log.info),
      error: (ErrorLog log) => _logger.e(
        log.message,
        error: log.error,
        stackTrace: log.stackTrace,
      ),
    );
  }

  Stream<List<AppLog>> watchLogs() => _logsSubject.stream;
}
