import 'dart:io';

sealed class AppCorners {
  static final double message = Platform.isMacOS ? 16 : 20;
  static final double radius200 = Platform.isMacOS ? 6 : 8;
  static final double space100 = Platform.isMacOS ? 16 : 20;
  static final double space200 = Platform.isMacOS ? 2 : 4;
}
