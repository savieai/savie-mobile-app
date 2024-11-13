import 'dart:io';

sealed class AppSpaces {
  static final double space0 = Platform.isMacOS ? 0 : 0;
  static final double space50 = Platform.isMacOS ? 2 : 2;
  static final double space100 = Platform.isMacOS ? 4 : 4;
  static final double space200 = Platform.isMacOS ? 6 : 8;
  static final double space300 = Platform.isMacOS ? 8 : 12;
  static final double space400 = Platform.isMacOS ? 12 : 16;
  static final double space500 = Platform.isMacOS ? 16 : 20;
  static final double space600 = Platform.isMacOS ? 20 : 24;
  static final double space700 = Platform.isMacOS ? 24 : 28;
  static final double space800 = Platform.isMacOS ? 28 : 32;
  static final double space900 = Platform.isMacOS ? 32 : 36;
  static final double space1000 = Platform.isMacOS ? 36 : 40;
  static final double space1500 = Platform.isMacOS ? 52 : 60;
  static final double space1600 = Platform.isMacOS ? 56 : 64;
}
