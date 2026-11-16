import 'package:url_launcher/url_launcher.dart';

import '../core/config.dart';

abstract final class WhatsApp {
  static Uri link(String message) => Uri.https(
        'wa.me',
        '/${AppConfig.whatsappNumber}',
        {'text': message},
      );

  /// Opens WhatsApp (or wa.me in the browser). Returns false if nothing could open it.
  static Future<bool> open(String message) =>
      launchUrl(link(message), mode: LaunchMode.externalApplication);
}
