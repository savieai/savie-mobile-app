import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'application/application.dart';
import 'domain/model/app_log.dart';
import 'firebase_options.dart';
import 'infrastructure/service/logging_service.dart';
import 'presentation/savie_app.dart';

late final bool wasInitiallyLoggedIn;

void main() async {
  runZonedGuarded(
    () async {
      final WidgetsBinding widgetsBinding =
          WidgetsFlutterBinding.ensureInitialized();

      if (Platform.isMacOS) {
        await windowManager.ensureInitialized();
        await _setupTray();
      }

      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
      Hive.init((await getApplicationDocumentsDirectory()).path);

      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      await Supabase.initialize(
        url: 'https://dluwcbfoyzaweccmahye.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRsdXdjYmZveXphd2VjY21haHllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTkzODkyNjQsImV4cCI6MjAzNDk2NTI2NH0.F-NoFb0zV5QaaM_S4VhiDA9lf7ShNo6GYIPCCi9XQSQ',
        debug: kDebugMode,
      );

      wasInitiallyLoggedIn =
          Supabase.instance.client.auth.currentSession != null;
      await configureDependencies();

      runApp(const SavieApp());
    },
    (Object e, StackTrace s) {
      FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(exception: e, stack: s),
      );
      getIt.get<LoggingService>().addLog(
            ErrorLog(
              error: e,
              message: 'Unknown error',
              stackTrace: s,
            ),
          );
    },
  );
}

Future<void> _setupTray() async {
  bool isLightMode() =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.light;

  WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
      () async => _setTrayIcon(isLightMode: isLightMode());

  await _setTrayIcon(isLightMode: isLightMode());

  trayManager.addListener(CustomTrayListener());
  WindowManager.instance.waitUntilReadyToShow(null, _updateContextMenu);
  WindowManager.instance.addListener(CustomWindowListener());
}

Future<void> _updateContextMenu() async {
  final bool isShown = await WindowManager.instance.isFocused();

  final Menu menu = Menu(
    items: <MenuItem>[
      MenuItem(
        key: 'hide_or_show',
        label: isShown ? 'Hide' : 'Show',
        onClick: (_) {
          if (isShown) {
            WindowManager.instance.hide();
          } else {
            WindowManager.instance.show();
          }
        },
      ),
      MenuItem(
        key: 'quit',
        label: 'Quit',
        onClick: (_) {
          WindowManager.instance.destroy();
        },
      ),
    ],
  );
  await trayManager.setContextMenu(menu);
}

Future<void> _setTrayIcon({required bool isLightMode}) async {
  await trayManager.setIcon(
    isLightMode ? 'assets/tray_icon_light.svg' : 'assets/tray_icon_dark.svg',
    iconPosition: TrayIconPositon.right,
  );
}

class CustomTrayListener extends TrayListener {
  @override
  void onTrayIconMouseDown() => trayManager.popUpContextMenu();

  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();
}

class CustomWindowListener extends WindowListener {
  @override
  void onWindowBlur() => _updateContextMenu();

  @override
  void onWindowFocus() => _updateContextMenu();
}
