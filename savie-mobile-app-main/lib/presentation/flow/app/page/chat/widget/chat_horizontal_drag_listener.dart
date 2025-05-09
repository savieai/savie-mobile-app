import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cubit.dart';
import 'widget.dart';

class MessagesHorizontalDragListener extends StatefulWidget {
  const MessagesHorizontalDragListener({
    super.key,
    required this.child,
  });

  final MessageListView child;

  @override
  State<MessagesHorizontalDragListener> createState() =>
      _MessagesHorizontalDragListenerState();
}

class _MessagesHorizontalDragListenerState
    extends State<MessagesHorizontalDragListener>
    with TickerProviderStateMixin {
  final ChatHorizontalDragCubit _cubit = ChatHorizontalDragCubit();
  double _dragPosition = 0.0;
  double _displayedPosition = 0.0;
  final double _constantMultiplier = 120.0; // Adjust this value as needed
  bool _isHorizontalDrag = false; // To track if the drag is horizontal
  Offset? _initialPointerPosition; // Track the initial pointer position
  final double _verticalTolerance = 10.0; // Tolerance for vertical movement

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatHorizontalDragCubit>(
      create: (BuildContext context) => _cubit,
      child: Builder(
        builder: (BuildContext context) {
          return GestureDetector(
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: Listener(
              onPointerDown: _onPointerDown,
              onPointerUp: _onHorizontalDragEnd,
              onPointerMove: _onHorizontalDragUpdate,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }

  void _onPointerDown(PointerDownEvent details) {
    _initialPointerPosition = details.position;
    _isHorizontalDrag = false;
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _initialPointerPosition = details.globalPosition;
  }

  void _onHorizontalDragUpdate(PointerMoveEvent details) {
    if (_initialPointerPosition != null && !_isHorizontalDrag) {
      final double dx =
          (details.position.dx - _initialPointerPosition!.dx).abs();
      final double dy =
          (details.position.dy - _initialPointerPosition!.dy).abs();
      // Determine if the drag is horizontal with a vertical tolerance
      if (dx > dy && dy < _verticalTolerance) {
        _isHorizontalDrag = true;
      } else {
        return; // Ignore if not horizontal drag within the tolerance
      }
    }

    if (_isHorizontalDrag) {
      setState(() {
        _dragPosition += details.delta.dx;
        if (_dragPosition >= 0) {
          _dragPosition = 0;
          return;
        }

        _displayedPosition = _mapValue(_dragPosition);
        _cubit.updateOffset(
            _displayedPosition); // Update the Cubit with the new position
      });
    }
  }

  void _onHorizontalDragEnd(_) {
    if (_isHorizontalDrag) {
      final AnimationController animationController = AnimationController(
        vsync: this,
        value: -_dragPosition / _constantMultiplier,
      );

      animationController.addListener(() {
        _dragPosition = -animationController.value * _constantMultiplier;
        _displayedPosition =
            -_mapValue(animationController.value) * _constantMultiplier;
        _cubit.updateOffset(_displayedPosition);
        setState(() {});
      });

      animationController
          .animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.linearToEaseOut,
      )
          .then((_) {
        animationController.dispose();
      });
    }

    // Reset the horizontal drag flag and initial pointer position
    _isHorizontalDrag = false;
    _initialPointerPosition = null;
  }

  double _mapValue(double input) {
    final double normalizedInput = input / _constantMultiplier * 0.7;

    final double e1 = exp(normalizedInput);
    final double e2 = exp(-normalizedInput);
    return (e1 - e2) / (e1 + e2) * _constantMultiplier;
  }
}
