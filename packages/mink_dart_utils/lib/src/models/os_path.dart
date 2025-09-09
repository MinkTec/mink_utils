import 'package:mink_dart_utils/mink_dart_utils.dart';

class OsPath {
  final List<String> _parts;

  OsPath(this._parts) {
    if (PlatformInfo.isWindows) {
      assert(RegExp(_windowsValidityRegex, multiLine: true).hasMatch(path) ==
          false);
    }
  }

  void push(String part) {
    _parts.add(part);
  }

  String removeLast() {
    return
    _parts.removeLast();
  }

  static const String _windowsValidityRegex =
      r"""^(?: [<>:"/\\|?*] | (?:[a-zA-Z]:)?\\ (?: (?:CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\\.|$)))""";

  String get path => _parts.join(PlatformInfo.pathSeperator);

  bool get isAbsolute {
    if (PlatformInfo.isNixLike) {
      return path.startsWith(PlatformInfo.pathSeperator);
    } else {
      return RegExp(r"^[a-zA-Z]:\\").hasMatch(path);
    }
  }

  bool get isRelative => !isAbsolute;

  String? get fileExtension {
    final splits = _parts.last.split('.');
    if (splits.length == 1) {
      return null;
    } else {
      return splits.last;
    }
  }
}
