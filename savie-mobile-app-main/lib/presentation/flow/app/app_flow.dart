import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_notification/in_app_notification.dart';

import '../../../application/application.dart';
import '../../presentation.dart';
import '../logs_wrapper_flow.dart';

@RoutePage(name: 'AppFlowRoute')
class AppFlow extends StatelessWidget {
  const AppFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<void>>[
        BlocProvider<PlayerCubit>(create: (_) => getIt.get<PlayerCubit>()),
        BlocProvider<ChatCubit>(
          create: (_) => getIt.get<ChatCubit>(
            param2: true,
          ),
        ),
        BlocProvider<ContextMenuCubit>(create: (_) => ContextMenuCubit()),
        BlocProvider<AuthCubit>.value(value: getIt.get<AuthCubit>()),
        BlocProvider<RecordingCubit>(
          create: (_) => getIt.get<RecordingCubit>(),
        ),
      ],
      child: const LogsWrapper(
        child: InAppNotification(
          child: ProgressHud(
            child: ContextMenuListener(
              child: ContextMenuScope(
                child: AutoRouter(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
