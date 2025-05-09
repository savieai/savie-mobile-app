import 'package:flutter/cupertino.dart';

import '../../../../../presentation.dart';

class NoResultsPlaceholder extends StatelessWidget {
  const NoResultsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 52),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Assets.icons.savieMonoLogo.svg(),
          const SizedBox(height: 12),
          Text(
            'Here you will see all the media files\nand links you have uploaded.',
            style: AppTextStyles.paragraph.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
