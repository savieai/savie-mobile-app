import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../../domain/domain.dart';
import '../../../../presentation.dart';

@RoutePage()
class PhotoCarouselPage extends StatefulWidget {
  const PhotoCarouselPage({
    super.key,
    required this.images,
    required this.caption,
    required this.initialBorderRadius,
    required this.initialIndex,
    required this.heroTagPredicate,
  });

  final List<Attachment> images;
  final String? caption;
  final double initialBorderRadius;
  final int initialIndex;
  final String Function(Attachment image) heroTagPredicate;

  @override
  State<PhotoCarouselPage> createState() => _PhotoCarouselPageState();
}

class _PhotoCarouselPageState extends State<PhotoCarouselPage>
    with TickerProviderStateMixin {
  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex,
  );
  final ValueNotifier<double> _verticalOffsetNotifier =
      ValueNotifier<double>(0);
  final double _verticalOffsetThreshold = 100;
  late final ValueNotifier<int> _selectedIndexNotifier =
      ValueNotifier<int>(widget.initialIndex);

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    //TODO: think of metrics
    super.initState();
    // getIt.get<TrackUseActivityUseCase>().execute(
    //       AppEvents.photoView.screenOpened(
    //         messageId: widget.message.id,
    //         type: widget.message.appEventMessageType,
    //       ),
    //     );

    _pageController.addListener(() {
      final int newSelectedIndex = _pageController.page?.round() ?? 0;
      if (newSelectedIndex != _selectedIndexNotifier.value) {
        // if (newSelectedIndex > _selectedIndexNotifier.value) {
        //   getIt.get<TrackUseActivityUseCase>().execute(
        //         AppEvents.photoView.swipeRight(
        //           messageId: widget.message.id,
        //           type: widget.message.appEventMessageType,
        //         ),
        //       );
        // } else {
        //   getIt.get<TrackUseActivityUseCase>().execute(
        //         AppEvents.photoView.swipeLeft(
        //           messageId: widget.message.id,
        //           type: widget.message.appEventMessageType,
        //         ),
        //       );
        // }
        _selectedIndexNotifier.value = newSelectedIndex;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayEntry = OverlayEntry(
        builder: (BuildContext context) => _opacityView(
          (double opacity) => Align(
            alignment: Alignment.bottomCenter,
            child: ValueListenableBuilder<int>(
              valueListenable: _selectedIndexNotifier,
              builder:
                  (BuildContext context, int selectedIndex, Widget? child) {
                return Opacity(
                  opacity: opacity,
                  child: _BottomBar(
                    images: widget.images,
                    selectedIndex: selectedIndex,
                    caption: widget.caption,
                  ),
                );
              },
            ),
          ),
        ),
      );

      final OverlayState overlay = Overlay.of(context);
      overlay.insert(_overlayEntry!);
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: _opacityView(
            (double opacity) => Container(
              color: Colors.black.withValues(alpha: opacity),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (DragUpdateDetails details) {
            // Limit the rate of updates to prevent excessive rebuilds
            if (details.primaryDelta != null && details.primaryDelta!.abs() > 1) {
              _verticalOffsetNotifier.value -= details.primaryDelta!;
            }
          },
          onVerticalDragEnd: (DragEndDetails details) {
            if (_verticalOffsetNotifier.value.abs() > _verticalOffsetThreshold) {
              // If past threshold, dismiss the view immediately without additional animation
              context.router.maybePop();
            } else {
              try {
                // Simple, efficient animation to reset position
                final AnimationController animationController = AnimationController(
                  vsync: this,
                  duration: const Duration(milliseconds: 150), // Faster reset
                  value: 1,
                );

                final Animation<double> animation = CurvedAnimation(
                  parent: animationController,
                  curve: Curves.easeOut, // Smoother curve
                );

                final double currentVerticalOffset = _verticalOffsetNotifier.value;

                animation.addListener(() {
                  if (mounted) {
                    _verticalOffsetNotifier.value = currentVerticalOffset * animation.value;
                  }
                });
                
                // Make sure to dispose the controller
                animationController.reverse().then((_) {
                  animationController.dispose();
                });
              } catch (e) {
                // Reset the value directly if animation fails
                _verticalOffsetNotifier.value = 0;
              }
            }
          },
          child: ValueListenableBuilder<double>(
            valueListenable: _verticalOffsetNotifier,
            builder:
                (BuildContext context, double verticalOffset, Widget? child) {
              return Transform.translate(
                offset: Offset(0, -verticalOffset),
                child: Transform.scale(
                  scale: 1 +
                      (verticalOffset / _verticalOffsetThreshold).clamp(-2, 2) *
                          0.05,
                  child: child,
                ),
              );
            },
            child: ValueListenableBuilder<int>(
              valueListenable: _selectedIndexNotifier,
              builder: (BuildContext context, int selectedIndex, _) {
                return _Carousel(
                  images: widget.images,
                  pageController: _pageController,
                  selectedIndex: selectedIndex,
                  initialBorderRadius: widget.initialBorderRadius,
                  heroTagPredicate: widget.heroTagPredicate,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _opacityView(Widget Function(double opacity) builder) {
    final Animation<double> pageAnimation = ModalRoute.of(context)?.animation ??
        const AlwaysStoppedAnimation<double>(1);

    return ValueListenableBuilder<double>(
      valueListenable: _verticalOffsetNotifier,
      builder: (BuildContext context, double verticalOffset, _) {
        final double offsetRatio =
            ((_verticalOffsetThreshold - verticalOffset.abs() * 1.5) /
                    _verticalOffsetThreshold)
                .clamp(0, 1);

        return AnimatedBuilder(
          animation: pageAnimation,
          builder: (BuildContext context, Widget? child) {
            return builder(
              min(
                pageAnimation.value,
                offsetRatio,
              ),
            );
          },
        );
      },
    );
  }
}

class _Carousel extends StatefulWidget {
  const _Carousel({
    required this.images,
    required this.pageController,
    required this.selectedIndex,
    required this.initialBorderRadius,
    required this.heroTagPredicate,
  });

  final List<Attachment> images;
  final PageController pageController;
  final int selectedIndex;
  final double initialBorderRadius;
  final String Function(Attachment image) heroTagPredicate;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> with TickerProviderStateMixin {
  // Keep track of controllers to properly dispose them
  final List<PhotoViewController> _controllers = [];
  
  @override
  void dispose() {
    // Clean up all controllers when the widget is disposed
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhotoViewGallery.builder(
      backgroundDecoration: const BoxDecoration(),
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        // Create and track each controller
        final PhotoViewController photoViewController = PhotoViewController();
        _controllers.add(photoViewController);
        
        final Attachment attachment = widget.images[index];

        return PhotoViewGalleryPageOptions(
          controller: photoViewController,
          imageProvider: getCustomImageProvider(attachment),
          disableGestures: false, // Enable gestures for zooming
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 3,
          initialScale: PhotoViewComputedScale.contained,
          basePosition: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Error loading image',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          },
          heroAttributes: widget.selectedIndex == index
              ? PhotoViewHeroAttributes(
                  tag: widget.heroTagPredicate(attachment),
                  createRectTween: (Rect? begin, Rect? end) {
                    return RectTween(begin: begin, end: end);
                  },
                  flightShuttleBuilder: (
                    BuildContext flightContext,
                    Animation<double> animation,
                    HeroFlightDirection flightDirection,
                    BuildContext fromHeroContext,
                    BuildContext toHeroContext,
                  ) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (BuildContext context, Widget? child) {
                        return Opacity(
                          // TODO: fix [widget.initialBorderRadius == 0] workaround
                          opacity: index == 0 || widget.initialBorderRadius == 0
                              ? 1
                              : Curves.easeOutExpo.transform(animation.value),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              (1 - animation.value) *
                                  widget.initialBorderRadius,
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: CustomImage(
                        attachment: attachment,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                )
              : null,
        );
      },
      itemCount: widget.images.length,
      pageController: widget.pageController,
    );
  }
}

class _BottomBar extends StatefulWidget {
  const _BottomBar({
    required this.images,
    required this.caption,
    required this.selectedIndex,
  });

  final List<Attachment> images;
  final int selectedIndex;
  final String? caption;

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  late final List<GlobalKey> _keys = List<GlobalKey>.generate(
    widget.images.length,
    (_) => GlobalKey(),
  );

  void _scrollToSelectedIndex(int index) {
    Scrollable.ensureVisible(
      _keys[index].currentContext!,
      alignment: 0.5,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );
  }

  @override
  void didUpdateWidget(covariant _BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollToSelectedIndex(widget.selectedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 16),
          if (widget.caption?.isNotEmpty ?? false) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: _Caption(
                text: widget.caption!,
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return _ImagePreview(
                  key: _keys[index],
                  attachment: widget.images[index],
                  isSelected: widget.selectedIndex == index,
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemCount: widget.images.length,
            ),
          ),
          SizedBox(
            height: MediaQuery.paddingOf(context).bottom,
          )
        ],
      ),
    );
  }
}

class _ImagePreview extends StatefulWidget {
  const _ImagePreview({
    super.key,
    required this.attachment,
    required this.isSelected,
  });

  final Attachment attachment;
  final bool isSelected;

  @override
  State<_ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<_ImagePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: widget.isSelected ? 1 : 0,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeOut.flipped,
  );

  @override
  void didUpdateWidget(covariant _ImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool wasSelected = oldWidget.isSelected;
    final bool isSelected = widget.isSelected;

    if (wasSelected != isSelected) {
      if (isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, _) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: CustomImage(
            attachment: widget.attachment,
            height: 28 + _animation.value * 8,
            width: 28 + _animation.value * 8,
            filterQuality: FilterQuality.none,
            memCacheHeight: 100,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 75),
      child: SingleChildScrollView(
        child: Text(
          text,
          style: AppTextStyles.paragraph.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
