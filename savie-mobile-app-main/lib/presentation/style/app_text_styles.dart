import 'dart:io';

import 'package:flutter/material.dart';

import '../presentation.dart';

sealed class AppTextStyles {
  static const TextStyle title1 = TextStyle(
    fontFamily: FontFamily.newYorkLarge,
    fontWeight: FontWeight.w600,
    fontSize: 32,
    height: 40 / 32,
  );

  static TextStyle title2 = const TextStyle(
    fontFamily: FontFamily.newYorkLarge,
    fontWeight: FontWeight.w600,
  ).copyWith(
    fontSize: Platform.isMacOS ? 20 : 24,
    height: Platform.isMacOS ? 28 / 20 : 32 / 24,
  );

  static TextStyle paragraph = TextStyle(
    fontFamily: FontFamily.inter,
    fontWeight: Platform.isMacOS ? FontWeight.w400 : FontWeight.w500,
    letterSpacing: -0.4,
  ).copyWith(
    fontSize: Platform.isMacOS ? 14 : 17,
    height: Platform.isMacOS ? 18 / 14 : 22 / 17,
  );

  static const TextStyle footnote = TextStyle(
    fontFamily: FontFamily.inter,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.4,
    fontSize: 14,
    height: 20 / 14,
  );

  static final TextStyle caption = TextStyle(
    fontFamily: FontFamily.inter,
    fontWeight: Platform.isMacOS ? FontWeight.w400 : FontWeight.w500,
    letterSpacing: -0.4,
  ).copyWith(
    fontSize: Platform.isMacOS ? 14 : 13,
    height: Platform.isMacOS ? 14 / 11 : 16 / 13,
  );

  static final TextStyle callout = TextStyle(
    fontFamily: FontFamily.inter,
    fontWeight: Platform.isMacOS ? FontWeight.w400 : FontWeight.w500,
    letterSpacing: -0.4,
  ).copyWith(
    fontSize: Platform.isMacOS ? 12 : 14,
    height: Platform.isMacOS ? 16 / 12 : 18 / 14,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: FontFamily.inter,
    fontWeight: FontWeight.w500,
    fontSize: 18,
    height: 24 / 18,
    letterSpacing: -0.4,
  );

  static const TextStyle subheadMedium = TextStyle(
    fontFamily: FontFamily.inter,
    fontWeight: FontWeight.w500,
    fontSize: 18,
    height: 26 / 18,
    letterSpacing: -0.4,
  );

  static const TextStyle description = TextStyle(
    fontFamily: 'SF Mono',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 14 / 12,
    letterSpacing: -0.4,
  );
}
