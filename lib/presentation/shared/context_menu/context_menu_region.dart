import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../flow/app/page/chat/cubit/cubit.dart';
import '../../presentation.dart';

class ContextMenuRegion extends StatefulWidget {
  const ContextMenuRegion({
    super.key,
    required this.data,
    required this.heroTag,
    required this.builder,
  });

  final List<ContextMenuItemData> data;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    bool contextMenuShown,
  ) builder;
  final String heroTag;

  @override
  State<ContextMenuRegion> createState() => _ContextMenuRegionState();
}

class _ContextMenuRegionState extends State<ContextMenuRegion>
    with TickerProviderStateMixin {
  final GlobalKey _childKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  late final AnimationController _overlayAnimationController;
  late final Animation<double> _overlayAnimation;

  late final ValueNotifier<double> _childBottomDyNotifier =
      ValueNotifier<double>(0);

  late final AnimationController _longPressAnimationController;
  late final Animation<double> _longPressAnimation;

  final ValueNotifier<bool> _contextMenuShownNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<double> _scrollPositionNotifier =
      ValueNotifier<double>(0);
  ScrollController? _scrollController;
  late final ContextMenuCubit _contextMenuCubit;

  final double horizontalPadding = Platform.isMacOS ? 24 : 16;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        _sizeNotifier.value = context.size;
      }
    });
  }

  @override
  void didUpdateWidget(covariant ContextMenuRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        _sizeNotifier.value = context.size;
      }
    });
  }

  final ValueNotifier<Size?> _sizeNotifier = ValueNotifier<Size?>(null);

  @override
  void initState() {
    super.initState();

    _contextMenuCubit = context.read<ContextMenuCubit>();
    _overlayAnimationController =
        ContextMenuScope.of(context)!.overlayAnimationController;
    _overlayAnimation = ContextMenuScope.of(context)!.overlayAnimation;

    _longPressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _longPressAnimation = CurvedAnimation(
      parent: _longPressAnimationController,
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.easeOut.flipped,
    );
  }

  void _showOverlay() {
    try {
      _sizeNotifier.value = context.size;
    } catch (_) {
      // ignore, really
    }

    context.read<ContextMenuCubit>().setShown();
    _contextMenuShownNotifier.value = true;

    HapticFeedback.lightImpact();

    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    Offset posiiton = renderBox.localToGlobal(Offset.zero);

    final Offset contextMenuVisiblePosition =
        HeroVisibleArea.positionOf(context);

    final double minOffsetDy = contextMenuVisiblePosition.dy;
    final double maxOffset = MediaQuery.sizeOf(context).height -
        widget.data.length * 40 -
        renderBox.size.height -
        30;

    if (posiiton.dy < minOffsetDy) {
      posiiton = posiiton.translate(0, minOffsetDy - posiiton.dy);
    }

    if (posiiton.dy > maxOffset) {
      posiiton = posiiton.translate(
        0,
        maxOffset - posiiton.dy - 30,
      );
    }

    const double width = 218;

    _childBottomDyNotifier.value = renderBox.size.height + posiiton.dy;

    final double childWidth = renderBox.size.width;
    final bool shouldAttachToRight =
        MediaQuery.sizeOf(context).width - posiiton.dx < childWidth ||
            posiiton.dx + width >= MediaQuery.sizeOf(context).width;

    final double screenHeight = MediaQuery.sizeOf(context).height;

    _scrollPositionNotifier.value = 0;
    _scrollController = ScrollController()
      ..addListener(() {
        _scrollPositionNotifier.value = _scrollController?.offset ?? 0;
      });

    bool canPop = false;

    Navigator.push(
      context,
      PageRouteBuilder<dynamic>(
        fullscreenDialog: true,
        opaque: false,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (BuildContext context, Animation<double> animation, ___) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return PopScope(
                canPop: canPop,
                onPopInvokedWithResult: (bool didPop, dynamic result) {
                  if (!didPop) {
                    setState(() => canPop = true);
                    _hideOverlay();
                  }
                },
                child: Material(
                  type: MaterialType.transparency,
                  child: Stack(
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: animation,
                        builder: (BuildContext _, Widget? child) {
                          return Opacity(
                            opacity: animation.value,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 15 + 15 * animation.value,
                                sigmaY: 15 + 15 * animation.value,
                                tileMode: TileMode.repeated,
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                      Positioned.fill(
                        child: TapRegion(
                          onTapInside: (PointerDownEvent event) {
                            final RenderBox renderBox =
                                _childKey.currentContext!.findRenderObject()!
                                    as RenderBox;
                            final Size size = renderBox.size;
                            final Offset offset =
                                renderBox.localToGlobal(Offset.zero);
                            final Offset tapPosition = event.position;

                            final Offset delta = tapPosition - offset;

                            final bool hit = delta.dx >= 0 &&
                                delta.dx <= size.width &&
                                delta.dy >= 0 &&
                                delta.dy <= size.height;

                            if (hit) {
                              // TODO: on hit
                            } else {
                              _hideOverlay();
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox(),
                        ),
                      ),
                      Positioned(
                        left: (posiiton.dx < horizontalPadding
                                ? horizontalPadding
                                : (MediaQuery.sizeOf(context).width -
                                            (posiiton.dx +
                                                renderBox.size.width)) <
                                        horizontalPadding
                                    ? posiiton.dx - horizontalPadding
                                    : posiiton.dx) -
                            20,
                        width: renderBox.size.width + 40,
                        child: SizedBox(
                          height: screenHeight,
                          child: ScrollbarTheme(
                            data: const ScrollbarThemeData(
                              thickness: WidgetStatePropertyAll<double>(0),
                            ),
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              reverse: true,
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _hideOverlay,
                                    child: SizedBox(
                                      height: minOffsetDy,
                                      width: double.infinity,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Hero(
                                      key: _childKey,
                                      tag: widget.heroTag,
                                      flightShuttleBuilder:
                                          flightShuttleBuilder,
                                      child: unconstrainedChild,
                                    ),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _hideOverlay,
                                    child: SizedBox(
                                      height: screenHeight -
                                          posiiton.dy -
                                          renderBox.size.height,
                                      width: double.infinity,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );

    // Setting up the autofill
    _overlayEntry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: <Widget>[
              ValueListenableBuilder<double>(
                valueListenable: _scrollPositionNotifier,
                builder: (BuildContext context, double value, _) {
                  return ValueListenableBuilder<double>(
                    valueListenable: _childBottomDyNotifier,
                    builder: (BuildContext context, double value, _) {
                      return Positioned(
                        width: width,
                        right: shouldAttachToRight ? horizontalPadding : null,
                        left: shouldAttachToRight
                            ? null
                            : max(horizontalPadding, posiiton.dx),
                        top: value + 4 + _scrollPositionNotifier.value,
                        child: FadeTransition(
                          opacity: _overlayAnimation,
                          child: ScaleTransition(
                            scale: _overlayAnimation,
                            alignment: shouldAttachToRight
                                ? Alignment(
                                    1 - renderBox.size.width / 2 / width, -1)
                                : Alignment.topCenter,
                            child: _ContextMenuListView(
                              mainContext: context,
                              data: widget.data,
                              pop: _hideOverlay,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            ],
          ),
        );
      },
    );

    final OverlayState overlay = Overlay.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      overlay.insert(_overlayEntry!);
    });

    Future<void>.delayed(const Duration(milliseconds: 50), () {
      _overlayAnimationController.forward();
    });
  }

  void _hideOverlay() {
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      _contextMenuCubit.setNotShown();
      _contextMenuShownNotifier.value = false;
      _scrollController?.dispose();
    });

    Navigator.of(context).pop();
    _overlayAnimationController.reverse().then((_) {
      if (_overlayEntry?.mounted ?? false) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  Widget get constrainedChild => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _sizeNotifier.value?.width ?? 0,
        ),
        child: unconstrainedChild,
      );

  Widget get unconstrainedChild => Material(
        type: MaterialType.transparency,
        child: ValueListenableBuilder<Size?>(
          valueListenable: _sizeNotifier,
          builder: (BuildContext context, Size? size, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: _contextMenuShownNotifier,
              builder: (BuildContext context, bool isShown, _) {
                return AnimatedBuilder(
                  animation: _longPressAnimation,
                  builder: (BuildContext context, Widget? child) {
                    final double scale = size == null
                        ? 1
                        : ((size.longestSide + 50) -
                                16 * _longPressAnimation.value) /
                            (size.longestSide + 50);

                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: widget.builder(
                    context,
                    _overlayAnimation,
                    _contextMenuShownNotifier.value,
                  ),
                );
              },
            );
          },
        ),
      );

  bool _pressedDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTap: Platform.isMacOS ? _showOverlay : null,
      onLongPressDown: Platform.isMacOS
          ? null
          : (_) {
              late final ChatHorizontalDragCubit? cubit;
              try {
                cubit = context.read<ChatHorizontalDragCubit>();
              } catch (_) {
                cubit = null;
              }

              _pressedDown = true;
              Future<void>.delayed(const Duration(milliseconds: 200), () {
                if (cubit != null && cubit.state != 0) {
                  _pressedDown = false;
                  return;
                }

                if (_pressedDown) {
                  _longPressAnimationController.forward().then((_) {
                    _longPressAnimationController.reverse();
                    _pressedDown = false;

                    if (cubit != null && cubit.state != 0) {
                      return;
                    }

                    _showOverlay();
                  });
                }
              });
            },
      onLongPressCancel: Platform.isMacOS
          ? null
          : () {
              if (_pressedDown) {
                _pressedDown = false;
                _longPressAnimationController.reverse();
              }
            },
      onLongPressEnd: Platform.isMacOS
          ? null
          : (_) {
              if (_pressedDown) {
                _pressedDown = false;
                _longPressAnimationController.reverse();
              }
            },
      child: ValueListenableBuilder<bool>(
        valueListenable: _contextMenuShownNotifier,
        builder: (BuildContext context, bool value, _) {
          return value
              ? Hero(
                  tag: widget.heroTag,
                  flightShuttleBuilder: flightShuttleBuilder,
                  child: unconstrainedChild,
                )
              : unconstrainedChild;
        },
      ),
    );
  }

  Widget flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final BuildContext pageContext = flightDirection == HeroFlightDirection.push
        ? fromHeroContext
        : toHeroContext;

    animation.addListener(() {
      if (!flightContext.mounted) {
        return;
      }

      final RenderBox? flightRenderBox =
          flightContext.findRenderObject() as RenderBox?;

      if (flightRenderBox != null) {
        final double bottom = flightRenderBox.size.height +
            flightRenderBox.localToGlobal(Offset.zero).dy;
        _childBottomDyNotifier.value = bottom;
      }
    });

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, __) {
        final Size contextMenuVisibleSize = HeroVisibleArea.sizeOf(pageContext);
        final Offset contextMenuVisiblePosition =
            HeroVisibleArea.positionOf(pageContext);

        final RenderBox? renderBox =
            flightContext.findRenderObject() as RenderBox? ??
                fromHeroContext.findRenderObject() as RenderBox?;

        if (renderBox != null) {
          final Offset offset = renderBox.localToGlobal(Offset.zero);

          final double top = offset.dy;
          final double maxTop = contextMenuVisiblePosition.dy;

          final double bottom = offset.dy + renderBox.size.height;
          final double maxBottom = maxTop + contextMenuVisibleSize.height;

          final Widget unconstrainedChild = OverflowBox(
            maxWidth: renderBox.size.width + 44,
            maxHeight: renderBox.size.height + 44,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: constrainedChild,
            ),
          );

          final double dyTop = maxTop - top;
          final double dyBottom = bottom - maxBottom;

          return ClipRect(
            clipper: TopBottomClipper(
              dyTop > 0 ? dyTop * (1 - animation.value) : null,
              dyBottom > 0 ? dyBottom * (1 - animation.value) : null,
            ),
            child: unconstrainedChild,
          );
        }

        return constrainedChild;
      },
    );
  }
}

class _ContextMenuListView extends StatelessWidget {
  const _ContextMenuListView({
    required this.mainContext,
    required this.data,
    required this.pop,
  });

  final BuildContext mainContext;
  final List<ContextMenuItemData> data;
  final VoidCallback pop;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        clipBehavior: Clip.hardEdge,
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
          itemCount: data.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) => _ContextMenuItem(
            data: data[index],
            onTap: () {
              data[index].onTap();
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

class _ContextMenuItem extends StatefulWidget {
  const _ContextMenuItem({
    required this.data,
    required this.onTap,
  });

  final ContextMenuItemData data;
  final VoidCallback onTap;

  @override
  State<_ContextMenuItem> createState() => _ContextMenuItemState();
}

class _ContextMenuItemState extends State<_ContextMenuItem> {
  bool _isPointerDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onPanDown: (_) => setState(() {
        _isPointerDown = true;
      }),
      onPanEnd: (_) => setState(() {
        _isPointerDown = false;
      }),
      onLongPress: () => setState(() {
        _isPointerDown = true;
      }),
      onLongPressEnd: (_) => setState(() {
        _isPointerDown = false;
      }),
      onPanCancel: () => setState(() {
        _isPointerDown = false;
      }),
      child: Container(
        height: 40,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
        color: _isPointerDown ? AppColors.strokePrimaryAlpha : null,
        child: Row(
          children: <Widget>[
            widget.data.icon.svg(
              colorFilter: ColorFilter.mode(
                widget.data.color,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.data.title,
                style: AppTextStyles.paragraph.copyWith(
                  color: widget.data.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
