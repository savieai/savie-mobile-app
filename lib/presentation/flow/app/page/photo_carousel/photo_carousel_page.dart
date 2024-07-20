import 'dart:io';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../../domain/model/message/message.dart';
import '../../../../presentation.dart';

@RoutePage()
class PhotoCarouselPage extends StatefulWidget {
  const PhotoCarouselPage({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  State<PhotoCarouselPage> createState() => _PhotoCarouselPageState();
}

class _PhotoCarouselPageState extends State<PhotoCarouselPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ValueNotifier<double> _verticalOffsetNotifier =
      ValueNotifier<double>(0);
  final double _verticalOffsetThreshold = 100;
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final int newSelectedIndex = _pageController.page?.round() ?? 0;
      if (newSelectedIndex != _selectedIndexNotifier.value) {
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
                    message: widget.message,
                    selectedIndex: selectedIndex,
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
              color: Colors.black.withOpacity(opacity),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (DragUpdateDetails details) {
            _verticalOffsetNotifier.value -= details.delta.dy;
          },
          onVerticalDragEnd: (_) {
            if (_verticalOffsetNotifier.value.abs() >
                _verticalOffsetThreshold) {
              context.router.maybePop();
            } else {
              final AnimationController animationController =
                  AnimationController(
                vsync: this,
                duration: const Duration(milliseconds: 200),
                value: 1,
              );

              final Animation<double> animation = CurvedAnimation(
                parent: animationController,
                curve: Curves.easeIn,
              );

              final double currentVerticalOffset =
                  _verticalOffsetNotifier.value;

              animation.addListener(() {
                _verticalOffsetNotifier.value =
                    currentVerticalOffset * animation.value;
              });
              animationController.reverse();
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
                  message: widget.message,
                  pageController: _pageController,
                  selectedIndex: selectedIndex,
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
    required this.message,
    required this.pageController,
    required this.selectedIndex,
  });

  final Message message;
  final PageController pageController;
  final int selectedIndex;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return PhotoViewGallery.builder(
      backgroundDecoration: const BoxDecoration(),
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        final PhotoViewController photoViewController = PhotoViewController();
        final String path = widget.message.mediaPaths[index];

        return PhotoViewGalleryPageOptions(
          controller: photoViewController,
          imageProvider: FileImage(File(path)),
          disableGestures: true,
          heroAttributes: widget.selectedIndex == index
              ? PhotoViewHeroAttributes(
                  tag: path + widget.message.id,
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
                          opacity: index == 0
                              ? 1
                              : Curves.easeOutExpo.transform(animation.value),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              (1 - animation.value) * 20,
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: Image.file(
                        File(path),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                )
              : null,
        );
      },
      itemCount: widget.message.mediaPaths.length,
      pageController: widget.pageController,
    );
  }
}

class _BottomBar extends StatefulWidget {
  const _BottomBar({
    required this.message,
    required this.selectedIndex,
  });

  final Message message;
  final int selectedIndex;

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  late final List<GlobalKey> _keys = List<GlobalKey>.generate(
    widget.message.mediaPaths.length,
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
      color: Colors.black.withOpacity(0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 16),
          if (widget.message.text?.isNotEmpty ?? false) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: _Caption(
                text: widget.message.text!,
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
                  path: widget.message.mediaPaths[index],
                  isSelected: widget.selectedIndex == index,
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemCount: widget.message.mediaPaths.length,
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
    required this.path,
    required this.isSelected,
  });

  final String path;
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
          child: Image.file(
            File(widget.path),
            height: 28 + _animation.value * 8,
            width: 28 + _animation.value * 8,
            filterQuality: FilterQuality.none,
            cacheHeight: 100,
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
