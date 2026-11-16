/// App-wide configuration.
///
/// `API_BASE` can be overridden at build time, e.g. for a local mock server:
/// `flutter run --dart-define=API_BASE=http://localhost:8080`.
abstract final class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://glamifyy.shop',
  );

  /// Store WhatsApp number, international format without "+".
  static const String whatsappNumber = '212616734343';

  static const String storeName = 'Glamifyy';

  /// FCM topic every install subscribes to for promotions.
  static const String promoTopic = 'promos';
}
