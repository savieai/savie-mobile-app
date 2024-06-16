import 'package:flutter/material.dart';

import '../presentation.dart';

sealed class AppTextStyles {
  static const TextStyle title2 = TextStyle(
    fontFamily: FontFamily.newYorkLarge,
    fontWeight: FontWeight.w500,
    fontSize: 26,
    height: 32 / 26,
  );

  static const TextStyle paragraph = TextStyle(
    fontFamily: FontFamily.inter,
    fontWeight: FontWeight.w500,
    fontSize: 17,
    height: 22 / 17,
    letterSpacing: -0.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: FontFamily.inter,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 16 / 13,
    letterSpacing: -0.4,
  );

  static const TextStyle callout = TextStyle(
    fontFamily: FontFamily.inter,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 18 / 14,
    letterSpacing: -0.4,
  );
}
