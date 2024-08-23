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
