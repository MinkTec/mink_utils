import 'dart:html' as html;

final class PlatformInfo {
  static bool get isGerman => locale.startsWith("de");

  static bool get isMobile => false;

  static bool get isDesktop => false;

  static String get locale => "en_US";

  static String get pathSeperator => "/";
  // Alias with correct spelling
  static String get pathSeparator => pathSeperator;

  static bool get isIOS => false;

  static bool get isAndroid => false;

  static bool get isMacOS => false;

  static bool get isWindows => false;

  static bool get isLinux => false;

  static bool get isFuchsia => false;

  static bool get isWeb => true;

  static int get nProcs => html.window.navigator.hardwareConcurrency;
}
