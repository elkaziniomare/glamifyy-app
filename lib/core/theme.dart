import 'package:material_ui/material_ui.dart';

/// Glamifyy brand colours, taken from glamifyy.shop.
abstract final class Brand {
  static const Color green = Color(0xFF2F5A45);
  static const Color cream = Color(0xFFF7F1E8);
  static const Color sand = Color(0xFFECE2D4);
  static const Color gold = Color(0xFFD6B270);
  static const Color ink = Color(0xFF221E1C);
  static const Color whatsapp = Color(0xFF1F8F4E);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Brand.green,
    primary: Brand.green,
    surface: Brand.cream,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: Brand.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: Brand.cream,
      foregroundColor: Brand.ink,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
