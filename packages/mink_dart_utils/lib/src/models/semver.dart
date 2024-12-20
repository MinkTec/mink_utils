import 'dart:convert';

/// semantic versioning
class SemVer implements Comparable<SemVer> {
  final int major;
  final int minor;
  final int patch;
  final String? label;

  SemVer({
    this.major = 0,
    this.minor = 0,
    this.patch = 0,
    this.label,
  }) {
    assert(0 <= major);
    assert(0 <= minor);
    assert(0 <= patch);
  }

  factory SemVer.fromList(List<int> semver, {String? label}) => SemVer(
        major: semver[0],
        minor: semver.length >= 2 ? semver[1] : 0,
        patch: semver.length >= 3 ? semver[2] : 0,
        label: label,
      );

  Map<String, dynamic>? toJson() => {
        "major": major,
        "minor": minor,
        "path": patch,
        "label": label,
      };

  static Map<String, dynamic>? toJsonStatic(SemVer? semver) => semver?.toJson();

  static SemVer? fromJson(Map<String, dynamic> json) {
    return json.containsKey("major")
        ? SemVer(
            major: json["major"],
            minor: json["minor"],
            patch: json["path"],
            label: json["label"],
          )
        : null;
  }

  factory SemVer.parse(String semver) {
    final parts = semver.split(RegExp(r"(\.|\+)"));
    final label = parts.length == 4 ? parts.last : null;
    return SemVer(
      major: int.parse(parts[0]),
      minor: int.parse(parts[1]),
      patch: int.parse(parts[2]),
      label: label,
    );
  }

  static SemVer? tryParse(Object semver) {
    try {
      return SemVer.parse(semver as String);
    } catch (_) {}

    try {
      return SemVer.fromJson(jsonDecode(semver as String));
    } catch (_) {}

    try {
      return SemVer.fromJson(semver as Map<String, dynamic>);
    } catch (_) {}

    return null;
  }

  List<int> toList() => [major, minor, patch];

  SemVer copyWith({
    int? major,
    int? minor,
    int? patch,
    String? label,
  }) {
    return SemVer(
      major: major ?? this.major,
      minor: minor ?? this.minor,
      patch: patch ?? this.patch,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! SemVer) {
      return false;
    }
    return other.major == major &&
        minor == other.minor &&
        patch == other.patch &&
        label == other.label;
  }

  @override
  String toString() {
    String string = "$major.$minor.$patch";
    if (label != null) {
      string += "+$label";
    }

    return string;
  }

  bool operator <(SemVer other) => compareTo(other) == -1;

  bool operator <=(SemVer other) => compareTo(other) != 1;

  bool operator >(SemVer other) => compareTo(other) == 1;

  bool operator >=(SemVer other) => compareTo(other) != -1;

  @override
  int compareTo(SemVer other) {
    int comp = major.compareTo(other.major);
    if (comp != 0) {
      return comp;
    }
    comp = minor.compareTo(other.minor);
    if (comp != 0) {
      return comp;
    }
    comp = patch.compareTo(other.patch);
    if (comp != 0) {
      return comp;
    }
    return 0;
  }
}
