import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

GlobalKey<_ProgressHudChildState> _progressHudKey =
    GlobalKey<_ProgressHudChildState>();

class ProgressHud extends StatefulWidget {
  const ProgressHud({
    super.key,
    required this.child,
  });

  final Widget child;

  static bool get isShowing =>
      _progressHudKey.currentState?._isShowing ?? false;

  static void show() => _progressHudKey.currentState?._show();
  static void hide() => _progressHudKey.currentState?._hide();

  @override
  State<ProgressHud> createState() => _ProgressHudState();
}

class _ProgressHudState extends State<ProgressHud> {
  @override
  void initState() {
    _progressHudKey = GlobalKey<_ProgressHudChildState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _ProgressHudChild(
      key: _progressHudKey,
      child: widget.child,
    );
  }
}

class _ProgressHudChild extends StatefulWidget {
  const _ProgressHudChild({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<_ProgressHudChild> createState() => _ProgressHudChildState();
}

class _ProgressHudChildState extends State<_ProgressHudChild>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  bool _isShowing = false;

  void _show() {
    _isShowing = true;
    _controller.forward();
  }

  void _hide() {
    _isShowing = false;
    _controller.reverse();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linearToEaseOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child,
        AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, _) {
            return Visibility(
              visible: _animation.value != 0,
              child: Stack(
                children: <Widget>[
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 2.5 * _animation.value,
                      sigmaY: 2.5 * _animation.value,
                    ),
                    child: Container(
                      color: Colors.black
                          .withValues(alpha: 0.4 * _animation.value),
                    ),
                  ),
                  Opacity(
                    opacity: _animation.value,
                    child: const Center(
                      child: CupertinoActivityIndicator(
                        radius: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
