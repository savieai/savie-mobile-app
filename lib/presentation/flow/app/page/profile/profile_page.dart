import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../presentation.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onTap: () {},
          ),
          const _ProfileSeparator(),
          _ProfileTile(
            title: 'Delete Profile',
            icon: Assets.icons.delete24,
            color: AppColors.iconNegative,
            onTap: () {},
          ),
          _ProfileTile(
            title: 'Log out',
            icon: Assets.icons.logOut24,
            color: AppColors.iconNegative,
            onTap: context.read<AuthCubit>().logOut,
          ),
          const Spacer(),
          Text(
            'Terms & Terms',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'App Version · 1.0',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Savie',
            style: AppTextStyles.callout.copyWith(
              color: AppColors.iconAccent,
            ),
          ),
          SizedBox(height: 16 + MediaQuery.paddingOf(context).bottom),
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
