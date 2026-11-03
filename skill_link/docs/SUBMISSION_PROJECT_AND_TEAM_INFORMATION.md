# SkillLink: Project and Team Information

## Project Information

### Project name

**SkillLink**

### Project purpose

SkillLink is a Flutter mobile marketplace that helps people in Addis Ababa,
Ethiopia find and connect with trusted local service providers. Customers can
discover professionals, compare their services and prices, view provider
profiles, and submit booking requests. Service professionals can register
their services and reach new customers through the platform.

The project is designed as a functional MVP for demonstrating a practical
local-services marketplace, with a focus on simple navigation, secure data
handling, and a professional mobile user experience.

### Main features

- Email/password authentication using Firebase Authentication.
- Service discovery for tutoring, photography, electrical, plumbing, graphic
  design, cleaning, and other local services.
- Search, category filtering, and provider sorting by relevance, rating, and
  price.
- Provider profiles showing professional details, experience, pricing,
  availability, ratings, and verification status.
- Booking request creation and booking-history management.
- Provider registration and onboarding with optional profile-image upload.
- Firebase Cloud Firestore persistence for users, providers, registrations,
  and application data.
- Firebase Storage integration for uploaded images.
- Administrator dashboard for reviewing provider registrations.
- Secure external Supabase Edge Function gateway for administrator listing,
  approval, and rejection operations.
- Firebase custom-claim authorization requiring `admin: true` for
  administrator operations.
- Local sample data and local persistence to support demonstrations when
  backend data is unavailable.
- Material 3 design with a consistent navy, teal, white, and light-gray visual
  system.

### Technology used

- Flutter and Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Supabase Edge Functions
- Deno and TypeScript
- Google Cloud Firestore REST API
- `shared_preferences`
- `http`
- `image_picker`

### Repository

GitHub repository:

```text
https://github.com/Abel8866/SkillLink
```

## Team Information

The following team information is included in the repository documentation
and should be included in the GitHub submission:

| Full name | CTC ID | Role |
|---|---|---|
| Abel Endale | CTC/1667/26 | Lead Developer and Full-Stack Engineer |

### Responsibilities

Abel Endale contributed to:

- Flutter application architecture and Material 3 interface design.
- Home, explore, provider-details, booking, profile, and registration
  workflows.
- Firebase Authentication, Cloud Firestore, and Firebase Storage integration.
- Firestore and Storage security rules.
- Provider discovery and approved-provider visibility.
- Administrator dashboard and provider-registration review workflow.
- Supabase Edge Function gateway implementation.
- Firebase ID-token verification and administrator custom-claim checks.
- Firestore REST access and concurrency-safe approval/rejection operations.
- Automated Flutter and Deno tests.
- Project documentation and deployment guidance.

## Submission checklist

Before submitting the GitHub repository, verify that:

- This document is committed under `docs/`.
- The `README.md` links to the project documentation.
- Every team member is listed with a full name and CTC ID.
- No service-account credentials, private keys, tokens, or secret values are
  committed.
- Firebase and Supabase configuration instructions do not expose secrets.
- The repository contains the source code, tests, security rules, and setup
  instructions needed to review the project.

