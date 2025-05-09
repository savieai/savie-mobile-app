import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../application/application.dart';
import '../../../presentation.dart';
import '../../../router/app_router.gr.dart';

@RoutePage()
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _currentSlide = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    getIt
        .get<TrackUseActivityUseCase>()
        .execute(AppEvents.welcome.screenOpened);
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      _currentSlide = _currentSlide + 1;
      if (mounted && context.mounted) {
        setState(() {});
      }

      if (_currentSlide == 4) {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Platform.isMacOS ? 464 : double.infinity,
      child: BlocListener<AuthCubit, AuthState>(
        listener: (BuildContext context, AuthState state) {
          // TODO: block ui when signing in

          if (state is LoggedIn) {
            context.router.replace(const ChatRoute());
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          body: Center(
            child: SizedBox(
              width: Platform.isMacOS ? 464 : double.infinity,
              child: SafeArea(
                minimum: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 32),
                    Text(
                      'Savie',
                      style: AppTextStyles.title1.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Unload your brain.\nChat with yourself.',
                      style: AppTextStyles.paragraph.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        child: FittedBox(
                          child: SizedBox(
                            height: 324,
                            width: 393,
                            child: Stack(
                              children: <Widget>[
                                AnimatedPositioned(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOutCubic,
                                  top: _currentSlide == 4 ? -40 : 30,
                                  left: 0,
                                  right: 0,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    switchInCurve: Curves.linearToEaseOut,
                                    switchOutCurve: Curves.easeIn,
                                    transitionBuilder: (
                                      Widget child,
                                      Animation<double> animation,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: switch (_currentSlide) {
                                      0 => Assets.images.audio.image(
                                          key: const ValueKey<int>(0),
                                          width: 393,
                                        ),
                                      1 => Assets.images.spanish.image(
                                          key: const ValueKey<int>(1),
                                          width: 393,
                                        ),
                                      2 => Assets.images.list.image(
                                          key: const ValueKey<int>(2),
                                          width: 393,
                                        ),
                                      _ => Assets.images.images.image(
                                          key: const ValueKey<int>(3),
                                          width: 393,
                                        ),
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: -10,
                                  left: 0,
                                  right: 0,
                                  child: AnimatedScale(
                                    alignment: const Alignment(0, 0.5),
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    curve: Curves.easeInOutCubic,
                                    scale: _currentSlide == 4 ? 1 : 0,
                                    child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 1000),
                                      curve: Curves.easeInOutCubic,
                                      opacity: _currentSlide == 4 ? 1 : 0,
                                      child: Center(
                                        child: Assets.images.spanishAudio.image(
                                          width: 393,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const _AppleSignInButton(),
                    const SizedBox(height: 12),
                    const _GoogleSignInButton(),
                    const SizedBox(height: 12),
                    const _EmailSignInButton(),
                    const SizedBox(height: 12),
                    const _TermsAndPolicy(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context) {
    return _SignInButton(
      leadingGenImage: Assets.icons.google24,
      title: 'Continue with Google',
      backgroundColor: Colors.white,
      textColor: AppColors.textPrimary,
      onTap: () {
        getIt
            .get<TrackUseActivityUseCase>()
            .execute(AppEvents.welcome.googleButtonPressed);
        context.read<AuthCubit>().signInWithGoogle();
      },
      addBorder: true,
    );
  }
}

class _AppleSignInButton extends StatelessWidget {
  const _AppleSignInButton();

  @override
  Widget build(BuildContext context) {
    return _SignInButton(
      leadingGenImage: Assets.icons.apple24,
      title: 'Continue with Apple',
      backgroundColor: Colors.black,
      textColor: Colors.white,
      onTap: () {
        getIt
            .get<TrackUseActivityUseCase>()
            .execute(AppEvents.welcome.appleButtonPressed);
        context.read<AuthCubit>().signInWithApple();
      },
    );
  }
}

class _EmailSignInButton extends StatelessWidget {
  const _EmailSignInButton();

  @override
  Widget build(BuildContext context) {
    return _SignInButton(
      title: 'Continue with email',
      backgroundColor: Colors.white,
      textColor: AppColors.textPrimary,
      onTap: () {
        getIt
            .get<TrackUseActivityUseCase>()
            .execute(AppEvents.welcome.emailButtonPressed);
        context.router.push(const OtpFlowRoute());
      },
      addBorder: true,
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    this.leadingGenImage,
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.addBorder = false,
  });

  final SvgGenImage? leadingGenImage;
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  final bool addBorder;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthCubit, AuthState, bool>(
      selector: (AuthState state) {
        return state is! LoggingIn;
      },
      builder: (BuildContext context, bool canTap) {
        return CupertinoButton(
          borderRadius: BorderRadius.circular(20),
          minSize: 0,
          padding: EdgeInsets.zero,
          onPressed: canTap ? onTap : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: canTap ? 1 : 0.4,
            child: Container(
              decoration: BoxDecoration(
                border: addBorder
                    ? Border.all(color: AppColors.strokeSecondaryAlpha)
                    : null,
                borderRadius: BorderRadius.circular(20),
                color: backgroundColor,
              ),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (leadingGenImage != null) ...<Widget>[
                    leadingGenImage!.svg(),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: AppTextStyles.paragraph.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TermsAndPolicy extends StatelessWidget {
  const _TermsAndPolicy();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          const TextSpan(text: 'By continuing, you agree to the\n'),
          TextSpan(
            text: 'Terms of Use',
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: Colors.black.withValues(alpha: 0.2),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse('https://savie.ai/terms'));
                getIt
                    .get<TrackUseActivityUseCase>()
                    .execute(AppEvents.welcome.termsOfUsePressed);
              },
          ),
          const TextSpan(text: ' & '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: Colors.black.withValues(alpha: 0.2),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse('https://savie.ai/privacy'));
                getIt
                    .get<TrackUseActivityUseCase>()
                    .execute(AppEvents.welcome.privacyPolicyPressed);
              },
          ),
          const TextSpan(text: '.'),
        ],
      ),
      style: AppTextStyles.callout.copyWith(
        color: AppColors.textSecondary,
        height: 20 / 14,
      ),
    );
  }
}
