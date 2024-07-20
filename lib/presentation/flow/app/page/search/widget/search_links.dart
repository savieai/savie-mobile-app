import 'package:flutter/material.dart';

import '../../../../../presentation.dart';

class SearchLinks extends StatelessWidget {
  const SearchLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: 100,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: <Widget>[
              Assets.images.link.image(height: 24, width: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'danilakropotkin.com',
                      style: AppTextStyles.paragraph.copyWith(
                        color: AppColors.iconAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'June 14, 2024 at 20:21',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => Container(
        color: AppColors.strokeSecondaryAlpha,
        height: 1,
      ),
    );
  }
}
