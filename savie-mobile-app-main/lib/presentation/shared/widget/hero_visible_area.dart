import 'package:flutter/widgets.dart';

import '../../presentation.dart';

class HeroVisibleArea extends StatefulWidget {
  const HeroVisibleArea({
    super.key,
    required this.child,
  });

  final Widget child;

  static Size sizeOf(BuildContext context) {
    final _HeroVisibleAreaState state =
        context.findAncestorStateOfType<_HeroVisibleAreaState>()!;
    return state._size;
  }

  static Offset positionOf(BuildContext context) {
    final _HeroVisibleAreaState state =
        context.findAncestorStateOfType<_HeroVisibleAreaState>()!;
    return state._position;
  }

  @override
  State<HeroVisibleArea> createState() => _HeroVisibleAreaState();
}

class _HeroVisibleAreaState extends State<HeroVisibleArea> {
  Size _size = Size.zero;
  Offset _position = Offset.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSizeAndPosition();
    });
  }

  void _updateSizeAndPosition() {
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    final Size newSize = renderBox.size;
    final Offset newPosition = renderBox.localToGlobal(Offset.zero);

    if (_size != newSize || _position != newPosition) {
      setState(() {
        _size = newSize;
        _position = newPosition;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutListener(
      onConstraintsChanged: (_) => _updateSizeAndPosition(),
      child: widget.child,
    );
  }
}
