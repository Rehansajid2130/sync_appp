# Walkthrough — Supabase Database & Authentication Integration

We have completed the transition of the application's mock persistence layer into a production-ready **Supabase backend (Authentication & PostgreSQL database)** with an elegant, compile-safe local database fallback.

---

## Changes Implemented

### 1. Project Dependencies

#### [MODIFY] [pubspec.yaml](file:///c:/Users/lenovo/Desktop/google/sync_app/pubspec.yaml)
- Added `supabase_flutter: ^2.6.0` dependency.
- Successfully resolved and retrieved packages via `flutter pub get`.

---

### 2. Configuration & Boot Setup

#### [NEW] [supabase_config.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/core/config/supabase_config.dart)
- Created central configurations for the Supabase endpoint:
  - **Supabase URL**: `https://mtcllacvjzjdkzfrmebu.supabase.co`
  - **Anon Key**: `sb_publishable_8ECN5MtzC3UAl_BZYQGyQg_w4K55pYa`
- Added the `isSupabaseActive` tracker flag to dynamically identify connection success.

#### [MODIFY] [main.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/main.dart)
- Imported `supabase_flutter` and initialized it inside a robust try-catch block inside `main()`.
- If the configuration is missing or initialization fails, it prints a clean warning and boots up in SharedPreferences fallback mode instead of crashing.

---

### 3. Authentication Upgrades

#### [MODIFY] [auth_service.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/core/services/auth_service.dart)
- Upgraded `signUp()`, `signIn()`, `signOut()`, `restoreSession()`, `updateProfile()`, and `changePassword()` to use `Supabase.instance.client.auth`.
- Created a PostgreSQL-mapped `profiles` table to store extra profile fields (such as `name`, `phone`, and `is_provider` status) associated with `auth.users`.
- Wrapped all remote requests with automatic SharedPreferences authentication fallback in case the device is offline or the backend has no schemas yet.

---

### 4. Persistence Layer Upgrades

#### [MODIFY] [mock_data.dart](file:///c:/Users/lenovo/Desktop/google/sync_app/lib/core/data/mock_data.dart)
- Redesigned the data persistence APIs (`MockData`) to run fully-reactive Supabase CRUD queries on active connections:
  - `loadProviders()`: Fetch from `service_providers` table. Automatically seeds the database if empty.
  - `loadBookings()`: Fetch client/provider bookings filtered by active user ID.
  - `addBooking()` & `updateBookingStatus()`: Insert and update PostgreSQL rows.
  - `loadAddresses()` & `saveAddresses()`: Map address listings.
  - `loadNotifications()` & `addNotification()`: Write and fetch app notification streams.
- Preserved all static getters and signatures exactly, ensuring that **zero screen-level visual layouts had to be edited**.

---

## Verification Results

### Dynamic Fallback & Credentials Verification
- Confirmed project ref `mtcllacvjzjdkzfrmebu` is fully configured in `supabase_config.dart`.
- The user has successfully executed the SQL DDL, making all database tables fully active in the Supabase backend.
- Verified that the application initializes flawlessly in dynamic SharedPreferences mode when Supabase is not reachable, with no startup crashes.

### Static Code Analysis
- Ran `flutter analyze` and resolved a missing material import in `lib/ai/state/chat_state.dart`. The entire application now compiles **100% cleanly** with zero compilation or syntax errors.

### Schema Blueprint (PostgreSQL DDL)
To initialize your Supabase tables in your [Supabase SQL Editor](https://supabase.com/dashboard/project/mtcllacvjzjdkzfrmebu/sql/new), you can use the following standard schema:

```sql
-- 1. Profiles Table (linked to Auth)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  name text not null,
  email text not null,
  phone text,
  is_provider boolean default false,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on Profiles
alter table public.profiles enable row level security;
create policy "Allow public profiles read access" on public.profiles for select using (true);
create policy "Allow users update own profiles" on public.profiles for update using (auth.uid() = id);

-- 2. Service Providers Table
create table public.service_providers (
  id text primary key,
  name text not null,
  category text not null,
  rating numeric not null,
  reviewCount integer not null,
  location text not null,
  iconCodePoint integer not null,
  colorValue bigint not null,
  priceRange text default '$$',
  availableTimes text[]
);

alter table public.service_providers enable row level security;
create policy "Allow public service_providers read access" on public.service_providers for select using (true);

-- 3. Bookings Table
create table public.bookings (
  id text primary key,
  service_name text not null,
  provider_name text not null,
  client_name text not null,
  status text default 'Upcoming',
  date timestamp with time zone not null,
  time text not null,
  icon_code_point integer not null,
  description text default '',
  image_paths text[] default '{}',
  client_id text,
  provider_id text
);

alter table public.bookings enable row level security;
create policy "Allow users read own bookings" on public.bookings for select using (auth.uid()::text = client_id or auth.uid()::text = provider_id);
create policy "Allow users insert own bookings" on public.bookings for insert with check (auth.uid()::text = client_id);
create policy "Allow users update own bookings" on public.bookings for update using (auth.uid()::text = client_id or auth.uid()::text = provider_id);

-- 4. Addresses Table
create table public.addresses (
  id bigserial primary key,
  title text not null,
  address text not null,
  latitude double precision not null,
  longitude double precision not null,
  is_selected boolean default false,
  is_main boolean default false,
  user_id uuid references auth.users on delete cascade
);

alter table public.addresses enable row level security;
create policy "Allow users manage own addresses" on public.addresses for all using (auth.uid() = user_id);

-- 5. Notifications Table
create table public.notifications (
  id text primary key,
  title text not null,
  subtitle text not null,
  icon_code_point integer not null,
  timestamp timestamp with time zone default timezone('utc'::text, now()) not null,
  is_read boolean default false,
  user_id text
);

alter table public.notifications enable row level security;
create policy "Allow users read own notifications" on public.notifications for select using (auth.uid()::text = user_id);
create policy "Allow users insert own notifications" on public.notifications for insert with check (auth.uid()::text = user_id);
```
