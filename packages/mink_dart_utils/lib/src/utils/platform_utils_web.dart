import 'dart:html' as html;

final class PlatformInfo {
  static bool get isGerman => locale.startsWith("de");

  static bool get isMobile => false;

  static bool get isDesktop => !isMobile;

  static String get locale => html.document.body!.localName;

  static String get pathSeperator => "/";

  static bool get isIOS => false;

  static bool get isAndroid => false;

  static bool get isMacOS => false;

  static bool get isWindows => false;

  static bool get isLinux => false;

  static bool get isFuchsia => false;
}
