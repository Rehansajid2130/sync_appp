# Task List — Supabase Database & Authentication Integration

- `[x]` **Task 1: Add Supabase Flutter Dependency**
  - Modify `pubspec.yaml` to include `supabase_flutter`.
  - Run `flutter pub get` to download and link packages.
- `[x]` **Task 2: Build Safe Supabase Configuration & Services**
  - Create `supabase_config.dart` with a fallback configuration matching standard Supabase URL and Anon key placeholders.
  - Set up `isSupabaseActive` connection state tracker.
- `[x]` **Task 3: Refactor Authentication Service to Supabase Auth**
  - Update `auth_service.dart` to support real signing, account creation, profile modifications, and session restorations using Supabase Auth.
  - Map user registration profile details into a PostgreSQL `profiles` table.
  - Wrap Supabase requests with safety handlers to fall back automatically to the local SharedPreferences store if offline.
- `[x]` **Task 4: Integrate MockData to Supabase Table Sync**
  - Upgrade `mock_data.dart` to sync all main tables (providers, bookings, addresses, notifications) with Supabase database when active.
  - Implement automatic first-time Supabase table seeding for providers.
- `[x]` **Task 5: Upgrade App Startup & Verification**
  - Modify `main.dart` to initialize Supabase safely in `main()` with standard try-catch protection.
  - Run `flutter analyze` to verify absolute compilation, service, and routing integrity.
