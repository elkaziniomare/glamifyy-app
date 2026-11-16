/// Text helpers for content coming from WordPress.
abstract final class TextUtils {
  static const Map<String, String> _named = {
    'amp': '&',
    'lt': '<',
    'gt': '>',
    'quot': '"',
    'apos': "'",
    'nbsp': ' ',
    'rsquo': '’',
    'lsquo': '‘',
    'rdquo': '”',
    'ldquo': '“',
    'ndash': '–',
    'mdash': '—',
    'hellip': '…',
    'eacute': 'é',
    'egrave': 'è',
    'agrave': 'à',
    'ccedil': 'ç',
  };

  static final RegExp _entity = RegExp(r'&(#x?[0-9a-fA-F]+|[a-zA-Z]+);');
  static final RegExp _tag = RegExp(r'<[^>]*>');
  static final RegExp _spaces = RegExp(r'\s+');

  /// Decodes HTML entities such as `&amp;`, `&rsquo;` or `&#8211;`.
  static String decodeEntities(String input) {
    return input.replaceAllMapped(_entity, (m) {
      final code = m.group(1)!;
      if (code.startsWith('#x') || code.startsWith('#X')) {
        final value = int.tryParse(code.substring(2), radix: 16);
        return value == null ? m.group(0)! : String.fromCharCode(value);
      }
      if (code.startsWith('#')) {
        final value = int.tryParse(code.substring(1));
        return value == null ? m.group(0)! : String.fromCharCode(value);
      }
      return _named[code.toLowerCase()] ?? m.group(0)!;
    });
  }

  /// Strips tags, decodes entities and collapses whitespace.
  static String plain(String html) {
    return decodeEntities(html.replaceAll(_tag, ' '))
        .replaceAll(_spaces, ' ')
        .trim();
  }
}
