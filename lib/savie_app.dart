import 'package:flutter/material.dart';

import 'application/application.dart';
import 'presentation/presentation.dart';

class SavieApp extends StatelessWidget {
  const SavieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: getIt.get<AppRouter>().config(),
    );
  }
}
