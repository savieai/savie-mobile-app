import 'dart:io';

import 'package:flutter/material.dart';

import '../../presentation.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.middle,
    this.leading,
    this.trailing,
    this.backgroundColor,
  });

  final Widget middle;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;

  static double get preferredHeight => Platform.isMacOS ? 52 : 64;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.backgroundPrimary,
      child: SafeArea(
        bottom: false,
        minimum: EdgeInsets.symmetric(horizontal: Platform.isMacOS ? 16 : 12),
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
  Size get preferredSize => Size.fromHeight(preferredHeight);
}
