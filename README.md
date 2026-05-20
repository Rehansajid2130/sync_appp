# HelperHive - AI-Powered Service Marketplace

HelperHive is a next-generation service marketplace application built with Flutter and Supabase. It features an intelligent AI orchestration layer that simplifies the process of finding, booking, and managing home services like AC repair, plumbing, and electrical work.

## 🚀 Key Features

### 🧠 AI Orchestration (The "AI Brain")
The heart of HelperHive is its simulated AI system, which handles the complex logic of service matching:
- **Natural Language Intent Extraction**: Converts user voice or text requests (e.g., "Fix my AC in DHA tomorrow") into structured service requirements.
- **Smart Location Resolution**: Automatically checks saved addresses and confirms the exact location using map coordinates.
- **Dynamic Issue Clarification**: Asks service-specific follow-up questions to generate a detailed briefing for the provider.
- **Intelligent Provider Ranking**: Matches users with the best providers based on distance, rating, availability, and specialization.
- **Material & Tool Prediction**: Analyzes the reported issue to suggest the likely tools and parts the provider should bring.

### 🔐 Modern Authentication & Direct Password Reset
- **Seamless Auth**: Integrated with Supabase Auth for secure login and registration.
- **Direct Password Reset**: A custom-built, demo-friendly flow that allows users to reset their passwords directly without waiting for email confirmation.
- **Role-Based Access**: Dedicated interfaces for both Customers and Service Providers.

### 📍 Location-Based Services
- **Map Integration**: Interactive maps for setting addresses and tracking service locations.
- **GPS-Precision**: All addresses are stored as coordinates to ensure accurate distance calculations and navigation.

## 🛠️ Project Structure

- `lib/ai/`: Contains the logic, state management, and widgets for the AI orchestration flow.
- `lib/core/`: Core services including `AuthService`, `SupabaseConfig`, and `MockData`.
- `lib/screens/`: UI screens for onboarding, authentication, booking, and profile management.
- `lib/widgets/`: Reusable UI components following the project's design system.

## ⚙️ Setup & Installation

1. **Prerequisites**:
   - Flutter SDK (latest stable version)
   - Supabase project set up

2. **Database Configuration**:
   The project uses a custom `profiles` table fallback for direct password resets. Ensure your Supabase database has the following structure:
   ```sql
   ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT;
   ALTER TABLE profiles ADD COLUMN IF NOT EXISTS temp_password TEXT;
   CREATE INDEX IF NOT EXISTS profiles_email_idx ON profiles (email);
   ```

3. **Running the App**:
   ```bash
   flutter pub get
   flutter run
   ```

## 🤖 AI Functionality Breakdown

HelperHive's AI is designed to feel "alive." It doesn't just show a list of names; it guides the user through a conversation:
1. **Agent Workflow**: Users see a transparent AI processing screen where agents (Intent Agent, Location Agent, etc.) work in sequence.
2. **Context Awareness**: If a user mentions "Home" or "Office," the AI knows which saved coordinate to use.
3. **Provider Briefing**: Providers don't just get a notification; they get an AI-generated summary of the problem and a list of recommended tools.

---

*This project was developed for a hackathon to demonstrate the future of AI-driven service marketplaces.*
