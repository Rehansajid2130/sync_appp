# HelperHive — Codebase Analysis & Next Steps

> Full breakdown of what's built, what's mocked, and what the backend phase needs to address.

---

## 1. What This Project Is

**HelperHive** is a **double-sided on-demand home services marketplace** built in Flutter.
- **Customer side**: Search → AI-powered matching → Book a service provider
- **Provider side**: Accept/decline jobs → Track active jobs → Manage storefront

It's currently a **fully functional frontend** with all data simulated through a local `MockData` layer backed by `SharedPreferences`. No real backend, no auth, no real payments — everything is wired to in-memory lists and local storage. The goal of this phase was to demo the complete UX flow for a hackathon.

---

## 2. Architecture (Current State)

```
UI Screens (35 total)
    │
    ▼
MockData (static class — acts as in-memory DB)
    │           │
    ▼           ▼
StorageService      NotificationService
(SharedPreferences)  (flutter_local_notifications)
```

### Key Files

| File | Role |
|---|---|
| `lib/core/data/mock_data.dart` | Central data store — Booking, AppNotification, ServiceProvider lists |
| `lib/models/service_provider.dart` | Provider model with JSON serialization |
| `lib/core/services/storage_service.dart` | SharedPreferences wrapper |
| `lib/core/services/notification_service.dart` | Native push notifications (Android/iOS) |
| `lib/core/theme/` | AppColors, AppTypography (Google Fonts Inter) |

---

## 3. What's Fully Built ✅

### Auth & Onboarding (9 screens)
- Splash → Onboarding (3-page) → Login → Email Login → Signup → OTP Verification → Reset Password → Create New Password → Address Setup
- **State**: All UI is complete. Auth is simulated (no real token/session). OTP codes are not verified against any backend.

### Customer-Side Flow (11 screens)
- Classic Dashboard (`home_dashboard_screen`) + AI Chat Dashboard (`dashboardScreen2`)
- Search results with filter chips + provider cards fully navigable
- Full service detail screen (collapsing SliverAppBar, tabs, gallery, reviews)
- **4-Stage Booking Funnel** fully wired end-to-end:
  1. `booking_date_screen` — calendar + time slot picker
  2. `booking_details_screen` — description, photo attachment (`image_picker`), payment method
  3. `booking_summary_screen` — itemized invoice view
  4. `booking_success_screen` — confirmation + navigation out
- Address management: `address_selection_screen` + `add_address_map_screen` (mock map styles)
- Bookings list (`bookings_screen`), Calendar view, Inbox threads, Chat detail, Call screen, Notifications screen

### Settings & Profile (5 screens)
- Profile screen with dark mode toggle (persisted via `StorageService`), role switcher, stats card
- Edit profile, Notification settings (toggles synced to storage), Security settings

### Provider-Side Suite (7 screens)
- Provider navigation shell, Provider setup (register as provider)
- Provider dashboard: online/offline toggle, incoming job cards with Accept/Decline
- **`request_details_screen`** — The most complete screen: AI-analyzed job description, photo section, mock map location, AI-predicted tool checklist (rule-based by service type), Accept/Decline actions that update `MockData.bookingStatus`
- Ongoing job step tracker (Arrived → Started → Completed)
- Storefront preview + edit business profile

### Infrastructure
- `flutter_local_notifications` — native push for reminders (Android + iOS, web bypassed)
- `MockData.addBooking()` auto-generates both customer + provider notifications
- `MockData.sendJobReminder()` triggers OS-level notification + in-app notification
- Theme persistence across restarts via SharedPreferences
- Role switcher (Client ↔ Provider) persisted

---

## 4. What's Mocked / Simulated (Not Real) ⚠️

| Feature | Current State | What's Missing |
|---|---|---|
| **Authentication** | Hardcoded user (`john@example.com`) | Real Firebase Auth / JWT tokens |
| **User database** | `currentUserName/Email` static fields | Firestore/Supabase `users` collection |
| **Provider database** | 3 seed providers in `SharedPreferences` | Real `providers` collection in DB |
| **Bookings** | Local list in `SharedPreferences` | Cloud bookings collection (real-time sync) |
| **AI matching** | Timed animation + static card display | Real ranking: distance (Maps API) + rating + availability |
| **Voice/text intent parsing** | Chat UI only (no NLP) | Speech-to-Text API + NLP intent extraction |
| **Location / Maps** | Mock vector art map painter | Google Maps SDK + real GPS coordinates |
| **Real-time chat** | Static text bubbles | WebSocket / Firestore real-time listeners |
| **Payment** | UI selection only (Cash/Card/Wallet) | Stripe / Google Pay / Apple Pay SDK |
| **OTP verification** | Any code accepted | Twilio / Firebase Phone Auth |
| **Provider availability** | Hardcoded `availableTimes` strings | Provider-set schedule in DB + AI cross-reference |
| **Push notifications** | Local only (same device) | FCM for cross-device provider/customer alerts |
| **Image upload** | `image_picker` picks file locally | Cloud Storage (Firebase/Supabase) upload + URL stored in DB |
| **Decline fallback (AI)** | Not implemented | Re-run ranking, remove declined provider, notify customer |
| **Reviews / Ratings** | Static mock values | Write-to-DB on booking completion |
| **Admin dashboard** | Not built | Provider location pins, analytics |

---

## 5. What the Brainstorm Doc Says to Build Next

The `HelperHive_AI_Brainstorm.md` defines the **real AI system**. Here's how it maps to missing pieces:

### Customer Flow (7 steps defined)
1. **Voice/Text Input → Intent Extraction** — needs Speech-to-Text API + NLP (service type, urgency, location hints)
2. **Location Resolution** — GPS coordinates mandatory; AI picks saved address or asks
3. **Issue Detail Questions** — per-service dynamic Q&A (currently only on `request_details_screen` for providers, not customer side)
4. **Provider Cards (ranked)** — needs real ranking: Maps distance + DB rating + DB availability + specialization
5. **Time Cross-Reference** — needs provider schedule in DB + AI conflict detection
6. **Confirmation Summary** — screen exists (`booking_summary_screen`) but needs real data flowing through
7. **Booking → Pending** — `MockData` has statuses but no cloud persistence

### Provider Flow
- **Incoming request** with AI issue summary + material prediction — `request_details_screen` does this with rule-based logic ✅ (needs real DB data)
- **Decline Fallback** — not implemented anywhere yet ❌
- **Availability Negotiation** — not implemented ❌

---

## 6. Backend Phase — What to Build

> [!IMPORTANT]
> This is what "starting the backend" means. Everything below is **not yet built** in the codebase.

### Priority 1 — Foundation (Required for anything to work)
- [ ] **Firebase Auth** — email/password + Google Sign-In (replace mock login)
- [ ] **Firestore schema** — `users`, `providers`, `bookings`, `notifications` collections
- [ ] **Address as GPS coordinates** — mandatory per brainstorm doc; store `{lat, lng}` not text
- [ ] **Migrate MockData → Firestore** — `addBooking()`, `updateBookingStatus()`, `addNotification()` all become Firestore writes

### Priority 2 — Core AI Features
- [ ] **Google Maps SDK** — real distance calculation between customer and provider coordinates
- [ ] **Provider ranking algorithm** — score = f(distance, rating, availability, specialization)
- [ ] **Dynamic issue Q&A on customer side** — currently only exists for providers; needs to be in booking flow
- [ ] **Speech-to-Text** (optional for hackathon) — `speech_to_text` pub package

### Priority 3 — Real-Time & Payments
- [ ] **FCM push notifications** — cross-device alerts when booking status changes
- [ ] **Firebase Storage** — upload `imagePaths` to cloud, store download URL in booking
- [ ] **Real-time chat** — Firestore listeners on `chat` sub-collection per booking
- [ ] **Decline Fallback** — backend function triggered on `status == 'Declined'` → re-rank → notify customer
- [ ] **Stripe payment** — replace mock payment UI

### Priority 4 — Missing Screens
- [ ] **Customer-side AI Q&A screen** — per-service follow-up questions during booking
- [ ] **Admin/analytics dashboard**
- [ ] **Review submission** — write rating to DB on job completion

---

## 7. Current Dependencies (pubspec.yaml)

```yaml
google_fonts: ^8.1.0        # Typography ✅
intl: ^0.19.0               # Date formatting ✅
shared_preferences: ^2.5.1  # Local storage ✅
url_launcher: ^6.3.1        # Maps link ✅
image_picker: ^1.2.2        # Photo attach ✅
flutter_local_notifications: ^21.0.0  # Native push ✅
logger: ^2.7.0              # Debug logging ✅
```

**Not yet added (needed for backend):**
```yaml
# To add:
firebase_core
firebase_auth
cloud_firestore
firebase_storage
firebase_messaging       # FCM
google_maps_flutter
speech_to_text           # optional
stripe_flutter           # optional
```

---

## 8. Quick Reference — Screen Count

| Category | Count | Status |
|---|---|---|
| Auth & Onboarding | 9 | ✅ UI complete, auth mocked |
| Customer Core | 11 | ✅ UI complete, data mocked |
| Settings & Profile | 5 | ✅ Complete with persistence |
| Messaging | 4 | ✅ UI complete, chat mocked |
| Provider Suite | 7 | ✅ UI complete, data mocked |
| **Total** | **36** | **Frontend done, backend = 0%** |

