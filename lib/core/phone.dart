/// Moroccan phone validation. Mirrors `MCWC_Phone` in the Maroc Checkout plugin,
/// so the app rejects exactly what the server rejects.
abstract final class MoroccanPhone {
  static final RegExp _pattern = RegExp(r'^(?:\+212|00212|212|0)([5-7]\d{8})$');
  static final RegExp _junk = RegExp(r'[^\d+]');

  /// The 9 national digits (e.g. `612345678`), or null when invalid.
  static String? nationalDigits(String raw) {
    final digits = raw.replaceAll(_junk, '');
    if (digits.isEmpty) return null;
    return _pattern.firstMatch(digits)?.group(1);
  }

  static bool isValid(String raw) => nationalDigits(raw) != null;

  /// `+212612345678`, or the input unchanged when invalid.
  static String normalize(String raw) {
    final national = nationalDigits(raw);
    return national == null ? raw : '+212$national';
  }
}
