import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation.dart';
import '../../router/app_router.gr.dart';

@RoutePage()
class OnboardingdPage extends StatelessWidget {
  const OnboardingdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (BuildContext context, AuthState state) {
        // TODO: block ui when signing in

        if (state is LoggedIn) {
          context.router.replace(const ChatRoute());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 64),
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
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 60 - 24),
                  child: Assets.images.voiceMemo.image(),
                ),
              ),
              // TODO: create custom button
              const _AppleSignInButton(),
              const SizedBox(height: 12),
              const _GoogleSignInButton(),
              const SizedBox(height: 32),
            ],
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
      onTap: context.read<AuthCubit>().signInWithGoogle,
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
      onTap: context.read<AuthCubit>().signInWithApple,
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    required this.leadingGenImage,
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.addBorder = false,
  });

  final SvgGenImage leadingGenImage;
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  final bool addBorder;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      borderRadius: BorderRadius.circular(20),
      minSize: 0,
      padding: EdgeInsets.zero,
      onPressed: onTap,
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
            leadingGenImage.svg(),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.paragraph.copyWith(
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
