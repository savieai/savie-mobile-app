import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import '../../chat/widget/widget.dart';
import '../cubit/search_cubit.dart';
import 'no_results_placeholder.dart';

class SearchAudioFiles extends StatelessWidget {
  const SearchAudioFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchCubit, SearchState, TabSearchState>(
      selector: (SearchState state) => state.audios,
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
                final AudioSearchResult audio =
                    data[index] as AudioSearchResult;

                return ContextMenuRegion(
                  data: <ContextMenuItemData>[
                    ContextMenuItemData(
                      title: 'Show in chat',
                      icon: Assets.icons.messageCircle16,
                      color: AppColors.textPrimary,
                      onTap: () {
                        context.read<ChatCubit>().findMessage(audio.messageId);

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.router.maybePop();
                        });
                      },
                    ),
                  ],
                  heroTag: '${audio.hashCode}',
                  builder: (_, __, ___) => LayoutBuilder(
                    builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: AudioView(
                          expand: true,
                          previewInfo: true,
                          audioMessage: audio.audioMessage,
                          width: constraints.maxWidth,
                        ),
                      );
                    },
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
