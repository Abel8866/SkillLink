# SkillLink

SkillLink is a cross-platform Flutter application that connects users with local service providers in Ethiopia (Addis Ababa). Users can browse service categories, explore verified providers, view provider details, book appointments, and manage their bookings — while professionals can register their business, showcase their skills, and grow their customer base.

---

## Features

- **Authentication & Security** — Email/password sign-up and sign-in backed by Firebase Authentication with custom claims support for administrators.
- **Service Discovery & Exploration** — Browse curated service categories (Tutoring, Photography, Electrical, Plumbing, Graphic Design, Cleaning) with real-time search, category filtering, and sorting (relevance, rating, price).
- **Provider Profiles & Verification** — Detailed professional profiles showing ratings, reviews, experience, hourly/service rates, availability badges, and verified status.
- **Appointment Booking** — Interactive booking request workflow with appointment tracking, status updates, and history.
- **Provider Registration & Onboarding** — Streamlined registration flow for service professionals with image/document upload capabilities.
- **Administrative Dashboard & Gateway** — Secure administrative portal for reviewing, approving, or rejecting provider registrations powered by an external Supabase Edge Function gateway.
- **Demonstration / Offline Mode** — Resilient fallback to local sample provider data to ensure a smooth, populated user experience during development and evaluation.
- **Local Persistence** — Cached user session and booking data with `shared_preferences`.

---

## Tech Stack

- **Frontend / Mobile Framework:** Flutter (Dart SDK `^3.12.2`), Material 3 Design
- **Core Backend:** Firebase (Authentication, Cloud Firestore, Cloud Storage, Security Rules)
- **Admin Gateway:** Supabase Edge Functions (Deno & TypeScript) with Firebase Admin token verification and Google Cloud Firestore REST integration
- **Networking & State:** `http`, `shared_preferences`, Dart Streams (`StreamBuilder`)
- **Key Flutter Packages:** `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `http`, `image_picker`, `shared_preferences`, `cupertino_icons`

---

## Project Structure

```
skill_link/
├── lib/
│   ├── data/            # Sample providers and service categories (demo fallback)
│   ├── models/          # Service provider, booking, and registration data models
│   ├── screens/         # Home, explore, booking, details, profile, admin, and registration screens
│   ├── services/        # Admin HTTP gateway, auth, booking, storage, and repository services
│   ├── theme/           # App colors and Material 3 theme definitions
│   └── widgets/         # Reusable provider cards, category chips, avatars, and custom UI components
├── external-admin-gateway/ # Isolated Deno/TypeScript Supabase Edge Function for admin operations
├── test/                # Flutter unit, widget, and service tests
└── pubspec.yaml         # Project dependencies and configuration
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.12.2`)
- Android Studio / Xcode / VS Code with Flutter extensions
- A configured Firebase project with Authentication, Firestore, and Storage enabled

### Setup & Run

1. **Clone the repository:**

   ```sh
   git clone https://github.com/Abel8866/SkillLink.git
   cd SkillLink/skill_link
   ```

2. **Install dependencies:**

   ```sh
   flutter pub get
   ```

3. **Configure Firebase:**
   - Place your `google-services.json` inside `android/app/`.
   - Place your `GoogleService-Info.plist` inside `ios/Runner/`.
   - Update `lib/firebase_options.dart` with your Firebase project credentials.

4. **Launch the application:**

   ```sh
   flutter run
   ```

5. **Run test suites:**

   ```sh
   flutter test
   flutter analyze
   ```

---

## Team & Roles

### Project Contributor

| Name | Student ID | Specific Roles |
| :--- | :--- | :--- |
| **Abel Endale** | **CTC/1667/26** | **Lead Developer & Full-Stack Engineer** |

---

### Specific Contributions & Responsibilities — Abel Endale

- **Cross-Platform Mobile Application Development (Flutter):**
  - Architected and built the entire cross-platform Flutter application with Material 3 design, custom typography, responsive layouts, and intuitive navigation.
  - Implemented the **Home & Service Discovery** screen featuring promotional banners, category carousels, featured professionals, and dynamic provider listings.
  - Developed the **Explore & Search** module with real-time text query filtering, category chip selection, and multi-criteria sorting (Relevance, Highest Rating, Price: Low to High, Price: High to Low).
  - Built the **Provider Details & Booking** workflows, enabling users to inspect verified credentials, pricing, and availability, and submit booking requests.
  - Engineered the **Provider Registration** flow, allowing local professionals to submit business details, pricing units, and experience along with profile image selection.
  - Implemented the **Demonstration / Sample Provider Architecture** that gracefully falls back to structured sample data when the database is empty, ensuring seamless offline demonstrations.

- **Cloud Backend, Authentication & Database (Firebase):**
  - Integrated and managed **Firebase Authentication** for user registration, login, and secure session management.
  - Designed the **Cloud Firestore** database schema, collections (`providerRegistrations`, bookings), real-time query listeners, and field mapping.
  - Configured **Firebase Storage** pipelines for secure image uploads and media hosting.
  - Established Firestore and Storage security rules ensuring user privacy and authorized data mutations.

- **Secure Edge Gateway & Admin Operations (Supabase / Deno / TypeScript):**
  - Architected and deployed the external **Supabase Edge Function Admin Gateway** (`admin-registrations`) in Deno / TypeScript to enable serverless administrative operations without exposing service account credentials to client devices.
  - Implemented cryptographically secure **Firebase ID Token verification**, checking signatures, audience, issuer, expiration, and the custom `admin: true` claim.
  - Implemented server-side Google Cloud Firestore REST API calls using service account credentials for secure listing and atomic review updates (approve/reject).
  - Designed comprehensive **CORS preflight handling** with dynamic origin validation, custom headers (`Authorization`, `Content-Type`), and strict HTTP method restrictions.
  - Built the **Admin Dashboard Screen** in Flutter with HTTP client integration, error handling, token refresh retries, and real-time status management.

- **Quality Assurance, Testing & DevOps:**
  - Created automated test suites including Flutter unit tests for `AdminService` HTTP communications, widget tests, and over 30 Deno unit tests for edge function routing and security.
  - Maintained zero static analysis warnings (`flutter analyze`) and enforced strict typing and error boundary resilience.
  - Maintained project documentation, deployment guidelines, and Git version control workflows.

---

## License

This project is licensed for academic and developmental use under the INSA SkillLink project.
