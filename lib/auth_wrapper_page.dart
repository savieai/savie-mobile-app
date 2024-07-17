import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

import 'application/di/di.dart';
import 'presentation/presentation.dart';
import 'presentation/router/app_router.gr.dart';

@RoutePage()
class AuthWrapperPage extends StatelessWidget implements AutoRouteWrapper {
  AuthWrapperPage({
    super.key,
  });

  final AuthStatusCubit authCubit = getIt.get<AuthStatusCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthStatusCubit, bool>(
      builder: (BuildContext context, bool loggedIn) {
        return AutoRouter.declarative(
          routes: (_) => <PageRouteInfo>[
            if (loggedIn) const AppRoute() else const OnboardingdRoute(),
          ],
        );
      },
    );
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<AuthStatusCubit>.value(
          value: getIt.get<AuthStatusCubit>(),
        ),
        BlocProvider<AuthCubit>.value(
          value: getIt.get<AuthCubit>(),
        ),
      ],
      child: this,
    );
  }
}
