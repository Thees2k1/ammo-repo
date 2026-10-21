/// Opinionated pure Dart utilities and helpers for modern Dart 3+ applications.
library ammo_dart;

export 'src/enumerable.dart';

/// String utility helpers.
extension AmmoStringX on String {
  /// Returns `true` if this string is null or empty after trimming.
  bool get isBlank => trim().isEmpty;

  /// Capitalizes the first letter of the string.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
