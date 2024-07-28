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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatHorizontalDragCubit>(
      create: (BuildContext context) => _cubit,
      child: Builder(
        builder: (BuildContext context) {
          return GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: widget.child,
          );
        },
      ),
    );
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
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

  void _onHorizontalDragEnd(_) {
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

  double _mapValue(double input) {
    final double normalizedInput = input / _constantMultiplier * 0.7;

    final double e1 = exp(normalizedInput);
    final double e2 = exp(-normalizedInput);
    return (e1 - e2) / (e1 + e2) * _constantMultiplier;
  }
}
