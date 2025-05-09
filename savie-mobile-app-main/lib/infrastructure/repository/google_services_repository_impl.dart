import 'package:injectable/injectable.dart';
import 'package:rxdart/subjects.dart';

import '../../domain/domain.dart';
import '../infrastructure.dart';

@Singleton(as: GoogleServicesRepository)
class GoogleServicesRepositoryImpl implements GoogleServicesRepository {
  GoogleServicesRepositoryImpl(this._googleServicesApi);

  // ignore: unused_field
  final GoogleServicesApi _googleServicesApi;

  final BehaviorSubject<bool> _servicesConnectedSubject =
      BehaviorSubject<bool>.seeded(false);

  @override
  Future<void> connect() async {
    _servicesConnectedSubject.value = true;
  }

  @override
  Future<void> disconnect() async {
    _servicesConnectedSubject.value = false;
  }

  @override
  Future<void> addCalendarEvent() {
    // TODO: implement addCalendarEvent
    throw UnimplementedError();
  }

  @override
  bool get isConnected => _servicesConnectedSubject.value;

  @override
  Stream<bool> get isConnectedStream => _servicesConnectedSubject.stream;
}
