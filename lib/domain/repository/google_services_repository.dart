abstract interface class GoogleServicesRepository {
  bool get isConnected;
  Stream<bool> get isConnectedStream;

  Future<void> connect();
  Future<void> disconnect();
  Future<void> addCalendarEvent();
}
