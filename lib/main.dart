import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'application/application.dart';
import 'domain/model/app_log.dart';
import 'firebase_options.dart';
import 'infrastructure/service/logging_service.dart';
import 'presentation/savie_app.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      Hive.init((await getApplicationDocumentsDirectory()).path);

      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      await Supabase.initialize(
        url: 'https://dluwcbfoyzaweccmahye.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRsdXdjYmZveXphd2VjY21haHllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTkzODkyNjQsImV4cCI6MjAzNDk2NTI2NH0.F-NoFb0zV5QaaM_S4VhiDA9lf7ShNo6GYIPCCi9XQSQ',
        debug: kDebugMode,
      );

      await configureDependencies();

      Clipboard.setData(
        ClipboardData(
          text: Supabase.instance.client.auth.currentSession?.accessToken ?? '',
        ),
      );

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
