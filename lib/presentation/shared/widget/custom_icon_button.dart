import 'package:flutter/material.dart';

import '../../presentation.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.svgGenImage,
    required this.onTap,
    this.color,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  final SvgGenImage svgGenImage;
  final Color? color;
  final VoidCallback? onTap;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressEndDetails)? onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: svgGenImage.svg(
          colorFilter: color == null
              ? null
              : ColorFilter.mode(
                  color!,
                  BlendMode.srcIn,
                ),
        ),
      ),
    );
  }
}
