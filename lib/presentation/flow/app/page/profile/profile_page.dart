import 'dart:io';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../application/application.dart';
import '../../../../presentation.dart';
import '../../../../router/app_router.gr.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    getIt
        .get<TrackUseActivityUseCase>()
        .execute(AppEvents.profile.screenOpened);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        leading: CustomIconButton(
          svgGenImage: Assets.icons.arrowLeft24,
          onTap: context.router.maybePop,
        ),
        middle: const Text('Profile'),
      ),
      body: Column(
        children: <Widget>[
          _ProfileTile(
            title:
                Supabase.instance.client.auth.currentSession!.user.email ?? '',
            icon: Assets.icons.user24,
            color: AppColors.textPrimary,
            onTap: null,
          ),
          const _ProfileSeparator(),
          _ProfileTile(
            title: 'Support',
            icon: Assets.icons.support24,
            color: AppColors.textPrimary,
            onTap: () {
              launchUrl(Uri.parse('mailto:support@savie.ai'));
              getIt
                  .get<TrackUseActivityUseCase>()
                  .execute(AppEvents.profile.supportClicked);
            },
          ),
          const _ProfileSeparator(),
          _ProfileTile(
            title: 'Delete Profile',
            icon: Assets.icons.delete24,
            color: AppColors.iconNegative,
            onTap: () {
              getIt
                  .get<TrackUseActivityUseCase>()
                  .execute(AppEvents.profile.deleteProfileClicked);
            },
          ),
          _ProfileTile(
            title: 'Log out',
            icon: Assets.icons.logOut24,
            color: AppColors.iconNegative,
            onTap: () {
              getIt
                  .get<TrackUseActivityUseCase>()
                  .execute(AppEvents.profile.logoutClicked);
              context.read<AuthCubit>().logOut();
            },
          ),
          const Spacer(),
          const _GiftButton(),
          SizedBox(height: AppSpaces.space1000),
          RichText(
            text: TextSpan(
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              children: <InlineSpan>[
                TextSpan(
                  text: 'Terms of Use',
                  style: const TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse('https://savie.ai/privacy'));
                    },
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse('https://savie.ai/privacy'));
                    },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (
              BuildContext context,
              AsyncSnapshot<PackageInfo> packageInfo,
            ) {
              return Text(
                'App Version · ${packageInfo.data?.version ?? '...'}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Savie',
            style: AppTextStyles.callout.copyWith(
              color: AppColors.iconAccent,
            ),
          ),
          SizedBox(
            height: Platform.isMacOS
                ? 50
                : 16 + MediaQuery.viewPaddingOf(context).bottom,
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final SvgGenImage icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            icon.svg(
              height: Platform.isMacOS ? 20 : 24,
              colorFilter: ColorFilter.mode(
                color,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.paragraph.copyWith(
                  color: color,
                ),
              ),
            ),
            if (onTap != null)
              Transform.rotate(
                angle: pi,
                child: Assets.icons.chevronLeft16.svg(
                  colorFilter: const ColorFilter.mode(
                    AppColors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSeparator extends StatelessWidget {
  const _ProfileSeparator();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 4,
      indent: 16,
      endIndent: 16,
      thickness: 1,
      color: AppColors.strokePrimaryAlpha,
    );
  }
}

class _GiftButton extends StatelessWidget {
  const _GiftButton();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () => context.router.push(const GetInviteRoute()),
      minSize: 0,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: const LinearGradient(
            colors: <Color>[
              Color(0xFFFB5012),
              Color(0xFFFF783A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: AppSpaces.space600,
          horizontal: AppSpaces.space700,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Assets.icons.gift24.svg(
              height: Platform.isMacOS ? 20 : 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Gift Savie',
              style: AppTextStyles.paragraph.copyWith(
                color: AppColors.textInvert,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
