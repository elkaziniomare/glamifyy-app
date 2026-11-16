import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../core/config.dart';

/// Push notifications for promotions (Firebase Cloud Messaging).
///
/// The app works without Firebase: until `google-services.json` (Android) and
/// `GoogleService-Info.plist` (iOS) are added, [init] logs and returns false.
/// See docs/PUSH.md for the setup steps.
abstract final class PushService {
  static Future<bool> init() async {
    if (kIsWeb) return false;
    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return false;
      }
      await messaging.subscribeToTopic(AppConfig.promoTopic);
      return true;
    } catch (e) {
      debugPrint('Push disabled: $e');
      return false;
    }
  }
}
