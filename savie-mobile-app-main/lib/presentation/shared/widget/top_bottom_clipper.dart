import 'package:flutter/widgets.dart';

class TopBottomClipper extends CustomClipper<Rect> {
  const TopBottomClipper(this.dyTop, this.dyBottom);

  final double? dyTop;
  final double? dyBottom;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      -20,
      dyTop ?? -20,
      size.width + 20,
      size.height - (dyBottom ?? -20),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}
