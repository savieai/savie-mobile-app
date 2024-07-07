import 'package:flutter/material.dart';

import '../../presentation.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.middle,
    this.leading,
    this.trailing,
  });

  final Widget middle;
  final Widget? leading;
  final Widget? trailing;

  static const double preferredHeight = 64;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundPrimary,
      child: SafeArea(
        bottom: false,
        minimum: const EdgeInsets.symmetric(horizontal: 12),
        child: NavigationToolbar(
          leading: leading,
          middle: DefaultTextStyle(
            style: AppTextStyles.title2.copyWith(
              color: AppColors.textPrimary,
            ),
            child: middle,
          ),
          trailing: trailing,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(preferredHeight);
}
