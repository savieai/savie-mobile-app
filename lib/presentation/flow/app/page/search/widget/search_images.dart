import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import '../cubit/search_cubit.dart';
import 'images_scrollbar.dart';

class SearchImages extends StatefulWidget {
  const SearchImages({super.key});

  @override
  State<SearchImages> createState() => _SearchImagesState();
}

class _SearchImagesState extends State<SearchImages> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchCubit, SearchState, TabSearchState>(
      selector: (SearchState state) => state.images,
      builder: (BuildContext context, TabSearchState state) {
        return state.when(
          initial: () => const SizedBox(),
          fetching: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          fetched: (List<SearchResult> data) {
            if (data.isEmpty) {
              return const SizedBox();
            }

            return ImagesScrollbar(
              controller: _scrollController,
              heightScrollThumb: 40,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int i) {
                      final ImageSearchResult image =
                          data[i] as ImageSearchResult;
                      return ContextMenuRegion(
                        data: <ContextMenuItemData>[
                          ContextMenuItemData(
                            title: 'Show in chat',
                            icon: Assets.icons.file12,
                            color: AppColors.textPrimary,
                            onTap: () {},
                          ),
                        ],
                        heroTag: 'ImageSearchResult${image.id}',
                        builder: (_, Animation<double> animation, __) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (BuildContext context, Widget? child) {
                              return Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    12 * animation.value,
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: AppColors.strokePrimaryAlpha
                                          .withOpacity(0.25 * animation.value),
                                      blurRadius: 18,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: CustomImage(
                              height: MediaQuery.sizeOf(context).width / 3 - 1,
                              width: MediaQuery.sizeOf(context).width / 3 - 1,
                              attachment: image.image,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.paddingOf(context).bottom,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
