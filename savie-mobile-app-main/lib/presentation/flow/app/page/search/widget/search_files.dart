import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import '../../chat/widget/widget.dart';
import '../cubit/search_cubit.dart';
import 'widget.dart';

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
            if (data.isEmpty) {
              return const Center(
                child: NoResultsPlaceholder(),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                max(MediaQuery.viewInsetsOf(context).bottom,
                    MediaQuery.paddingOf(context).bottom),
              ),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                final FileSearchResult file = data[index] as FileSearchResult;

                return ContextMenuRegion(
                  data: <ContextMenuItemData>[
                    ContextMenuItemData(
                      title: 'Show in chat',
                      icon: Assets.icons.messageCircle16,
                      color: AppColors.textPrimary,
                      onTap: () {
                        context.read<ChatCubit>().findMessage(file.messageId);

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.router.maybePop();
                        });
                      },
                    ),
                  ],
                  heroTag: '${file.hashCode}',
                  builder: (_, __, ___) => _FileSearchResultView(file: file),
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

class _FileSearchResultView extends StatelessWidget {
  const _FileSearchResultView({
    required this.file,
  });

  final FileSearchResult file;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            FilePreview(file: file.file),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Spacer(),
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
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
