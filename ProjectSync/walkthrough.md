# UI Migration Walkthrough
## Classic → Soft-Morphism New UI: Complete

All 10 classic screens have been upgraded **in-place** — original filenames, class names, and constructors are fully preserved so every existing route, deep link, and import continues to work without modification.

---

## Design System Applied

| Token | Value |
|---|---|
| **Typography** | Nunito (Google Fonts) — weights 600 → 900 |
| **Primary Accent** | `AppColors.deepTeal` |
| **Secondary Accent** | `AppColors.pastelBlue` / `AppColors.primary` |
| **Border Radius** | 24–32px rounded cards (Soft-Morphism) |
| **Surfaces** | `AppColors.surfaceLightGray` (light) / `Color(0xFF090909)` (dark) |
| **Shadows** | Subtle layered shadows at 0.03–0.08 opacity |
| **Dark Mode** | Full support via `Theme.of(context).brightness` |

---

## Screens Upgraded

### 1. [main_navigation_screen.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/screens/main_navigation_screen.dart)
Replaced classic `BottomNavigationBar` with a curved floating bottom bar — translucent container with gradient active tab indicator and icon-only navigation.

### 2. [home_dashboard_screen.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/screens/home_dashboard_screen.dart)
Full discovery dashboard with:
- Nunito-styled search field with filter icon
- Horizontal scrollable category tags (All, Cleaning, Repair, Beauty …)
- Premium promo hero card with gradient
- Discovery service cards with ratings and distance

### 3. [login_screen.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/screens/login_screen.dart)
Immersive full-screen background image with a frosted bottom-sheet authentication card. Handles both Login and Signup modes. Supabase auth integration intact.

### 4. [signup_screen.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/screens/signup_screen.dart)
Same auth layout as login, pre-set to `_isLoginMode = false` (registration mode). Matches the shared Soft-UI auth card aesthetic.

### 5. [search_results_screen.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/screens/search_results_screen.dart)
Modern search results feed with:
- Live-updating `query` parameter display
- Horizontal scrollable dynamic filter chips
- Rounded provider result cards with specialty tags and ratings

### 6. [service_detail_screen.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/screens/service_detail_screen.dart)
Collapsing `SliverAppBar` with hero image, smooth scroll-up reveal, star ratings summary, and tabbed sections (Overview / Reviews / Portfolio). Supports both `ServiceProvider? provider` and `Map<String,dynamic>? providerData` so all routes work.

### 7. [calendar_screen.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/screens/calendar_screen.dart)
- Horizontal **Weekly Date Ribbon** (`WeeklyDateRibbon` widget)
- Agenda timeline list (`EventAgendaCard` widget)
- Radial analog time picker bottom sheet (`RadialTimePicker` widget)
- Fixed stale `../models/booking.dart` import → `../models/service_provider.dart`

### 8. [inbox_screen.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/screens/inbox_screen.dart)
Replaced classic tab-bar chat list with:
- Lock-state empty view when no active bookings
- Active booking list with avatar + green online dot
- `NEW` badge on pending bookings
- Preserved `isProvider` param + added `VoidCallback? onBackTap`

### 9. [chat_detail_screen.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/screens/chat_detail_screen.dart)
Full chat screen upgrade with:
- Provider avatar + online status in header
- Video & audio call action buttons
- `StreamBuilder<List<ChatMessage>>` real-time message feed
- Asymmetric chat bubbles (teal outgoing / white incoming)
- Emoji + attach + camera icons in input capsule
- Backward-compat with legacy `Booking? booking` and `ServiceProvider? provider` params

### 10. [profile_screen.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/screens/profile_screen.dart)
Settings screen with:
- Gradient-ringed user avatar with camera edit button
- Invite Friends promo hero card (purple gradient)
- Settings menu inside a rounded card (navigation, theme toggle, provider switch, logout)
- Smooth logout dialog with red confirm button
- Added `VoidCallback? onBackTap` param (required by `MainNavigationScreen`)

---

## Backward-Compatibility Notes

- All class names unchanged: `InboxScreen`, `ChatDetailScreen`, `ProfileScreen`, etc.
- `ChatDetailScreen` accepts `Booking?`, `ServiceProvider?`, **and** the new `Map<String,dynamic>? chatArguments`
- `ProfileScreen` logout navigates to `LoginScreen` (already upgraded to new auth UI)
- No changes to `app_routes.dart` or any route declarations

---

## Verification

```
flutter analyze --no-pub
→ 0 compilation errors
→ Info-only warnings (deprecated withOpacity) are pre-existing project-wide, not blockers
```

> [!TIP]
> You can now safely delete `lib/screens/new_ui/` showcase files once you confirm the app feels right in a hot-reload session — they are no longer needed.
