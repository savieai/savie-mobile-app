import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

import '../../application/di/di.dart';
import '../presentation.dart';
import '../router/app_router.gr.dart';

@RoutePage(name: 'AuthWrapperFlowRoute')
class AuthWrapperFlow extends StatelessWidget implements AutoRouteWrapper {
  const AuthWrapperFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthStatusCubit, bool>(
      builder: (BuildContext context, bool loggedIn) {
        return AutoRouter.declarative(
          routes: (_) => <PageRouteInfo>[
            if (loggedIn) ...<PageRouteInfo>[
              const AppFlowRoute(),
              const EnterReferralCodeRoute(),
            ] else
              const OnboardingFlowRoute(),
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
