# Push notifications (Firebase Cloud Messaging)

The code is ready (`lib/services/push.dart`): at startup the app asks for permission and
subscribes to the `promos` topic. Until the Firebase files below are added, the app runs
normally and push is simply disabled.

## One-time setup (15 min, with the Glamifyy Google account)

1. Go to https://console.firebase.google.com → **Add project** → name it `glamifyy`.
2. **Android**: Add app → package name `shop.glamifyy.glamifyy_app` → download
   `google-services.json` → put it in `android/app/`.
3. **iOS**: Add app → bundle ID `shop.glamifyy.glamifyyApp` → download
   `GoogleService-Info.plist` → add it to `ios/Runner/` in Xcode.
   On iOS, also upload an **APNs key** (Apple Developer account → Keys) in
   Firebase → Project settings → Cloud Messaging.
4. Easiest wiring: `dart pub global activate flutterfire_cli` then `flutterfire configure`
   (generates `firebase_options.dart` and the Gradle plugin lines).
5. Rebuild the app.

## Sending a promo

Firebase console → **Messaging** → **New campaign** → Notifications →
Target: **Topic** `promos` → write the message (e.g. "-20 % sur le chébé ce week-end") → Publish.

Keep it to 1–2 messages a week: more and people disable notifications.
