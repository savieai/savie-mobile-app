import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'application/di/di.dart';
import 'presentation/cubit/player_cubit/player_cubit.dart';
import 'presentation/presentation.dart';

@RoutePage()
class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<void>>[
        BlocProvider<PlayerCubit>(create: (_) => getIt.get<PlayerCubit>()),
        BlocProvider<ChatCubit>(create: (_) => getIt.get<ChatCubit>()),
        BlocProvider<ContextMenuCubit>(create: (_) => ContextMenuCubit()),
        BlocProvider<ChatInsetsCubit>(create: (_) => ChatInsetsCubit()),
        BlocProvider<AuthCubit>.value(value: getIt.get<AuthCubit>()),
        BlocProvider<RecordingCubit>(
          create: (_) => getIt.get<RecordingCubit>(),
        ),
      ],
      child: const ContextMenuListener(
        child: AutoRouter(),
      ),
    );
  }
}
