import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../../../application/application.dart';
import '../../../../../presentation.dart';

class CameraRollTopBar extends StatefulWidget implements PreferredSizeWidget {
  const CameraRollTopBar({super.key});

  @override
  State<CameraRollTopBar> createState() => _CameraRollTopBarState();

  @override
  Size get preferredSize => Size.fromHeight(CustomAppBar.preferredHeight);
}

class _CameraRollTopBarState extends State<CameraRollTopBar> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraRollCubit, CameraRollState>(
      builder: (BuildContext context, CameraRollState state) {
        return CustomAppBar(
          middle: _AlbumsOverlayButton(
            canTap: state.mapOrNull(fecthed: (CameraRollStateFetched fetched) {
                  return fetched.selectedPhotoIds.isEmpty;
                }) ??
                false,
            albums: state.mapOrNull(
              fecthed: (CameraRollStateFetched fetched) => fetched.albums,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  state.map(
                    loading: (_) => '...',
                    fecthed: (CameraRollStateFetched fetched) =>
                        fetched.selectedAlbum.name,
                  ),
                  style: AppTextStyles.headline,
                ),
                if (state.mapOrNull(fecthed: (_) => true) ?? false) ...<Widget>[
                  const SizedBox(width: 8),
                  Assets.icons.chevronDown16.svg(
                    colorFilter: const ColorFilter.mode(
                      AppColors.iconSecodary,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing: CustomIconButton(
            svgGenImage: Assets.icons.close24,
            onTap: () => context.router.maybePop(),
            color: AppColors.iconSecodary,
          ),
        );
      },
    );
  }
}

class _AlbumsOverlayButton extends StatefulWidget {
  const _AlbumsOverlayButton({
    required this.child,
    required this.albums,
    required this.canTap,
  });

  final Widget child;
  final List<AssetPathEntity>? albums;
  final bool canTap;

  @override
  State<_AlbumsOverlayButton> createState() => _AlbumsOverlayButtonState();
}

class _AlbumsOverlayButtonState extends State<_AlbumsOverlayButton>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _albumsOverlayEntry;
  late final AnimationController _albumsOverlayAnimationController;
  late final Animation<double> _albumsOverlayAnimation;

  @override
  void initState() {
    super.initState();
    _albumsOverlayAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _albumsOverlayAnimation = CurvedAnimation(
      parent: _albumsOverlayAnimationController,
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.canTap ? 1 : 0.6,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTap: widget.canTap
            ? () {
                getIt
                    .get<TrackUseActivityUseCase>()
                    .execute(AppEvents.mediaSelection.recentClicked);
                if (widget.albums != null) {
                  _showAlbumsOverlay(widget.albums!);
                }
              }
            : null,
        child: widget.child,
      ),
    );
  }

  void _showAlbumsOverlay(final List<AssetPathEntity> albums) {
    final OverlayState overlay = Overlay.of(context);

    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    final Offset posiiton = renderBox.localToGlobal(Offset.zero);
    const double width = 218;

    // Setting up the autofill
    _albumsOverlayEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _hideAlbumsOverlay,
              ),
            ),
            Positioned(
              width: width,
              left: posiiton.dx - (width - renderBox.size.width) / 2,
              top: posiiton.dy + renderBox.size.height + 4,
              child: FadeTransition(
                opacity: _albumsOverlayAnimation,
                child: ScaleTransition(
                  scale: _albumsOverlayAnimation,
                  alignment: Alignment.topCenter,
                  child: _AlbumsList(
                    mainContext: context,
                    albums: albums,
                    pop: _hideAlbumsOverlay,
                  ),
                ),
              ),
            )
          ],
        );
      },
    );

    _albumsOverlayAnimationController.forward();
    overlay.insert(_albumsOverlayEntry!);
  }

  void _hideAlbumsOverlay() {
    _albumsOverlayAnimationController.reverse().then((_) {
      _albumsOverlayEntry?.remove();
      _albumsOverlayEntry = null;
    });
  }
}

class _AlbumsList extends StatelessWidget {
  const _AlbumsList({
    required this.albums,
    required this.mainContext,
    required this.pop,
  });

  final List<AssetPathEntity> albums;
  final BuildContext mainContext;
  final VoidCallback pop;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 300,
        ),
        decoration: BoxDecoration(
          color: AppColors.systemMenuBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.strokeSecondaryAlpha),
          boxShadow: <BoxShadow>[
            BoxShadow(
              offset: const Offset(0, 6),
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
            ),
            BoxShadow(
              offset: const Offset(0, -4),
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
            ),
          ],
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: albums.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) => _AlbumItem(
            album: albums[index],
            onTap: () {
              mainContext.read<CameraRollCubit>().selectAlbum(albums[index]);
              pop();
            },
          ),
          separatorBuilder: (_, __) => Container(
            height: 1,
            color: AppColors.strokeSecondaryAlpha,
          ),
        ),
      ),
    );
  }
}

class _AlbumItem extends StatelessWidget {
  const _AlbumItem({
    required this.album,
    required this.onTap,
  });

  final AssetPathEntity album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                album.name,
                style: AppTextStyles.paragraph,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            FutureBuilder<Uint8List?>(
              future: album.getAssetListRange(start: 0, end: 1).then(
                    (List<AssetEntity> assets) =>
                        assets.firstOrNull?.thumbnailDataWithSize(
                      const ThumbnailSize.square(56),
                    ),
                  ),
              builder: (
                BuildContext context,
                AsyncSnapshot<Uint8List?> snapshot,
              ) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox();
                }

                return Container(
                  height: 20,
                  width: 20,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: AppColors.strokeSecondaryAlpha,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
