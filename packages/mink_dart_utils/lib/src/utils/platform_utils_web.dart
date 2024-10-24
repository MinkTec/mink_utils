import 'dart:html' as html;

final class PlatformInfo {
  static bool get isGerman => locale.startsWith("de");

  static bool get isMobile => false;

  static bool get isDesktop => !isMobile;

  static String get locale => html.document.body!.localName;
}
