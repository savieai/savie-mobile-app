import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../presentation.dart';
import 'widget.dart';

class CameraRollPhotos extends StatelessWidget {
  const CameraRollPhotos({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraRollCubit, CameraRollState>(
      buildWhen: (CameraRollState previous, CameraRollState current) {
        List<CameraRollPhoto> getPhotos(CameraRollState state) => state.map(
              loading: (_) => <CameraRollPhoto>[],
              fecthed: (CameraRollStateFetched fetched) =>
                  fetched.photos ?? <CameraRollPhoto>[],
            );

        return !const ListEquality<CameraRollPhoto>()
            .equals(getPhotos(previous), getPhotos(current));
      },
      builder: (BuildContext context, CameraRollState state) {
        return state.map(
          loading: (_) => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          fecthed: (CameraRollStateFetched fetched) {
            if (fetched.photos == null) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            return _CameraRollPhotoList(
              key: ValueKey<String>(fetched.selectedAlbum.id),
              photos: fetched.photos!,
              displayCamera: fetched.selectedAlbum.isAll,
            );
          },
        );
      },
    );
  }
}

class _CameraRollPhotoList extends StatefulWidget {
  const _CameraRollPhotoList({
    super.key,
    required this.photos,
    required this.displayCamera,
  });

  final List<CameraRollPhoto> photos;
  final bool displayCamera;

  @override
  State<_CameraRollPhotoList> createState() => _CameraRollPhotoListState();
}

class _CameraRollPhotoListState extends State<_CameraRollPhotoList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreData);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreData() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent -
            MediaQuery.sizeOf(context).height) {
      context.read<CameraRollCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final int indexOffset = widget.displayCamera ? 1 : 0;

    return GridView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: widget.photos.length + indexOffset,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0 && widget.displayCamera) {
          return const CameraRollCameraPreview();
        }

        final CameraRollPhoto photo = widget.photos[index - indexOffset];

        return _CameraRollPhotoItem(
          key: ValueKey<String>(photo.assetEntity.id),
          photo: photo,
        );
      },
    );
  }
}

class _CameraRollPhotoItem extends StatelessWidget {
  const _CameraRollPhotoItem({
    super.key,
    required this.photo,
  });

  final CameraRollPhoto photo;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CameraRollCubit, CameraRollState, bool>(
      selector: (CameraRollState state) {
        return state.mapOrNull(fecthed: (CameraRollStateFetched fetched) {
              return fetched.selectedPhotoIds.contains(photo.assetEntity.id);
            }) ??
            false;
      },
      builder: (BuildContext context, bool isSelected) {
        return Stack(
          alignment: Alignment.topRight,
          children: <Widget>[
            if (photo.thumbnailData == null)
              Positioned.fill(
                child: Container(
                  color: AppColors.strokePrimaryAlpha,
                ),
              )
            else
              Positioned.fill(
                child: Image(
                  image: MemoryImage(photo.thumbnailData!),
                  gaplessPlayback: true,
                  fit: BoxFit.cover,
                  frameBuilder: (_, Widget child, int? frame, __) {
                    return AnimatedCrossFade(
                      firstChild: child,
                      secondChild: Container(
                        color: AppColors.strokePrimaryAlpha,
                      ),
                      crossFadeState: frame != null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 150),
                      layoutBuilder:
                          (Widget topChild, _, Widget bottomChild, ___) {
                        return Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            topChild,
                            bottomChild,
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            _SelectionIndicator(
              isSelected: isSelected,
              onTap: () => context
                  .read<CameraRollCubit>()
                  .togglePhotoId(photo.assetEntity.id),
            ),
          ],
        );
      },
    );
  }
}

class _SelectionIndicator extends StatefulWidget {
  const _SelectionIndicator({
    required this.onTap,
    required this.isSelected,
  });

  final VoidCallback onTap;
  final bool isSelected;

  @override
  State<_SelectionIndicator> createState() => _SelectionIndicatorState();
}

class _SelectionIndicatorState extends State<_SelectionIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _toggleAnimationController;
  late final Animation<double> _toggleAnimaion;

  @override
  void initState() {
    super.initState();

    _toggleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _toggleAnimaion = CurvedAnimation(
      parent: _toggleAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant _SelectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isSelected != widget.isSelected) {
      _toggleAnimationController.stop();
      _toggleAnimationController.forward().then((_) {
        _toggleAnimationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _toggleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _toggleAnimaion,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: 1 - _toggleAnimaion.value * 0.2,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            child: (widget.isSelected
                    ? Assets.icons.selected24
                    : Assets.icons.unselected24)
                .svg(
              key: ValueKey<bool>(widget.isSelected),
              colorFilter: const ColorFilter.mode(
                AppColors.iconInvert,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
