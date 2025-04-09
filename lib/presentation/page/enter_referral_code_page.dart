import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import '../../application/application.dart';
import '../cubit/user/user_cubit.dart';
import '../presentation.dart';

@RoutePage()
class EnterReferralCodePage extends StatefulWidget {
  const EnterReferralCodePage({super.key});

  @override
  State<EnterReferralCodePage> createState() => _EnterReferralCodePageState();
}

class _EnterReferralCodePageState extends State<EnterReferralCodePage> {
  @override
  void initState() {
    super.initState();
    getIt
        .get<TrackUseActivityUseCase>()
        .execute(AppEvents.referralCheck.screenOpened);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xFFFB5012),
            Color(0xFFFF8254),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          middle: const SizedBox(),
          leading: CustomIconButton(
            svgGenImage: Assets.icons.logOut24,
            color: AppColors.iconInvert,
            onTap: () {
              context.read<AuthCubit>().logOut();
            },
          ),
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Center(
            child: SizedBox(
              width: Platform.isMacOS ? 464 : double.infinity,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 385,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: _Body(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final bool whitelistRequested = context.select<UserCubit, bool>(
      (UserCubit cubit) => cubit.state?.joinWaitlist ?? false,
    );

    return Column(
      children: <Widget>[
        const _EnterReferalCodeBox(),
        const Spacer(),
        if (whitelistRequested)
          Center(
            child: Text(
              'Requested to join the whitelist',
              textAlign: TextAlign.center,
              style: AppTextStyles.paragraph.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          )
        else ...<Widget>[
          Text(
            'No referral code? Join the whitelist.',
            textAlign: TextAlign.center,
            style: AppTextStyles.paragraph.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          const _JoinWishListButton(),
        ],
      ],
    );
  }
}

class _EnterReferalCodeBox extends StatelessWidget {
  const _EnterReferalCodeBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 32),
            const Text(
              '👀',
              style: TextStyle(fontSize: 44),
            ),
            const SizedBox(height: 12),
            Text(
              'Almost there! Savie is invite-only for those who value a clear mind. Got your invite, right?',
              style: AppTextStyles.paragraph,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const _EnterReferalCodeField(),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _EnterReferalCodeField extends StatefulWidget {
  const _EnterReferalCodeField();

  @override
  State<_EnterReferalCodeField> createState() => _EnterReferalCodeFieldState();
}

class _EnterReferalCodeFieldState extends State<_EnterReferalCodeField>
    with SingleTickerProviderStateMixin {
  bool _isRequesting = false;
  final TextEditingController _controller = TextEditingController();
  late final AnimationController _errorController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _errorController,
      builder: (BuildContext context, _) {
        return CupertinoTextField(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(AppColors.backgroundChatInput,
                  AppColors.iconNegative, _errorController.value)!,
            ),
            color: AppColors.backgroundChatInput,
          ),
          controller: _controller,
          enabled: !_isRequesting,
          onChanged: (_) {
            if (!_errorController.isDismissed) {
              _errorController.reverse();
            }
          },
          style: AppTextStyles.paragraph,
          placeholderStyle: const TextStyle(color: AppColors.textSecondary),
          placeholder: 'Enter a referral code',
          cursorColor: AppColors.iconAccent,
          suffix: GestureDetector(
            onTap: () async {
              setState(() => _isRequesting = true);

              final bool result = await getIt
                  .get<ApplyInviteUseCase>()
                  .execute(_controller.text);

              if (result) {
                getIt
                    .get<TrackUseActivityUseCase>()
                    .execute(AppEvents.referralCheck.success);
              }

              setState(() => _isRequesting = false);
              if (!result) {
                _errorController.forward();
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Assets.icons.selected24.svg(
                colorFilter: const ColorFilter.mode(
                  AppColors.iconAccent,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _JoinWishListButton extends StatefulWidget {
  const _JoinWishListButton();

  @override
  State<_JoinWishListButton> createState() => _JoinWishListButtonState();
}

class _JoinWishListButtonState extends State<_JoinWishListButton> {
  bool _requesting = false;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _requesting,
      child: AnimatedOpacity(
        opacity: _requesting ? 0.5 : 1,
        duration: const Duration(milliseconds: 100),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () async {
            getIt
                .get<TrackUseActivityUseCase>()
                .execute(AppEvents.referralCheck.joinWhitelistPressed);

            setState(() => _requesting = true);
            await context.read<UserCubit>().joinWhiteList();
            setState(() => _requesting = false);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: GradientBoxBorder(
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              color: Colors.white.withValues(alpha: 0.2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Join Whitelist',
              style: AppTextStyles.paragraph.copyWith(
                color: AppColors.textInvert,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
