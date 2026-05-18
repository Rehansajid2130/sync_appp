# 🐝 HelperHive

> A premium on-demand home services platform connecting customers with verified local service providers — built with Flutter.

---

## 📱 Overview

HelperHive is a mobile application that brings the convenience of on-demand services (cleaning, plumbing, electrician work, carpentry, and more) directly to your fingertips. Inspired by platforms like TaskRabbit and Urban Company, HelperHive provides a seamless dual-sided experience for both **Customers** and **Service Providers**.

The current version is a **fully functional frontend prototype** with local data persistence — no backend or payment infrastructure required at this stage.

---

## ✅ What Has Been Built

### 🧑‍💼 Customer Side

| Feature | Status |
|---|---|
| Splash Screen with animated branding | ✅ Done |
| Home / Discovery Feed (browse providers by category) | ✅ Done |
| Provider Detail Screen (ratings, reviews, availability) | ✅ Done |
| Service Booking Flow (3-step: Date → Details → Summary) | ✅ Done |
| Booking Confirmation / Success Screen | ✅ Done |
| My Bookings Screen (Upcoming, Completed, Cancelled tabs) | ✅ Done |
| Photo Upload for service requests (camera & gallery) | ✅ Done |
| Search & Filter Providers | ✅ Done |
| Address Selection with Map | ✅ Done |
| Post-Service Review & Star Rating Screen | ✅ Done |
| Customer Profile Screen | ✅ Done |
| Edit Profile (with real photo upload) | ✅ Done |
| Notification Center (in-app) | ✅ Done |
| Notification Settings | ✅ Done |
| Security Settings Screen | ✅ Done |
| Dark Mode / Light Mode Toggle (persisted) | ✅ Done |
| Chat / Messaging Screen with provider | ✅ Done |

### 🔧 Provider Side

| Feature | Status |
|---|---|
| Provider Onboarding / Setup Screen | ✅ Done |
| Provider Dashboard (earnings overview, job stats) | ✅ Done |
| Incoming Job Requests Screen | ✅ Done |
| Request Details Screen (view customer photos & description) | ✅ Done |
| Accept / Decline Job Flow | ✅ Done |
| Active Jobs Management | ✅ Done |
| Provider Profile & Business Profile Edit | ✅ Done |
| Business Profile Photo Upload | ✅ Done |
| Switch between Customer ↔ Provider mode | ✅ Done |
| Provider-side Notification Center | ✅ Done |

### ⚙️ Engineering & Architecture

| Feature | Status |
|---|---|
| Centralized Named Routing (`AppRoutes`) | ✅ Done |
| Reusable UI Components (`PrimaryButton`, `SectionCard`) | ✅ Done |
| Centralized App Logging (`AppLogger`) | ✅ Done |
| Global Flutter Error Boundary | ✅ Done |
| Local Data Persistence (`SharedPreferences`) via `StorageService` | ✅ Done |
| Mock Data Layer with full JSON serialization | ✅ Done |
| System Push Notifications (`flutter_local_notifications`) | ✅ Done |
| Dark/Light theme enforcement via `AppColors` design system | ✅ Done |
| Unit tests (Model layer) | ✅ Done |
| Widget tests (`PrimaryButton`) | ✅ Done |
| Release APK Build (with `--no-tree-shake-icons`) | ✅ Done |

---

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── data/
│   │   └── mock_data.dart          # In-memory data store (Bookings, Providers, Notifications)
│   ├── routes/
│   │   └── app_routes.dart         # Centralized named route definitions
│   ├── services/
│   │   ├── storage_service.dart    # SharedPreferences wrapper
│   │   └── notification_service.dart
│   ├── theme/
│   │   ├── app_colors.dart         # Design system color tokens
│   │   └── app_typography.dart
│   └── utils/
│       └── app_logger.dart         # Centralized debug logging
├── models/
│   ├── service_provider.dart
│   └── (booking model inside mock_data.dart)
├── screens/
│   ├── provider/                   # All provider-facing screens
│   └── *.dart                      # All customer-facing screens
├── widgets/
│   ├── primary_button.dart         # Reusable CTA button
│   └── section_card.dart           # Reusable content card
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Android Studio or VS Code with Flutter extension
- A physical device or emulator (Android/iOS)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/helperhive.git
cd helperhive

# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release --no-tree-shake-icons
```

> **Note:** The `--no-tree-shake-icons` flag is required because provider icons are loaded dynamically from serialized JSON data.

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `shared_preferences` | Local data persistence (theme, bookings, settings) |
| `image_picker` | Gallery & camera photo selection |
| `flutter_local_notifications` | System-level push notifications |
| `google_maps_flutter` | Address selection map |
| `intl` | Date & time formatting |

---

## 🔮 Future Plans (Roadmap)

### Phase 2 — Backend Integration
- [ ] **Firebase Authentication** — Email/password, Google Sign-In, phone OTP
- [ ] **Firestore Database** — Replace `MockData` with real-time cloud data for bookings, providers, and users
- [ ] **Firebase Storage** — Upload and store profile photos and service request images
- [ ] **Firebase Cloud Messaging (FCM)** — Real push notifications to specific user devices

### Phase 3 — Provider Reputation System
- [ ] **Rating Aggregation** — Display live average rating on provider cards after multiple reviews are submitted
- [ ] **Reviews History Screen** — Let providers see all reviews left for them
- [ ] **Provider Verification Badge** — Display a "Verified" badge after admin approves documentation

### Phase 4 — UX Enhancements
- [ ] **Live Job Tracking (Map Screen)** — Real-time GPS tracking of the provider en-route to the customer, similar to Uber
- [ ] **In-App Chat with Media** — Allow photos to be shared inside the messaging screen
- [ ] **Onboarding Walkthrough** — First-time user onboarding carousel explaining the app features
- [ ] **Saved / Favourite Providers** — Let customers save their go-to providers for quick re-booking

### Phase 5 — State Management Upgrade
- [ ] **Migrate to Riverpod** — Replace `setState` and constructor-drilling with a proper reactive state management solution for scalability
- [ ] **Repository Pattern** — Abstract all data access behind repository interfaces so swapping MockData → Firebase requires zero screen-level changes

### Phase 6 — Internationalization & Accessibility
- [ ] **Multi-language Support (i18n)** — Add English, Spanish, French, and Bahasa Indonesia
- [ ] **Accessibility Audit** — Ensure all screens are screen-reader compatible (`Semantics` widgets)
- [ ] **RTL Layout Support** — Full right-to-left language support

---

## 🎨 Design System

HelperHive uses a custom design system with a **Midnight Dark / Clean Light** dual-theme, built entirely with Material 3:

- **Primary Brand Color:** `#34A853` (Google Green)
- **Dark Background:** `#090909` (Near Black)
- **Dark Surface:** `#161616`
- **Typography:** Adaptive with `AppTypography` text themes
- **Border Radius:** Rounded pill-style inputs (`20px`) and cards (`24px`)

---

## 📸 Screenshots

> _Screenshots and screen recordings to be added after final UI polish._

---

## 🤝 Contributing

This project is currently in private development. Contribution guidelines will be published alongside the open-source release.

---

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

*Built with ❤️ using Flutter*
