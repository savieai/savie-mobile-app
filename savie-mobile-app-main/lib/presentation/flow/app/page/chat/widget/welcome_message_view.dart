import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../../../../presentation.dart';

class WelcomeMessageView extends StatelessWidget {
  const WelcomeMessageView({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      alignment: Alignment.centerLeft,
      child: Align(
        alignment: Alignment.centerLeft,
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(20),
          dashPattern: const <double>[4],
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          color: AppColors.strokePrimaryAlpha,
          child: Text(
            text,
            style: AppTextStyles.paragraph.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
