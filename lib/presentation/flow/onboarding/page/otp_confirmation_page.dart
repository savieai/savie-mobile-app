import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../presentation.dart';
import '../cubit/otp_cubit.dart';

@RoutePage()
class OtpConfirmationPage extends StatefulWidget {
  const OtpConfirmationPage({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<OtpConfirmationPage> createState() => _OtpConfirmationPageState();
}

class _OtpConfirmationPageState extends State<OtpConfirmationPage> {
  final ValueNotifier<bool> _hasErrorNotifier = ValueNotifier<bool>(false);
  String _lastOtpValue = '';
  late final TextEditingController _controller = TextEditingController()
    ..addListener(() {
      if (_hasErrorNotifier.value && _lastOtpValue != _controller.text) {
        _hasErrorNotifier.value = false;
      }
      _lastOtpValue = _controller.text;
    });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpCubit, OtpState>(
      listener: (BuildContext context, OtpState state) {
        _hasErrorNotifier.value = true;
      },
      listenWhen: (OtpState previous, OtpState current) =>
          current is OtpVerificationFailed,
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
                'Enter Code',
                style: AppTextStyles.title1,
              ),
              const SizedBox(height: 12),
              Text(
                'We’ve sent a code to ${widget.email}',
                style: AppTextStyles.paragraph.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _OtpTextField(controller: _controller),
              _MaybeError(hasErrorNotifier: _hasErrorNotifier),
              const Spacer(),
              _ResendButton(email: widget.email),
              const SizedBox(height: 20),
              _ContinueButton(
                email: widget.email,
                controller: _controller,
              ),
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
}

class _MaybeError extends StatelessWidget {
  const _MaybeError({
    required this.hasErrorNotifier,
  });

  final ValueNotifier<bool> hasErrorNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: hasErrorNotifier,
      builder: (BuildContext context, bool hasError, _) {
        if (hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            ),
            child: Text(
              'Incorrect code',
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

class _OtpTextField extends StatelessWidget {
  const _OtpTextField({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Pinput(
          length: 6,
          controller: controller,
          separatorBuilder: (_) => const SizedBox(width: 8),
          defaultPinTheme: PinTheme(
            constraints: BoxConstraints.tightFor(
              width: (constraints.maxWidth - 30) / 6,
              height: 56,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.backgroundChatInput,
            ),
            textStyle: AppTextStyles.paragraph.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.controller,
    required this.email,
  });

  final TextEditingController controller;
  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OtpCubit, OtpState, bool>(
      selector: (OtpState state) {
        return state is VerifyingOTP;
      },
      builder: (BuildContext context, bool isVerifyingOtp) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (BuildContext context, TextEditingValue value, _) {
            final bool isCodeEntered = value.text.length == 6;

            return AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: !isVerifyingOtp && isCodeEntered ? 1 : 0.5,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(20),
                minSize: 0,
                onPressed: !isVerifyingOtp && isCodeEntered
                    ? () => context.read<OtpCubit>().verifyOTP(
                          email: email,
                          otp: value.text,
                        )
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

class _ResendButton extends StatefulWidget {
  const _ResendButton({
    required this.email,
  });

  final String email;

  @override
  State<_ResendButton> createState() => _ResendButtonState();
}

class _ResendButtonState extends State<_ResendButton> {
  ValueNotifier<Duration>? _timeLeftNotifier;
  Timer? _timer;

  @override
  void initState() {
    _initTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeLeftNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Experiencing issues receiving the code?',
            style: AppTextStyles.paragraph.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          BlocSelector<OtpCubit, OtpState, bool>(
            selector: (OtpState state) {
              return state is SendingOTP || state is ResendingOTP;
            },
            builder: (BuildContext context, bool isSendingOtp) {
              return ValueListenableBuilder<Duration>(
                valueListenable: _timeLeftNotifier!,
                builder: (BuildContext context, Duration value, _) {
                  final bool canPress = value <= Duration.zero;

                  return GestureDetector(
                    onTap: canPress && !isSendingOtp
                        ? () => context
                            .read<OtpCubit>()
                            .resubmitEmail(widget.email)
                            .then((_) => _initTimer())
                        : null,
                    child: Text(
                      canPress
                          ? 'Resend code'
                          : 'Resend code (${_durationFormatted(value)})',
                      style: AppTextStyles.paragraph.copyWith(
                        color: AppColors.iconAccent.withOpacity(
                          canPress && !isSendingOtp ? 1 : 0.5,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _initTimer() {
    final Duration timeLeft = context.read<OtpCubit>().state.maybeWhen(
          otpSent: (DateTime sentAt) =>
              sentAt.add(const Duration(minutes: 1)).difference(DateTime.now()),
          orElse: () => Duration.zero,
        );
    _timeLeftNotifier = ValueNotifier<Duration>(timeLeft);

    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (!mounted) {
          return;
        }

        if (_timeLeftNotifier!.value <= const Duration(seconds: -1)) {
          timer.cancel();
        } else {
          _timeLeftNotifier!.value =
              _timeLeftNotifier!.value - const Duration(seconds: 1);
        }
      },
    );
  }

  String _durationFormatted(Duration duration) {
    final String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitSeconds =
        twoDigits(duration.inSeconds.remainder(60).abs());
    return '$negativeSign${duration.inMinutes}:$twoDigitSeconds';
  }
}
