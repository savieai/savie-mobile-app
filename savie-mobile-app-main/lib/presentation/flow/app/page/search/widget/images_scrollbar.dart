import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../style/style.dart';

class ImagesScrollbar extends StatefulWidget {
  const ImagesScrollbar({
    super.key,
    required this.heightScrollThumb,
    required this.controller,
    required this.child,
  });

  final double heightScrollThumb;
  final Widget child;
  final ScrollController controller;

  @override
  State<ImagesScrollbar> createState() => _ImagesScrollbarState();
}

class _ImagesScrollbarState extends State<ImagesScrollbar> {
  double _barOffset = 0;
  double _viewOffset = 0;
  bool _isDragInProcess = false;

  double get barMaxScrollExtent =>
      (context.size?.height ?? 0) - widget.heightScrollThumb;
  double get barMinScrollExtent => 0.0;

  double get viewMaxScrollExtent => widget.controller.position.maxScrollExtent;
  double get viewMinScrollExtent => widget.controller.position.minScrollExtent;

  double getScrollViewDelta(
    double barDelta,
    double barMaxScrollExtent,
    double viewMaxScrollExtent,
  ) {
    return barDelta * viewMaxScrollExtent / barMaxScrollExtent;
  }

  double getBarDelta(
    double scrollViewDelta,
    double barMaxScrollExtent,
    double viewMaxScrollExtent,
  ) {
    return scrollViewDelta * barMaxScrollExtent / viewMaxScrollExtent;
  }

  void _onVerticalDragStart(DragDownDetails details) {
    setState(() {
      _isDragInProcess = true;
    });
  }

  void _onVerticalDragEnd() {
    setState(() {
      _isDragInProcess = false;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _barOffset += details.delta.dy;

      if (_barOffset < barMinScrollExtent) {
        _barOffset = barMinScrollExtent;
      }
      if (_barOffset > barMaxScrollExtent) {
        _barOffset = barMaxScrollExtent;
      }

      final double viewDelta = getScrollViewDelta(
          details.delta.dy, barMaxScrollExtent, viewMaxScrollExtent);

      _viewOffset = widget.controller.position.pixels + viewDelta;
      if (_viewOffset < widget.controller.position.minScrollExtent) {
        _viewOffset = widget.controller.position.minScrollExtent;
      }
      if (_viewOffset > viewMaxScrollExtent) {
        _viewOffset = viewMaxScrollExtent;
      }
      widget.controller.jumpTo(_viewOffset);
    });
  }

  void changePosition(ScrollNotification notification) {
    //if notification was fired when user drags we don't need to update scrollThumb position
    if (_isDragInProcess) {
      return;
    }

    if (widget.controller.position.pixels < viewMinScrollExtent ||
        widget.controller.position.pixels > viewMaxScrollExtent) {
      return;
    }

    setState(() {
      if (notification is ScrollUpdateNotification) {
        _barOffset += getBarDelta(
          notification.scrollDelta ?? 0,
          barMaxScrollExtent,
          viewMaxScrollExtent,
        );

        if (_barOffset < barMinScrollExtent) {
          _barOffset = barMinScrollExtent;
        }
        if (_barOffset > barMaxScrollExtent) {
          _barOffset = barMaxScrollExtent;
        }

        _viewOffset += notification.scrollDelta ?? 0;
        if (_viewOffset < widget.controller.position.minScrollExtent) {
          _viewOffset = widget.controller.position.minScrollExtent;
        }
        if (_viewOffset > viewMaxScrollExtent) {
          _viewOffset = viewMaxScrollExtent;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        changePosition(notification);
        return true;
      },
      child: Stack(
        children: <Widget>[
          widget.child,
          Positioned(
            top: _barOffset,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragDown: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: (_) => _onVerticalDragEnd(),
              onVerticalDragCancel: _onVerticalDragEnd,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linearToEaseOut,
                  padding: EdgeInsets.only(right: _isDragInProcess ? 80 : 0),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 100),
                    alignment: Alignment.centerRight,
                    scale: _isDragInProcess ? 1.2 : 1,
                    child: _buildScrollThumb(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollThumb() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Stack(
        children: <Widget>[
          Positioned(
            width: 100,
            height: 100,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ),
                child: Container(
                  color: AppColors.strokePrimaryAlpha.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
          // Completely removed the container with the "June 14" text
          // Container(
          //   padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          //   child: Text(
          //     'June 14',
          //     style: AppTextStyles.caption.copyWith(
          //       color: AppColors.textInvert,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
