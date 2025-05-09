import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation.dart';

// TODO: refactor to a cubit

class DragAndDropWrapper extends StatefulWidget {
  const DragAndDropWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<DragAndDropWrapper> createState() => _DragAndDropWrapperState();
}

class _DragAndDropWrapperState extends State<DragAndDropWrapper> {
  final ValueNotifier<bool> _isDraggingNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isDraggingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(child: widget.child),
        ValueListenableBuilder<bool>(
          valueListenable: _isDraggingNotifier,
          builder: (BuildContext context, bool isDragging, _) {
            return ClipRect(
              child: _Blur(
                enabled: isDragging,
              ),
            );
          },
        ),
        Positioned.fill(
          child: _DropTarget(
            isDraggingNotifier: _isDraggingNotifier,
          ),
        ),
      ],
    );
  }
}

class _DropTarget extends StatefulWidget {
  const _DropTarget({
    required this.isDraggingNotifier,
  });

  final ValueNotifier<bool> isDraggingNotifier;

  @override
  State<_DropTarget> createState() => _DropTargetState();
}

class _DropTargetState extends State<_DropTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: widget.isDraggingNotifier.value ? 1 : 0,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _isImages = false;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Set<String> imageFormats = <String>{'png', 'jpeg', 'jpg', 'heic'};

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => DropTarget(
        onDragEntered: (DropEventDetails details) {
          final Set<String> formats = details.formats?.toSet() ?? <String>{};
          final bool isAllImages = formats.difference(imageFormats).isEmpty;

          setState(() {
            _isImages = isAllImages;
          });

          widget.isDraggingNotifier.value = true;
          _animationController.forward();
        },
        onDragUpdated: (DropEventDetails details) {
          final double yRatio =
              details.localPosition.dy / constraints.maxHeight;

          late final int newSelectedIndex;
          if (_isImages) {
            newSelectedIndex = yRatio < 0.5 ? 0 : 1;
          } else {
            newSelectedIndex = 0;
          }

          if (newSelectedIndex != _selectedIndex) {
            setState(() {
              _selectedIndex = newSelectedIndex;
            });
          }
        },
        onDragExited: (DropEventDetails event) async {
          widget.isDraggingNotifier.value = false;
          _animationController.reverse();
        },
        onDragDone: (DropDoneDetails details) {
          widget.isDraggingNotifier.value = false;
          _animationController.reverse();

          final bool sendAsImage = _isImages && _selectedIndex == 0;
          final List<String> paths =
              details.files.map((DropItem e) => e.path).toList();

          if (sendAsImage) {
            context.read<ChatCubit>().sendMessage(mediaPaths: paths);
          } else {
            paths.forEach(context.read<ChatCubit>().sendFile);
          }
        },
        child: SizedBox.expand(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (BuildContext context, Widget? child) {
              if (_animation.isDismissed) {
                return const SizedBox();
              }

              return Opacity(
                opacity: _animation.value,
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  if (_isImages) ...<Widget>[
                    Expanded(
                      child: _Placeholder(
                        isSelected: _isImages && _selectedIndex == 0,
                        svgGenImage: Assets.icons.imageUploadIcon,
                        label: 'image',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Expanded(
                    child: _Placeholder(
                      isSelected:
                          _isImages ? _selectedIndex == 1 : _selectedIndex == 0,
                      svgGenImage: Assets.icons.documentUploadIcon,
                      label: 'document',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Blur extends StatefulWidget {
  const _Blur({
    required this.enabled,
  });

  final bool enabled;

  @override
  State<_Blur> createState() => _BlurState();
}

class _BlurState extends State<_Blur> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: widget.enabled ? 1 : 0,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _Blur oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, _) {
        if (_animation.isDismissed) {
          return const SizedBox();
        }

        return Center(
          child: Opacity(
            opacity: _animation.value,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10 + _animation.value * 10,
                sigmaY: 10 + _animation.value * 10,
              ),
              child: Container(color: Colors.transparent),
            ),
          ),
        );
      },
    );
  }
}

class _Placeholder extends StatefulWidget {
  const _Placeholder({
    required this.svgGenImage,
    required this.label,
    required this.isSelected,
  });

  final SvgGenImage svgGenImage;
  final String label;
  final bool isSelected;

  @override
  State<_Placeholder> createState() => _PlaceholderState();
}

class _PlaceholderState extends State<_Placeholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: widget.isSelected ? 1 : 0,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _Placeholder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color grey = Color.alphaBlend(
      AppColors.strokePrimaryAlpha.withValues(alpha: 0.1),
      Colors.white,
    );

    final Color darkerGrey = Color.alphaBlend(
      AppColors.strokePrimaryAlpha.withValues(alpha: 0.1),
      Colors.white,
    );

    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return DottedBorder(
          radius: const Radius.circular(8),
          borderType: BorderType.RRect,
          color: Color.lerp(grey, darkerGrey, _animation.value)!,
          dashPattern: const <double>[6, 6],
          child: child ?? const SizedBox(),
        );
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            widget.svgGenImage.svg(
              colorFilter: const ColorFilter.mode(
                AppColors.iconAccent,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  const TextSpan(text: 'Drop files here to upload them as '),
                  TextSpan(
                    text: widget.label,
                    style: const TextStyle(color: AppColors.iconAccent),
                  ),
                ],
              ),
              style: AppTextStyles.callout,
            ),
          ],
        ),
      ),
    );
  }
}
