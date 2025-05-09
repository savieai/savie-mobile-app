import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import '../../../../../router/app_router.gr.dart';
import '../cubit/search_cubit.dart';
import 'images_scrollbar.dart';
import 'widget.dart';

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
              return const Center(
                child: NoResultsPlaceholder(),
              );
            }

            final List<ImageSearchResult> images =
                data.cast<ImageSearchResult>();

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
                    itemBuilder: (BuildContext context, int index) {
                      final ImageSearchResult image = images[index];
                      return ContextMenuRegion(
                        data: <ContextMenuItemData>[
                          ContextMenuItemData(
                            title: 'Show in chat',
                            icon: Assets.icons.messageCircle16,
                            color: AppColors.textPrimary,
                            onTap: () {
                              context
                                  .read<ChatCubit>()
                                  .findMessage(image.messageId);

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                context.router.maybePop();
                              });
                            },
                          ),
                        ],
                        heroTag: '${image.hashCode}',
                        builder: (
                          _,
                          Animation<double> animation,
                          bool contextMenuShown,
                        ) {
                          final Widget imageView = GestureDetector(
                            onTap: contextMenuShown
                                ? null
                                : () {
                                    context.router.push(
                                      PhotoCarouselRoute(
                                        images: images
                                            .map((ImageSearchResult i) =>
                                                i.image)
                                            .toList(),
                                        caption: null,
                                        initialBorderRadius: 0,
                                        initialIndex: index,
                                        heroTagPredicate: (Attachment image) =>
                                            '${image.name}_search',
                                      ),
                                    );
                                  },
                            child: CustomImage(
                              height: MediaQuery.sizeOf(context).width / 3 - 1,
                              width: MediaQuery.sizeOf(context).width / 3 - 1,
                              attachment: image.image,
                              fit: BoxFit.cover,
                            ),
                          );

                          if (!contextMenuShown) {
                            return Hero(
                              tag: '${image.image.name}_search',
                              child: imageView,
                            );
                          }

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
                                          .withValues(
                                        alpha: 0.25 * animation.value,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: imageView,
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
