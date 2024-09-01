import 'package:flutter/material.dart';

class ContextMenuScope extends StatefulWidget {
  const ContextMenuScope({
    super.key,
    required this.child,
  });

  final Widget child;

  static ContextMenuScopeState? of(BuildContext context) {
    return context.findAncestorStateOfType<ContextMenuScopeState>();
  }

  @override
  ContextMenuScopeState createState() => ContextMenuScopeState();
}

class ContextMenuScopeState extends State<ContextMenuScope>
    with TickerProviderStateMixin {
  late final AnimationController overlayAnimationController;
  late final Animation<double> overlayAnimation;

  @override
  void initState() {
    super.initState();
    overlayAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    overlayAnimation = CurvedAnimation(
      parent: overlayAnimationController,
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    overlayAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
