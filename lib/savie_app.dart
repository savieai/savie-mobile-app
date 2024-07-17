import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'application/application.dart';
import 'presentation/presentation.dart';

class SavieApp extends StatelessWidget {
  const SavieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<void>>[
        BlocProvider<AuthStatusCubit>.value(
          value: getIt.get<AuthStatusCubit>(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: getIt.get<AppRouter>().config(
              navigatorObservers: () => <NavigatorObserver>[HeroController()],
            ),
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundPrimary,
        ),
      ),
    );
  }
}
