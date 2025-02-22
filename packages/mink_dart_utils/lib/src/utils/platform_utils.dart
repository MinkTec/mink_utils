// ignore_for_file: dont_use_io_platform
import 'dart:io';

final class PlatformInfo {
  static bool get isGerman => locale.startsWith("de");

  static bool get isMobile => Platform.isIOS || Platform.isAndroid;

  static bool get isDesktop => !isMobile;

  static String get locale => Platform.localeName;

  static String get pathSeperator => Platform.pathSeparator;

  static bool get isIOS => Platform.isIOS;

  static bool get isAndroid => Platform.isAndroid;

  static bool get isMacOS => Platform.isMacOS;

  static bool get isWindows => Platform.isWindows;

  static bool get isLinux => Platform.isLinux;

  static bool get isFuchsia => Platform.isFuchsia;

  static bool get isWeb => false;
}
