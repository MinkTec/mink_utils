import 'dart:io';

final class PlatformInfo {
  static bool get isGerman => locale.startsWith("de");

  static bool get isMobile => Platform.isIOS || Platform.isAndroid;

  static bool get isDesktop => !isMobile;

  static String get locale => Platform.localeName;

  static String get pathSeperator => Platform.pathSeparator;
}
