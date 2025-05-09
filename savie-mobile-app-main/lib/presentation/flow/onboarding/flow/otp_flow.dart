import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../application/application.dart';
import '../../../cubit/cubit.dart';
import '../cubit/otp_cubit.dart';

@RoutePage(name: 'OtpFlowRoute')
class OtpFlow extends StatefulWidget {
  const OtpFlow({super.key});

  @override
  State<OtpFlow> createState() => _OtpFlowState();
}

class _OtpFlowState extends State<OtpFlow> {
  late final OtpCubit _otpCubit = getIt.get<OtpCubit>();
  late final AuthCubit _authCubit = context.read<AuthCubit>();

  @override
  void initState() {
    super.initState();
    _authCubit.initiateEmailSignIn();
  }

  @override
  void dispose() {
    _authCubit.closeEmailSingIn(result: _otpCubit.otpVerified);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OtpCubit>(
      create: (_) => _otpCubit,
      child: const AutoRouter(),
    );
  }
}
