
import 'dart:io';

final class PlatformInfo {
  static bool get isGerman => Platform.localeName.startsWith("de");

  static bool get isMobile => Platform.isIOS || Platform.isAndroid;

  static bool get isDesktop => !isMobile;
}
