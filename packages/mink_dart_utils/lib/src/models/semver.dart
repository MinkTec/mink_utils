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
    final String? label;
    if (semver.contains('+')) {
      label = parts.last;
    } else {
      label = null;
    }

    if (parts.isEmpty) {
      throw FormatException("Invalid SemVer string: $semver. Cannot be empty.");
    }

    final major = int.parse(parts[0]);
    final minor = parts.length > 1 ? int.parse(parts[1]) : 0;
    final patch;

    if (semver.contains('+')) {
      // If there's a label, patch is the part before the label, or 0 if not present
      patch = parts.length > 2 && parts[2] != label ? int.parse(parts[2]) : 0;
    } else {
      // If no label, patch is the third part, or 0 if not present
      patch = parts.length > 2 ? int.parse(parts[2]) : 0;
    }

    return SemVer(
      major: major,
      minor: minor,
      patch: patch,
      label: label,
    );
  }

  static SemVer? tryParse(Object? semver) {
    if (semver == null) return null;
    try {
      return SemVer.parse(semver as String);
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
