import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import '../presentation.dart';

@RoutePage()
class EnterReferralCodePage extends StatelessWidget {
  const EnterReferralCodePage({super.key});

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
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding:
              MediaQuery.viewInsetsOf(context) + MediaQuery.paddingOf(context),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 385,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: <Widget>[
                    const _EnterReferalCodeBox(),
                    const Spacer(),
                    Text(
                      'I don’t have a referral code, but I’d\nlike to join the whitelist',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.paragraph.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const Spacer(),
                    _JoinWishListButton(),
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

class _EnterReferalCodeBox extends StatelessWidget {
  const _EnterReferalCodeBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 32),
            Text(
              '👀',
              style: TextStyle(fontSize: 44),
            ),
            SizedBox(height: 12),
            Text(
              'Final step! We’re in test mode and only letting in people with invites. You have an invite, right?',
              style: AppTextStyles.paragraph,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _EnterReferalCodeField(),
            SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _EnterReferalCodeField extends StatelessWidget {
  const _EnterReferalCodeField();

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.backgroundChatInput,
      ),
      style: AppTextStyles.paragraph,
      placeholderStyle: const TextStyle(color: AppColors.textSecondary),
      placeholder: 'Enter a referral code',
      cursorColor: AppColors.iconAccent,
      suffix: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Assets.icons.selected24.svg(
          colorFilter: const ColorFilter.mode(
            AppColors.iconAccent,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _JoinWishListButton extends StatelessWidget {
  const _JoinWishListButton();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: () {
        context.router.maybePopTop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: GradientBoxBorder(
            gradient: LinearGradient(
              colors: <Color>[
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.04),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          color: Colors.white.withOpacity(0.2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
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
    );
  }
}
