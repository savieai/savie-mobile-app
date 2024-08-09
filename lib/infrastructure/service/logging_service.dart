import 'package:injectable/injectable.dart';
import 'package:rxdart/subjects.dart';

import '../../domain/domain.dart';

@Singleton()
class LoggingService {
  final BehaviorSubject<List<AppLog>> _logsSubject =
      BehaviorSubject<List<AppLog>>.seeded(<AppLog>[]);

  final List<AppLog> _logs = <AppLog>[];

  void addLog(AppLog log) {
    _logs.add(log);
    _logsSubject.add(_logs.toList());
  }

  Stream<List<AppLog>> watchLogs() => _logsSubject.stream;
}
