/// Version applicative au format `major.minor.patch+build` utilisé par le
/// champ `version:` de `pubspec.yaml` et par les tags des GitHub Releases
/// (le préfixe `v` et un éventuel suffixe de pré-version sont ignorés).
class AppVersion {
  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.build,
  });

  final int major;
  final int minor;
  final int patch;
  final int? build;

  static final _pattern =
      RegExp(r'^\s*v?(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\+(\d+))?');

  /// Retourne `null` si [raw] ne commence pas par un numéro de version.
  static AppVersion? tryParse(String raw) {
    final match = _pattern.firstMatch(raw);
    if (match == null) return null;
    return AppVersion(
      major: int.parse(match.group(1)!),
      minor: int.tryParse(match.group(2) ?? '') ?? 0,
      patch: int.tryParse(match.group(3) ?? '') ?? 0,
      build: int.tryParse(match.group(4) ?? ''),
    );
  }

  bool isNewerThan(AppVersion other) {
    if (major != other.major) return major > other.major;
    if (minor != other.minor) return minor > other.minor;
    if (patch != other.patch) return patch > other.patch;
    // Le numéro de build ne départage que si les deux versions le déclarent :
    // les tags GitHub l'omettent la plupart du temps.
    if (build == null || other.build == null) return false;
    return build! > other.build!;
  }

  @override
  String toString() =>
      build == null ? '$major.$minor.$patch' : '$major.$minor.$patch+$build';

  @override
  bool operator ==(Object other) =>
      other is AppVersion &&
      other.major == major &&
      other.minor == minor &&
      other.patch == patch &&
      other.build == build;

  @override
  int get hashCode => Object.hash(major, minor, patch, build);
}
