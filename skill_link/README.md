# SkillLink

SkillLink is a Flutter application that connects users with local service providers.
Users can browse service categories, explore verified providers, view provider details,
book appointments, and manage their bookings — while providers can register their
business and grow their customer base.

## Features

- **Authentication** — email/password sign-up and sign-in backed by Firebase Auth.
- **Explore** — browse service categories and discover service providers.
- **Provider details** — view provider profiles, ratings, and services offered.
- **Booking** — request an appointment and track booking status and history.
- **Provider registration** — register a service business with profile and cover images.
- **Profile & premium** — manage your account and view premium offerings.
- **Local persistence** — booking data cached locally with `shared_preferences`.

## Tech Stack

- **Framework:** Flutter (Dart SDK `^3.12.2`)
- **Backend:** Firebase (Core, Auth, Cloud Firestore, Storage)
- **Packages:** `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `image_picker`, `shared_preferences`

## Project Structure

```
lib/
├── data/        # Sample providers and service category data
├── models/      # Booking, service provider, and registration models
├── screens/     # Auth, home, explore, booking, profile, registration screens
├── services/    # Auth, booking, storage, upload, and repository services
├── theme/       # App colors and theme
└── widgets/     # Reusable cards and shared widgets
```

## Getting Started

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Fetch the dependencies:

   ```sh
   flutter pub get
   ```

3. Configure Firebase:
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
   - Update `lib/firebase_options.dart` with your own Firebase project values.
4. Run the app:

   ```sh
   flutter run
   ```

### Useful Resources

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
- [Flutter API reference](https://docs.flutter.dev/)

## Team Members

| Name | ID | Role |
| --- | --- | --- |
| Abel Endale | CTC/1667/26 | Flutter Developer |

### Contributions

- **Abel Endale** — Flutter Developer
  - Built the cross-platform Flutter UI and navigation for SkillLink.
  - Implemented Firebase authentication, Firestore data access, and Storage image uploads.
  - Developed the booking flow, provider registration flow, and supporting services.

## License

This project is licensed for use by the INSA SkillLink team.
