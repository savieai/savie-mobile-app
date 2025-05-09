import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import '../../common/widget/fav_icon.dart';
import '../cubit/search_cubit.dart';
import 'widget.dart';

class SearchLinks extends StatelessWidget {
  const SearchLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchCubit, SearchState, TabSearchState>(
      selector: (SearchState state) => state.links,
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
                MediaQuery.paddingOf(context).bottom,
              ),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                final LinkSearchResult link = data[index] as LinkSearchResult;

                return ContextMenuRegion(
                  data: <ContextMenuItemData>[
                    ContextMenuItemData(
                      title: 'Show in chat',
                      icon: Assets.icons.messageCircle16,
                      color: AppColors.textPrimary,
                      onTap: () {
                        context.read<ChatCubit>().findMessage(link.messageId);

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.router.maybePop();
                        });
                      },
                    ),
                  ],
                  heroTag: '${link.hashCode}',
                  builder: (_, __, ___) => _LinkSearchResultView(link: link),
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

class _LinkSearchResultView extends StatelessWidget {
  const _LinkSearchResultView({
    required this.link,
  });

  final LinkSearchResult link;

  @override
  Widget build(BuildContext context) {
    String completeLink(String url) {
      if (!url.startsWith(RegExp(r'https?://'))) {
        return 'http://$url';
      }
      return url;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            FavIcon(completeLink: completeLink(link.url)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Spacer(),
                  Text(
                    link.url,
                    style: AppTextStyles.paragraph.copyWith(
                      color: AppColors.iconAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('MMMM dd').format(link.date)}, ${link.date.year} at ${DateFormat('hh:mm').format(link.date)}',
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
