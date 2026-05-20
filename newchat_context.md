# HelperHive Flutter App — New Chat Context File
> Created: 2026-05-15 | Hand off document for continuing development in a new session.

---

## 1. PROJECT OVERVIEW

- **App Name:** HelperHive
- **Type:** Flutter mobile app (runs on Android, iOS, Windows Desktop, Web)
- **Purpose:** An on-demand home services marketplace — users can search for local service providers (cleaners, repairers, painters, plumbers, etc.) and book them.
- **Project Location:** `c:\Users\lenovo\Desktop\google\sync_app`
- **Flutter run command:** `flutter run` (already running in terminal)
- **Hot Restart:** Press `Shift + R` in terminal (always do this after structural changes, not just `r`)

---

## 2. DESIGN SYSTEM (Core Theme)

All theme files live in: `lib/core/theme/`

### `app_colors.dart`
- `AppColors.primary` — Main green brand color
- `AppColors.primaryLight` — Light green for backgrounds/badges
- `AppColors.surfaceLight` — Light grey page background
- `AppColors.textPrimaryLight` — Dark text
- `AppColors.textSecondaryLight` — Medium grey text
- `AppColors.textMutedLight` — Light grey / placeholder text

### `app_typography.dart`
- Uses **Google Fonts — Inter** for all text
- Access via: `AppTypography.textTheme.bodyLarge`, `.titleMedium`, `.displayLarge`, etc.

### `app_theme.dart`
- Applied globally in `main.dart` via `theme: AppTheme.light`

---

## 3. REUSABLE WIDGETS (lib/widgets/)

| File | Purpose |
|------|---------|
| `brand_logo.dart` | HelperHive logo with icon + text |
| `circular_progress_button.dart` | Animated circular progress button used on onboarding |
| `curved_header_clipper.dart` | Custom clipper for curved header sections |
| `custom_text_field.dart` | Shared input field used across login/signup/password screens |
| `page_indicator.dart` | Dot indicators for the onboarding PageView |
| `social_auth_button.dart` | Full-width social login button (Google, Apple) |
| `social_circle_button.dart` | Circular icon social login button |

---

## 4. ALL SCREENS BUILT (lib/screens/)

### ✅ COMPLETED SCREENS

#### `splash_screen.dart`
- Shows brand logo for 3 seconds, then navigates to Onboarding

#### `onboarding_screen.dart`
- 3-page PageView with circular progress button
- Page indicators at the bottom
- Navigates to `LoginScreen` on completion

#### `login_screen.dart`
- First login/auth choice screen
- Has Google and Apple `SocialAuthButton` widgets
- "Sign in with Email" button navigates to `EmailLoginScreen`
- Google/Apple buttons navigate to `MainNavigationScreen` (existing user flow)
- Import needed: `address_setup_screen.dart`, `email_login_screen.dart`, `main_navigation_screen.dart`

#### `email_login_screen.dart`
- Email + Password input with `CustomTextField`
- "Remember me" checkbox + "Forgot Password?" link
- Login button → navigates to `MainNavigationScreen`
- Google/Apple circle buttons → `MainNavigationScreen`
- "Register" link → `SignupScreen`
- "Forgot Password?" → `ResetPasswordScreen`

#### `signup_screen.dart`
- Name, Email, Password fields
- Register button → navigates to `OtpVerificationScreen(isFromSignup: true)`
- "Login" link → pops back

#### `otp_verification_screen.dart`
- 4 OTP input boxes with auto-focus
- Has `isFromSignup` bool parameter
  - If `isFromSignup: true` → Confirm button shows success dialog → "Continue to Login" → navigates to `EmailLoginScreen` (clears all routes)
  - If `isFromSignup: false` (forgot password flow) → Confirm → `CreateNewPasswordScreen`
- Used for BOTH signup OTP AND password reset OTP

#### `reset_password_screen.dart`
- Enter email to receive OTP
- Navigates to `OtpVerificationScreen(isFromSignup: false)`

#### `create_new_password_screen.dart`
- New Password + Confirm Password fields
- After success, navigates back to login

#### `address_setup_screen.dart`
- **Location Permission Popup** shows automatically on `initState` via `addPostFrameCallback`
- Top half: Mock map with decorative streets and a user avatar pin
- Bottom half: White rounded sheet with:
  - "Add your new home address" title
  - Multi-line `TextField` pre-filled with `"123 Main Street, New York, NY 10001"`
  - Cancel button (pops back), Add Address button → navigates to `MainNavigationScreen`
- **Logic:** This screen appears for new users after registration / first login

#### `main_navigation_screen.dart`
- The root of the app after login
- Contains bottom navigation bar (pill-shaped)
- Uses `IndexedStack` with tabs:
  - Tab 0: `HomeDashboardScreen` (Home)
  - Tab 1: (Bookings — not built yet)
  - Tab 2: (Messages — not built yet)
  - Tab 3: (Profile — not built yet)

#### `home_dashboard_screen.dart`
- Header: user avatar, greeting "Hello Fajar Kun 👋", location row (tappable → `AddressSetupScreen`)
- Green search icon (tappable → `SearchResultsScreen`)
- Bell notification icon (tappable → `NotificationsScreen`)
- Promo banner (green gradient card)
- Services grid (8 categories: Cleaning, Repairing, Painting, Laundry, Appliance, Plumbing, Shifting, More)
- Popular Services list (2 gradient cards)

#### `notifications_screen.dart`
- Tabbed view: "All" and "Unread"
- Grouped notification list items with icons and timestamps

#### `search_results_screen.dart`
- **IMPORTANT: This screen has a known navigation bug — cards are NOT navigating to ServiceDetailScreen when tapped. This is the #1 issue to fix in the new chat.**
- Has 3 states:
  1. **Initial** — Popular search tags shown
  2. **Results** — List of provider cards
  3. **Empty/Not Available** — Shows "Service Not Available" with icon
- Filter chips at top: All, Cleaning, Repairing, Painting, Laundry, Plumbing
- Search bar in AppBar with clear button
- `ServiceProvider` data model is defined IN this file (not a separate model file)
- 8 demo providers in `_allProviders` list
- Card click should call `_openDetail(provider)` → `Navigator.push` to `ServiceDetailScreen`
- **BUG:** Despite multiple fix attempts using GestureDetector with `HitTestBehavior.opaque` and `IgnorePointer` on child elements, the card tap is still not navigating. New chat must debug and fix this.

#### `service_detail_screen.dart`
- Full provider detail page matching design images
- Has `SliverAppBar` with collapsing hero section
- Imports `ServiceProvider` class from `search_results_screen.dart`
- Sections:
  - Hero image (mock with provider icon + decorative circles)
  - "Popular Service" label + service title + bookmark toggle
  - Star rating + review count
  - Category + Location tag chips
  - Description with "Read more / Show less" toggle
  - Photos grid (3 placeholders with +10 overlay on third)
  - Reviews section (3 demo reviews: Sarah T., Michael Wong, Emily R.)
- Bottom sticky bar: Chat icon button + "Book Now" green button
- **NOTE: "Book Now" button has no navigation yet (TODO)**

---

## 5. NAVIGATION FLOW

```
SplashScreen (3s)
    └─> OnboardingScreen (3 pages)
            └─> LoginScreen
                    ├─> EmailLoginScreen
                    │       ├─> Login button ──────────────────────> MainNavigationScreen
                    │       ├─> Forgot Password ──────────────────> ResetPasswordScreen
                    │       │                                               └─> OtpVerificationScreen(isFromSignup: false)
                    │       │                                                       └─> CreateNewPasswordScreen
                    │       └─> Register link ──────────────────────> SignupScreen
                    │                                                       └─> OtpVerificationScreen(isFromSignup: true)
                    │                                                               └─> Success Dialog
                    │                                                                       └─> EmailLoginScreen (clears stack)
                    └─> Google/Apple buttons ──────────────────────> MainNavigationScreen
                    
MainNavigationScreen
    ├─> Tab 0: HomeDashboardScreen
    │       ├─> Location row tap ──────────────────────────────────> AddressSetupScreen
    │       │                                                               └─> Add Address ──> MainNavigationScreen
    │       ├─> Search icon tap ───────────────────────────────────> SearchResultsScreen
    │       │                                                               └─> Card tap ──> ServiceDetailScreen (BUGGED)
    │       └─> Bell icon tap ─────────────────────────────────────> NotificationsScreen
    ├─> Tab 1: (Bookings — NOT BUILT)
    ├─> Tab 2: (Messages — NOT BUILT)
    └─> Tab 3: (Profile — NOT BUILT)
```

---

## 6. KNOWN BUGS & ISSUES

### 🔴 BUG #1 (Critical): Search Result Cards Not Navigating
- **File:** `lib/screens/search_results_screen.dart`
- **Method:** `_buildProviderCard()`
- **Problem:** Tapping any search result card (including the arrow button) does not navigate to `ServiceDetailScreen`
- **What was tried:**
  - `GestureDetector` with `onTap` — didn't work
  - `Material` + `InkWell` with `onTap` — didn't work  
  - `GestureDetector` with `behavior: HitTestBehavior.opaque` — didn't work
  - `IgnorePointer` around the arrow button — didn't work
- **Suspected causes in new chat:** 
  - Possible compile error in `service_detail_screen.dart` that prevents navigation silently
  - Possible import/class name conflict (`Container` class conflict was seen in lint errors)
  - Check if the `ServiceDetailScreen` screen itself compiles without errors
  - Try wrapping entire card in `TextButton` or `ElevatedButton` as a last resort test
  - Check if `service_detail_screen.dart` imports `search_results_screen.dart` creating a circular import

### 🟡 ISSUE #2: Circular Import Risk
- `service_detail_screen.dart` imports `search_results_screen.dart` (to access `ServiceProvider` class)
- `search_results_screen.dart` imports `service_detail_screen.dart` (to navigate to it)
- **This creates a circular dependency.** This is likely the ROOT CAUSE of the navigation bug.
- **Fix:** Move `ServiceProvider` model class into its own file: `lib/models/service_provider.dart`, then both screens import from there.

### 🟡 ISSUE #3: Address Screen Logic for New vs Returning Users
- Currently the Location Permission popup always shows when `AddressSetupScreen` opens
- For new users: Should show on first login automatically
- For returning users: Should only show if they tap the location in the dashboard
- Fix requires a simple `isNewUser` boolean flag passed as a constructor parameter

---

## 7. SCREENS STILL TO BUILD (from original roadmap)

| Screen | Status | Notes |
|--------|--------|-------|
| Search Results | ✅ Built | Has card navigation bug |
| Service Detail | ✅ Built | Book Now not wired |
| **My Bookings / Schedule** | ❌ Not started | Tab 1 in bottom nav |
| **Messaging / Chat** | ❌ Not started | Tab 2 in bottom nav |
| **User Profile / Settings** | ❌ Not started | Tab 3 in bottom nav |
| **Booking Flow** | ❌ Not started | After tapping "Book Now" |

---

## 8. KEY IMPLEMENTATION PATTERNS USED

### Navigation Pattern
- **Auth flow:** `Navigator.pushReplacement` or `Navigator.pushAndRemoveUntil` (can't go back)
- **Normal screens:** `Navigator.push` (can go back with back button)
- **After registration:** `Navigator.pushAndRemoveUntil` to clear the entire stack back to `EmailLoginScreen`

### State Management
- Currently uses only `StatefulWidget` + `setState` — NO external state management (no Provider, no Riverpod)
- This is fine for now but will need Provider/Riverpod when adding real user data

### Styling Pattern
```dart
// Always use this pattern for text:
style: AppTypography.textTheme.bodyLarge?.copyWith(
  color: AppColors.textPrimaryLight,
  fontWeight: FontWeight.w600,
),

// Always use AppColors constants — never hardcode colors
color: AppColors.primary // ✅ 
color: Color(0xFF4CAF50) // ❌ (unless in the demo data lists)
```

### Button Pattern (standard green button)
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
  ),
  child: Text('Label', style: AppTypography.textTheme.bodyLarge?.copyWith(
    color: Colors.white, fontWeight: FontWeight.w600,
  )),
)
```

---

## 9. FIRST THING TO DO IN NEW CHAT

**Step 1: Fix the circular import bug.**
Create `lib/models/service_provider.dart` with just the `ServiceProvider` class.
Remove it from `search_results_screen.dart`.
Update import in `service_detail_screen.dart` to use the new model file.
This will very likely fix the card navigation bug.

**Step 2: Verify navigation works** by hot restarting and testing the full search → card tap → detail flow.

**Step 3: Continue with the next screen** — My Bookings tab (Tab 1 in bottom navigation).
