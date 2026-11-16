/// Price formatting for WooCommerce Store API amounts (minor units).
abstract final class Money {
  /// `4500` with 2 minor digits → `45 DH`; `4550` → `45,50 DH`.
  static String format(int minorAmount, {int minorUnit = 2}) {
    final divisor = _pow10(minorUnit);
    final whole = minorAmount ~/ divisor;
    final rest = minorAmount.remainder(divisor);
    final wholeText = _group(whole);
    if (rest == 0) return '$wholeText DH';
    return '$wholeText,${rest.toString().padLeft(minorUnit, '0')} DH';
  }

  static int _pow10(int n) {
    var value = 1;
    for (var i = 0; i < n; i++) {
      value *= 10;
    }
    return value;
  }

  static String _group(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
