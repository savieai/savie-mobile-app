import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../application/application.dart';
import 'presentation.dart';

// Disable socket related warnings
const bool _debugNetworkingFlag = false;

class SavieApp extends StatelessWidget {
  const SavieApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Disable socket warnings
    if (!_debugNetworkingFlag) {
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception.toString().contains('socket') || 
            details.exception.toString().contains('SO_NOWAKEFROMSLEEP')) {
          // Ignore socket related errors
          return;
        }
        
        // Handle other errors normally
        FlutterError.presentError(details);
      };
    }
    
    return MaterialApp.router(
      routerConfig: getIt.get<AppRouter>().config(
            navigatorObservers: () => <NavigatorObserver>[
              HeroController(),
            ],
          ),
      localizationsDelegates: const <LocalizationsDelegate<void>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundPrimary,
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: AppColors.iconAccent,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.iconAccent,
          selectionColor: AppColors.iconAccent.withValues(alpha: 0.2),
          selectionHandleColor: AppColors.iconAccent.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
