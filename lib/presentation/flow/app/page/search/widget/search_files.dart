import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../presentation.dart';

class SearchFiles extends StatelessWidget {
  const SearchFiles({super.key});

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
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: <Widget>[
              if (index == 0) const _NonPreviewFile() else const _PreviewFile(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'BoardingPass.pdf',
                      style: AppTextStyles.paragraph.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1.4MB · June 14, 2024 at 20:21',
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

class _PreviewFile extends StatelessWidget {
  const _PreviewFile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: <Widget>[
          const AuthProtectedNetworkImage(
            'https://s.cafebazaar.ir/images/icons/com.Nature.WallappersQuick-f4c4352a-467d-4ffb-85e9-f4fa7645f1e2_512x512.png?x-img=v1/resize,h_256,w_256,lossless_false/optimize',
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.strokePrimaryAlpha,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            left: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 4,
                  sigmaY: 4,
                ),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: AppColors.strokePrimaryAlpha.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  child: Row(
                    children: <Widget>[
                      Assets.icons.file12.svg(
                        colorFilter: const ColorFilter.mode(
                          AppColors.textInvert,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: FittedBox(
                          child: Text(
                            'PDF',
                            maxLines: 1,
                            style: AppTextStyles.description.copyWith(
                              color: AppColors.textInvert,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NonPreviewFile extends StatelessWidget {
  const _NonPreviewFile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.strokePrimaryAlpha,
        ),
        borderRadius: BorderRadius.circular(10),
        color: AppColors.backgroundSecondary,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Assets.icons.file12.svg(
              colorFilter: const ColorFilter.mode(
                AppColors.iconAccent,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'zip',
              maxLines: 1,
              style: AppTextStyles.description.copyWith(
                color: AppColors.iconAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
