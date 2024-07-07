import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'application/application.dart';
import 'presentation/cubit/player_cubit/player_cubit.dart';
import 'presentation/presentation.dart';

class SavieApp extends StatelessWidget {
  const SavieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<void>>[
        BlocProvider<PlayerCubit>.value(value: getIt.get<PlayerCubit>()),
        BlocProvider<ContextMenuCubit>(create: (_) => ContextMenuCubit()),
        BlocProvider<ChatInsetsCubit>(create: (_) => ChatInsetsCubit()),
      ],
      child: MaterialApp.router(
        routerConfig: getIt.get<AppRouter>().config(),
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundPrimary,
        ),
        builder: (BuildContext context, Widget? child) {
          return ContextMenuListener(
            child: child ?? const SizedBox(),
          );
        },
      ),
    );
  }
}
