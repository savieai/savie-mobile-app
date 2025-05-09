import 'dart:io';

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
        padding: EdgeInsets.all(AppSpaces.space200),
        child: svgGenImage.svg(
          height: Platform.isMacOS ? 20 : 24,
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
