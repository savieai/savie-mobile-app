import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import '../../chat/widget/widget.dart';
import '../cubit/search_cubit.dart';

class SearchFiles extends StatelessWidget {
  const SearchFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchCubit, SearchState, TabSearchState>(
      selector: (SearchState state) => state.files,
      builder: (BuildContext context, TabSearchState state) {
        return state.when(
          initial: () => const SizedBox(),
          fetching: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          fetched: (List<SearchResult> data) {
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                MediaQuery.paddingOf(context).bottom,
              ),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                final FileSearchResult file = data[index] as FileSearchResult;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: <Widget>[
                      FilePreview(file: file.file),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              file.file.name,
                              style: AppTextStyles.paragraph.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('MMMM dd').format(file.date)}, ${file.date.year} at ${DateFormat('hh:mm').format(file.date)}',
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
          },
        );
      },
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
