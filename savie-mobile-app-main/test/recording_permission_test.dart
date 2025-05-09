import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:permission_handler_platform_interface/src/method_channel/method_channel_permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mocktail/mocktail.dart';

class _MockPermissionHandler extends Mock implements PermissionHandlerPlatform {}

void main() {
  late _MockPermissionHandler mockHandler;

  setUp(() {
    mockHandler = _MockPermissionHandler();
    PermissionHandlerPlatform.instance = mockHandler;
  });

  test('first request returns granted -> recording starts', () async {
    when(() => mockHandler.checkPermissionStatus(Permission.microphone))
        .thenAnswer((_) async => PermissionStatus.denied);
    when(() => mockHandler.requestPermissions(<Permission>[Permission.microphone]))
        .thenAnswer((_) async => <Permission, PermissionStatus>{
              Permission.microphone: PermissionStatus.granted,
            });

    final PermissionStatus status = await Permission.microphone.request();
    expect(status, PermissionStatus.granted);
  });

  test('first request returns permanentlyDenied -> open settings called once', () async {
    when(() => mockHandler.checkPermissionStatus(Permission.microphone))
        .thenAnswer((_) async => PermissionStatus.denied);
    when(() => mockHandler.requestPermissions(<Permission>[Permission.microphone]))
        .thenAnswer((_) async => <Permission, PermissionStatus>{
              Permission.microphone: PermissionStatus.permanentlyDenied,
            });

    final PermissionStatus status = await Permission.microphone.request();
    expect(status, PermissionStatus.permanentlyDenied);
  });
} 