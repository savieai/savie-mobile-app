import 'package:flutter/material.dart';

import '../../presentation.dart';

final class ContextMenuItemData {
  const ContextMenuItemData({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final SvgGenImage icon;
  final Color color;
  final VoidCallback onTap;
}
