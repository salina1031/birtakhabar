# BirtaKhabar (Flutter App)

Real-time local news and emergency alert mobile application for Birtamode
and the surrounding Jhapa district — built from the project proposal.

This is the **MVP scope**: user registration/login, categorized news feed,
emergency alerts, save & share, community news tip submissions, and a
lightweight in-app admin panel for content management.

Not yet implemented (flagged as future work in the proposal itself): the
full React.js web admin dashboard, business listings/advertising module,
live (non-sandbox) eSewa/Khalti payments, and the premium subscription
purchase flow. The Firestore data model already includes a `businesses`
collection and role field so these can be added without restructuring data.

## Project structure

```
lib/
  main.dart                  # Entry point, Firebase init
  app.dart                   # Provider wiring + MaterialApp
  theme/app_theme.dart       # Colors, typography, component themes
  utils/constants.dart       # Enums: NewsCategory, UserRole, TipStatus
  models/                    # NewsArticle, EmergencyAlert, NewsTip, AppUser
  services/                  # AuthService, FirestoreService, NotificationService
  providers/                 # AuthProvider, NewsProvider, AlertsProvider, SavedProvider
  screens/
    splash_screen.dart
    auth/                    # login, register
    home/                    # bottom-nav shell: news feed, alerts, saved, profile
    news/                    # article detail
    tips/                    # community tip submission
    admin/                   # dashboard, review tips, post news, post alert
  widgets/                   # NewsCard, AlertCard, CategoryChip, etc.
```

This maps directly onto the four-layer architecture from the proposal:

| Proposal layer                  | Implementation here                                   |
|---------------------------------|---------------------------------------------------------|
| Presentation Layer               | `lib/screens`, `lib/widgets` (Flutter mobile app)       |
| Application / Business Logic     | `lib/providers`, `lib/services` (client-side logic; pair with Firebase Cloud Functions for server-side rules, e.g. fan-out notifications) |
| Data Layer                       | Cloud Firestore, Firebase Auth, Firebase Storage         |
| Third-Party Integration Layer    | Firebase Cloud Messaging, (Payment Gateways / Social Sharing to be added) |

## Setup

1. **Install Flutter** (stable channel) — see https://docs.flutter.dev/get-started/install
2. **Create a Firebase project** at https://console.firebase.google.com, enable:
   - Authentication → Email/Password
   - Firestore Database
   - Storage
   - Cloud Messaging
3. **Generate real Firebase config** (replaces the placeholder file):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This regenerates `lib/firebase_options.dart` and adds
   `android/app/google-services.json` / `ios/Runner/GoogleService-Info.plist`.
4. **Install dependencies:**
   ```bash
   flutter pub get
   ```
5. **Deploy Firestore security rules** (see `firestore.rules`):
   ```bash
   firebase deploy --only firestore:rules
   ```
6. **Create your first admin account:** register normally in the app, then
   in the Firebase console manually change that user's `role` field in
   `users/{uid}` from `resident` to `admin`. They'll then see the Admin
   Dashboard entry on their Profile tab.
7. **Run the app:**
   ```bash
   flutter run
   ```

## Notes on notifications

`NotificationService` subscribes each device to FCM topics matching the
user's selected news categories (`local`, `emergency`, `sports`, `business`,
`events`). To actually deliver a push when an admin posts news/an alert,
add a Cloud Function that triggers on Firestore writes to `news/{id}` or
`alerts/{id}` and sends to the matching topic — this keeps the client thin
and avoids needing per-user fan-out logic on-device.

## Seed data

The app renders an empty state until content exists. Fastest way to see it
populated: sign in as an admin and use **Profile → Admin Dashboard → Publish
News Article / Post Emergency Alert** to add a few sample items.
