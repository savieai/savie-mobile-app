import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/model/savie_user.dart';
import '../cubit/user/user_cubit.dart';
import '../router/app_router.gr.dart';

@RoutePage(name: 'InviteWrapperFlowRoute')
class InviteWrapperFlow extends StatelessWidget {
  const InviteWrapperFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, SavieUser?>(
      buildWhen: (SavieUser? previous, SavieUser? current) {
        return current?.accessAllowed ?? false;
      },
      builder: (BuildContext context, SavieUser? user) {
        final bool accessAllowed = user?.accessAllowed ?? false;

        return AutoRouter.declarative(
          routes: (_) => <PageRouteInfo>[
            if (accessAllowed) ...<PageRouteInfo>[
              const AppFlowRoute(),
            ] else
              const EnterReferralCodeRoute(),
          ],
        );
      },
    );
  }
}
