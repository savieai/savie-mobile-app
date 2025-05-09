import 'package:auto_route/auto_route.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

import '../../../../application/application.dart';
import '../../../presentation.dart';
import '../../../router/app_router.gr.dart';
import '../cubit/otp_cubit.dart';

@RoutePage()
class OtpSubmissionPage extends StatefulWidget {
  const OtpSubmissionPage({super.key});

  @override
  State<OtpSubmissionPage> createState() => _OtpSubmissionPageState();
}

class _OtpSubmissionPageState extends State<OtpSubmissionPage> {
  final ValueNotifier<String?> _errorMessageNotifier =
      ValueNotifier<String?>(null);
  String _lastEmailValue = '';
  late final TextEditingController _controller = TextEditingController()
    ..addListener(() {
      if (_errorMessageNotifier.value != null &&
          _controller.text != _lastEmailValue) {
        _errorMessageNotifier.value = null;
      }
      _lastEmailValue = _controller.text;
    });

  @override
  void initState() {
    super.initState();
    getIt
        .get<TrackUseActivityUseCase>()
        .execute(AppEvents.emailLogin.screenOpened);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <SingleChildWidget>[
        _otpSentListener,
        _otpSendingFailureListener,
      ],
      child: Scaffold(
        appBar: CustomAppBar(
          leading: CustomIconButton(
            svgGenImage: Assets.icons.arrowLeft24,
            onTap: context.router.maybePop,
          ),
          middle: const SizedBox(),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 5),
              const Text(
                'Welcome',
                style: AppTextStyles.title1,
              ),
              const SizedBox(height: 12),
              Text(
                'Sign up with a new email or sign in use an existing account.',
                style: AppTextStyles.paragraph.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _EmailTextField(controller: _controller),
              _MaybeError(errorMessageNotifier: _errorMessageNotifier),
              const Spacer(),
              _ContinueButton(controller: _controller),
              Builder(builder: (BuildContext context) {
                return SizedBox(
                  height: MediaQuery.paddingOf(context).bottom + 20,
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  BlocListener<OtpCubit, OtpState> get _otpSentListener =>
      BlocListener<OtpCubit, OtpState>(
        listener: (BuildContext context, OtpState state) {
          context.router.push(OtpConfirmationRoute(
            email: _controller.text,
          ));
        },
        listenWhen: (OtpState previous, OtpState current) =>
            previous is SendingOTP && current is OtpSent,
      );

  BlocListener<OtpCubit, OtpState> get _otpSendingFailureListener =>
      BlocListener<OtpCubit, OtpState>(
        listener: (BuildContext context, OtpState state) {
          _errorMessageNotifier.value = (state as OtpSendingFailed).message;
        },
        listenWhen: (OtpState previous, OtpState current) =>
            current is OtpSendingFailed,
      );
}

class _MaybeError extends StatelessWidget {
  const _MaybeError({
    required this.errorMessageNotifier,
  });

  final ValueNotifier<String?> errorMessageNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: errorMessageNotifier,
      builder: (BuildContext context, String? errorMessage, _) {
        if (errorMessage != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            ),
            child: Text(
              errorMessage,
              style: AppTextStyles.callout.copyWith(
                color: AppColors.iconNegative,
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

class _EmailTextField extends StatelessWidget {
  const _EmailTextField({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultTextHeightBehavior(
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
      child: CupertinoTextField(
        controller: controller,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.backgroundChatInput,
        ),
        style: AppTextStyles.paragraph,
        placeholderStyle: const TextStyle(color: AppColors.textSecondary),
        placeholder: 'alex@savie.ai',
        cursorColor: AppColors.iconAccent,
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OtpCubit, OtpState, bool>(
      selector: (OtpState state) {
        return state is SendingOTP;
      },
      builder: (BuildContext context, bool isSendingOtp) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (BuildContext context, TextEditingValue value, _) {
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: !isSendingOtp && EmailValidator.validate(value.text)
                  ? 1
                  : 0.5,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(20),
                minSize: 0,
                onPressed: !isSendingOtp && EmailValidator.validate(value.text)
                    ? () {
                        getIt.get<TrackUseActivityUseCase>().execute(AppEvents
                            .emailLogin
                            .continuePressed(email: value.text));
                        context.read<OtpCubit>().submitEmail(value.text);
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.iconAccent,
                  ),
                  child: Text(
                    'Continue',
                    style: AppTextStyles.paragraph.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
