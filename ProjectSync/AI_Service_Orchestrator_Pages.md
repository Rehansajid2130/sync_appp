# AI Service Orchestrator — Complete Page Structure
**Challenge 2: AI Service Orchestrator for Informal Economy**

The UI flow demonstrates: user request → AI understanding → provider matching → AI reasoning → user selection → booking simulation → follow-up automation → live workflow tracking

---

# USER SIDE PAGES

---

## 1. Splash Screen

### Purpose
Initial branding and app initialization.

### This Page Will Have
1. App logo
2. App name
3. Tagline — "AI Powered Local Services"
4. Loading animation
5. Background initialization
   - Check login state
   - Load saved session
   - Initialize AI agents

### Navigation
- Logged in → Home Page
- Not logged in → Welcome Page

---

## 2. Welcome / Onboarding Page

### Purpose
Introduce the app and explain what it does.

### This Page Will Have
1. Intro slides
   - Find nearby technicians
   - AI booking automation
   - Urdu/Roman Urdu support
   - Live service tracking
2. Buttons
   - Login
   - Signup
   - Continue as Guest
3. Language selection
   - English
   - Urdu

### Guest Flow Note
Guest users can browse the Home Page and view providers but cannot submit a service request. When they tap any action that requires an account (Search, Book, Chat), a prompt appears: "Please sign in to continue" with Login and Signup buttons. No data is saved for guest sessions.

### Navigation
- Login → Login Page
- Signup → Signup Page
- Guest → Home Page (limited mode)

---

## 3. Login Page

### Purpose
Allow users to log into their account.

### This Page Will Have
1. Greeting — "Welcome Back"
2. Inputs
   - Phone/Email
   - Password
3. Buttons
   - Login
   - Continue with Google
   - Continue with Phone OTP
4. Forgot password link
5. Signup redirect
6. Remember me checkbox

### Functionality
- Validates credentials
- Creates user session
- Fetches saved addresses and bookings

### Navigation
- Successful login → Home Page
- Signup redirect → Signup Page
- Forgot password → Reset Password Page

---

## 4. Reset Password Page

### Purpose
Let users recover access to their account.

### This Page Will Have
1. Phone/Email input
2. OTP input field (after sending)
3. New password input
4. Confirm password input
5. Submit button

### Functionality
- Sends OTP to registered phone/email
- Validates new password
- Updates credentials

### Navigation
- Success → Login Page

---

## 5. Signup Page

### Purpose
Create a new user account.

### This Page Will Have
1. Inputs
   - Full name
   - Phone number
   - Email
   - Password
2. Location permission request
3. Profile image upload (optional)
4. Buttons
   - Create Account
   - Login redirect

### Functionality
- Creates user profile
- Stores user data
- Triggers address setup

### Navigation
- Account created → Address Setup Page
- Login redirect → Login Page

---

## 6. Address Setup Page

### Purpose
Collect the user's precise location for accurate provider matching.

### This Page Will Have
1. Map picker
2. Current location button
3. Manual address input
4. Saved addresses section
5. Address label options — Home / Office / Other

### Functionality
- Saves precise GPS coordinates
- Reverse geocoding (converts pin to readable address)
- Stores locations in database for future use

### Navigation
- Continue → Home Page

---

## 7. Home Page

### Purpose
Main dashboard for users.

### This Page Will Have
1. Greeting — "Assalamualaikum, [Name]"
2. Search bar — "What service do you need?"
3. Voice input button
4. Quick service categories
   - AC Technician
   - Electrician
   - Plumber
   - Beautician
   - Tutor
   - Carpenter
5. AI suggestion section (based on past bookings and season)
6. Nearby providers preview
7. Recent bookings section
8. Bottom navigation
   - Home
   - Bookings
   - Chat
   - Profile

### Functionality
- Accepts natural language input
- AI intent extraction on search
- Category tap pre-fills service type in request form

### Guest Restriction
- Search bar and categories visible
- Tapping any of them shows sign-in prompt

### Navigation
- Search → AI Service Request Page
- Category tap → AI Service Request Page (pre-filled)
- Recent booking → Booking Details Page

---

## 8. AI Service Request Page

### Purpose
Collect service request details in a natural, conversational way.

### This Page Will Have
1. Chat-like input box
2. Voice recording option
3. Suggested prompts
   - "Mujhe kal electrician chahiye"
   - "Need AC repair tomorrow"
   - "Geyser repair in DHA"
4. Image upload option (show the issue)
5. Schedule selector (date and time)
6. Location selector (from saved addresses or new pin)

### Functionality
AI extracts from input:
- Service type
- Preferred time
- Urgency level
- Location
- Issue description

### Navigation
- Submit → AI Processing Page

---

## 9. AI Processing / Agent Workflow Page

### Purpose
Show live AI orchestration happening in real time.

### This Page Will Have
1. Animated workflow steps with live progress
2. Agent cards with status indicators
   - Intent Agent — understanding the request
   - Location Agent — resolving address and radius
   - Provider Search Agent — finding available providers
   - Ranking Agent — scoring providers
3. Live reasoning log
   - "Detected AC repair request"
   - "Searching providers within 5km"
   - "Ranking based on ratings, distance, and specialization"
4. Progress timeline (visual step indicator)
5. Short explainer — "Our AI is finding the best match for you"

### Functionality
Simulates multi-agent orchestration with realistic delays between steps to show actual workflow reasoning, not instant results.

### Navigation
- Workflow complete → Provider Recommendation Page

---

## 10. Provider Recommendation Page

### Purpose
Present AI-ranked provider options and let the user choose.

### This Page Will Have
1. Page heading — "Here are your best matches"
2. Provider cards (list of 3–5 options), each showing:
   - Provider image and name
   - Distance
   - Overall rating (stars + number of reviews)
   - Availability status
   - Estimated arrival time
   - Price estimate
   - Worker specializations
   - AI Reasoning Card (expandable)
     - Example: "Ranked #1 — nearest available inverter AC specialist with 4.8 rating and 3 confirmed slots today"
3. Compare button (select two providers side by side)
4. Per card buttons: Book Now / Chat / View Profile

### Important
The AI presents and explains. The user decides. No auto-selection.

### Functionality
- AI scoring breakdown visible per provider
- User can expand reasoning card to see what factors were used
- Comparison mode shows two providers' details side by side

### Navigation
- Book Now → Booking Confirmation Page
- View Profile → Provider Details Page
- Chat → Chat Page

---

## 11. Provider Details Page

### Purpose
Full information about a specific provider before booking.

### This Page Will Have
1. Provider profile photo and name
2. Shop name and description
3. Years of experience
4. Skills and certifications
5. Worker list with individual specializations
   - Example: Ali — AC Installation, Inverter Repair
   - Example: Usman — Gas Refill, Wiring
6. Ratings breakdown (cleanliness, punctuality, skill, communication)
7. Customer reviews
8. Portfolio images (past work)
9. Available time slots
10. Service coverage map

### Navigation
- Book button → Booking Confirmation Page
- Back → Provider Recommendation Page

---

## 12. Provider Comparison Page

### Purpose
Side-by-side comparison of two selected providers.

### This Page Will Have
1. Two provider cards side by side
2. Comparison rows
   - Distance
   - Rating
   - Price estimate
   - Availability
   - Specialization match
   - AI score
3. Select button under each provider

### Navigation
- Select → Booking Confirmation Page (with selected provider)

---

## 13. Booking Confirmation Page

### Purpose
Review and confirm booking details before submission.

### This Page Will Have
1. Service summary
2. Selected provider details
3. Assigned worker (if provider has assigned one)
4. Selected date and time
5. Service address
6. Estimated charges
7. Payment method — Cash on Delivery (display only, no payment processing)
8. Notes section (anything extra for the provider)
9. Buttons
   - Confirm Booking
   - Reschedule
   - Change Provider (goes back to recommendation page)

### Functionality
Simulates:
- Booking creation
- Worker assignment
- Notification creation
- Scheduling record

### Navigation
- Confirm → Booking Success Page

---

## 14. Booking Success Page

### Purpose
Confirm the booking was created successfully.

### This Page Will Have
1. Success animation
2. Booking ID
3. Technician assigned name
4. Estimated arrival time
5. Reminder info
6. Download receipt button
7. Share booking button

### Functionality
Creates:
- Mock receipt (PDF or shareable card)
- Booking record in database
- Reminder schedule for follow-up automation

### Navigation
- Track Service → Live Tracking Page
- Home → Home Page

---

## 15. Live Service Tracking Page

### Purpose
Let the user follow service progress in real time.

### This Page Will Have
1. Status timeline
   - Booking Confirmed
   - Worker Assigned
   - Left Shop
   - Arriving Soon
   - Service Completed
2. Simulated live map with provider pin moving
3. ETA display
4. Provider contact button
5. Chat button
6. Cancel booking button (only before worker leaves)

### Functionality
Simulates:
- Real-time status updates (timed transitions)
- Location tracking
- Push notifications at each stage

### Navigation
- Chat → Chat Page
- Completion → Feedback Page

---

## 16. Chat Page

### Purpose
Communication channel between user and provider.

### This Page Will Have
1. Real-time chat interface
2. Image sharing (show the issue, location access)
3. Voice notes
4. AI-generated suggested replies
5. AI summary of conversation (collapsible)

### Functionality
- Material coordination before visit
- Issue clarification
- AI summarizes long threads for the provider

### Navigation
- Back → Previous page

---

## 17. Follow-Up Automation Page

### Purpose
Show AI-generated reminders and post-service automation.

### This Page Will Have
1. Reminder cards (upcoming appointment alerts)
2. Completion confirmation card
3. Feedback request card
4. Rebooking suggestion (if recurring service like AC cleaning)
5. AI-generated summary of last service

### Functionality
Simulates:
- Automated notification scheduling
- Follow-up workflow triggers
- AI-generated reminder messages

### Navigation
- Feedback button → Feedback Page

---

## 18. Feedback & Rating Page

### Purpose
Dual rating system — user rates provider, provider rates user.

### This Page Will Have
1. Star rating (1–5)
2. Written review
3. Specific feedback categories
   - Punctuality
   - Skill level
   - Communication
   - Cleanliness
4. Issue resolved toggle (Yes / No)
5. Customer rating from provider's side (shown after both submit)

### Functionality
- Updates both reputation scores
- Feeds back into AI ranking algorithm for future recommendations

### Navigation
- Submit → Home Page

---

## 19. Payment Summary Page

### Purpose
Record what the user paid for each completed service. Not a payment gateway — cash only. This data is stored for future AI spend-pattern suggestions.

### This Page Will Have
1. Service name and date
2. Provider name
3. Final amount paid (cash)
4. Breakdown
   - Labour cost
   - Materials (if any)
   - Any extras discussed during chat
5. Comparison to original estimate
6. Save/Confirm button
7. Download receipt button

### Functionality
- Stores payment record per booking
- Compares actual cost to estimate (feeds suggestion model)
- No payment processing — cash confirmation only

### Navigation
- Done → Booking Details Page or Home

---

## 20. Booking History Page

### Purpose
Show all past bookings.

### This Page Will Have
1. List of bookings with status labels
   - Completed
   - Cancelled
   - Upcoming
2. Rebook button per booking
3. Download receipt button
4. View details link

### Functionality
- Fetches booking history
- Enables repeat booking with same provider

### Navigation
- Booking tap → Booking Details Page

---

## 21. Booking Details Page

### Purpose
Full detail view of a single booking.

### This Page Will Have
1. Complete booking timeline
2. Provider and worker details
3. Payment summary (what was paid in cash)
4. Chat history
5. Tracking logs
6. AI workflow logs (full agent trace for this booking)

### Navigation
- Rebook → Booking Confirmation Page (pre-filled)

---

## 22. Notifications Page

### Purpose
Central notification system.

### This Page Will Have
1. Booking status updates
2. Reminder notifications
3. AI alerts (e.g. provider running late)
4. Follow-up prompts (feedback, rebooking)
5. Provider responses

### Functionality
- Notification history
- Mark as read
- Tap to navigate to relevant page

---

## 23. Profile Page

### Purpose
User account management and settings.

### This Page Will Have

**Profile Section**
1. Profile photo
2. Full name
3. Phone number
4. Email
5. Edit profile button

**Saved Addresses**
6. List of saved addresses with labels
7. Add new address button

**Preferences**
8. Language preference (English / Urdu)
9. Notification preferences toggle

**App Settings**
10. Dark mode toggle
11. Clear cache
12. About the app
13. Privacy policy
14. Help & Support

**Account**
15. Logout button
16. Delete account option

---

---

# PROVIDER SIDE PAGES

---

## 24. Provider Welcome Page

### Purpose
Separate entry point for service providers.

### This Page Will Have
1. "Join as a Service Provider" heading
2. Brief explanation of the platform
3. Buttons
   - Provider Login
   - Register Your Shop

### Navigation
- Login → Provider Login Page
- Register → Provider Signup Page

---

## 25. Provider Signup Page

### Purpose
Register a new shop on the platform.

### This Page Will Have
1. Inputs
   - Shop name
   - Owner name
   - Phone number
   - Email
   - Service category (AC, Electrician, Plumber, etc.)
   - Shop address with map pin
2. Business hours setup
3. Profile/shop image upload
4. Create Account button

### Functionality
- Creates provider profile
- Sets service area radius
- Triggers worker setup after account creation

### Navigation
- Account created → Worker Setup Page

---

## 26. Provider Login Page

### Purpose
Authentication for existing providers.

### This Page Will Have
1. Shop login (email/phone + password)
2. OTP verification option
3. Forgot password link
4. Register redirect

### Navigation
- Success → Provider Dashboard

---

## 27. Provider Dashboard

### Purpose
Main control center for the shop.

### This Page Will Have
1. Active bookings summary
2. Pending requests (new incoming)
3. AI-assigned tasks
4. Worker availability overview
5. Today's schedule
6. Revenue summary (total cash collected today/this week)
7. Notifications panel
8. Bottom navigation
   - Dashboard
   - Requests
   - Workers
   - Profile

### Functionality
- Booking management
- Quick accept/reject on pending requests
- Worker assignment

---

## 28. Incoming Request Details Page

### Purpose
Let the provider review a customer's request before accepting.

### This Page Will Have
1. Customer issue description
2. Uploaded images or videos from customer
3. Required date and time
4. Customer location on map
5. AI-generated issue summary
6. AI suggested materials/tools needed
7. Buttons
   - Accept Request
   - Propose Different Time
   - Decline

### Functionality
- AI summarizes the issue for the provider
- AI predicts required materials based on issue type
- Helps technician prepare before arrival

### Navigation
- Accept → Booking active, goes to Provider Active Bookings
- Propose Different Time → Availability Negotiation Page

---

## 29. Availability Negotiation Page

### Purpose
AI-simulated scheduling negotiation between provider and system.

### This Page Will Have
1. Customer's requested time
2. AI-suggested alternative slots (if provider is busy)
3. Chat-like interface showing the negotiation
4. Accept / Propose Another Time / Decline buttons
5. Final confirmed slot display

### Functionality
Simulates:
- AI checking provider calendar
- Suggesting alternatives
- Flexible rescheduling workflow

### Navigation
- Confirmed → Provider Dashboard (booking now active)

---

## 30. Worker Management Page

### Purpose
Manage all registered workers under the shop.

### This Page Will Have
1. Worker list with photos and names
2. Skills and specialization tags per worker
3. Availability toggle per worker
4. Individual worker rating
5. Add new worker button
6. Edit worker button

### Functionality
- Specialization tagging (used by AI for worker assignment)
- Toggle availability in real time
- AI uses this data to assign correct worker per booking

### Navigation
- Add Worker → Add Worker Page
- Worker card → Worker Profile Page

---

## 31. Add / Edit Worker Page

### Purpose
Register or update a worker's profile.

### This Page Will Have
1. Worker name
2. Phone number
3. Profile photo
4. Skill/specialization tags (multi-select)
   - AC Installation
   - Inverter Repair
   - Gas Refill
   - Electrical Wiring
   - etc.
5. Available days and hours
6. Save button

### Navigation
- Save → Worker Management Page

---

## 32. Worker Profile Page

### Purpose
Detailed view of a single worker.

### This Page Will Have
1. Worker photo and name
2. All specializations
3. Current availability status
4. Assigned bookings (today)
5. Rating and review summary
6. Edit button

---

## 33. Active Booking Management Page

### Purpose
Manage all currently active bookings.

### This Page Will Have
1. List of active bookings with status
2. Per booking:
   - Customer name and location
   - Service type
   - Assigned worker
   - Current status
   - Update status button
3. Status update options
   - Worker Assigned
   - Left Shop
   - Arriving
   - Service Completed

### Functionality
- Status updates trigger customer notifications automatically
- Completing a booking triggers follow-up automation

---

## 34. Provider Chat Page

### Purpose
Provider side of the chat with the customer.

### This Page Will Have
1. Customer messages
2. Image viewing
3. Voice notes
4. AI summary of conversation
5. Quick reply suggestions

---

## 35. Provider Earnings Page

### Purpose
Track all cash payments received.

### This Page Will Have
1. Earnings summary (today / this week / this month)
2. Per booking breakdown
   - Customer name
   - Service
   - Amount collected in cash
   - Date
3. Export summary button

### Functionality
- Stores cash payment records
- Future use: feeds into AI pricing suggestions

---

## 36. Provider Profile & Settings Page

### Purpose
Manage shop profile and app settings.

### This Page Will Have

**Shop Profile**
1. Shop photo
2. Shop name and description
3. Service categories offered
4. Business hours
5. Service area radius
6. Edit profile button

**Settings**
7. Language preference
8. Notification preferences
9. About the app
10. Help & Support
11. Logout

---

---

# ADMIN / MONITORING DASHBOARD

---

## 37. Admin Dashboard (Hackathon Demo Page)

### Purpose
System-wide monitoring of all AI agent activity, bookings, and workflows. The most important page for the hackathon demo — shows that this is a real orchestration system, not just a booking form.

### This Page Will Have

**Live System Overview**
1. Total active bookings right now
2. Active AI agents count
3. Pending requests in queue
4. Providers online

**Agent Activity Feed**
5. Real-time log of every agent action
   - "Intent Agent — extracted AC repair request from user Cyrus"
   - "Location Agent — resolved address to DHA Phase 5"
   - "Ranking Agent — scored 7 providers, returned top 3"
   - "Booking Agent — created booking #B00142"
6. Each log entry shows timestamp, agent name, and action

**Booking Analytics**
7. Total bookings today/this week
8. Success rate (confirmed vs cancelled)
9. Average time from request to booking confirmation
10. Most requested service categories (bar chart)

**Provider Map**
11. Live map showing all active providers
12. Status color codes (available / busy / offline)

**AI Decision Logs**
13. Full reasoning trace per booking (expandable)
14. Which providers were considered and why
15. Which ranking factors were applied

**Failed Workflows**
16. Requests where no provider was found
17. Cancelled bookings with reason
18. Agent errors or timeouts

**Notification Logs**
19. All notifications sent (user and provider side)
20. Follow-up automation triggers

### Why This Page Matters
Every hackathon requirement — agentic workflows, reasoning, execution, automation, system state changes — is visible on this single screen. This is the page you open during the demo when judges ask "how does the AI work?"

---

---

# COMPLETE USER FLOW

```
Splash
  → Welcome
    → Login / Signup
      → Address Setup
        → Home
          → AI Service Request
            → AI Processing (live agent workflow)
              → Provider Recommendation (user selects)
                → Provider Details (optional)
                → Provider Comparison (optional)
                → Booking Confirmation
                  → Booking Success
                    → Live Tracking
                      → Follow-Up Automation
                        → Feedback & Rating
                          → Payment Summary
                            → Home
```

---

# MOST IMPORTANT PAGES FOR HACKATHON JUDGING

These directly match the challenge requirements and should be the focus of your demo:

1. **AI Processing Page** — shows multi-agent orchestration live
2. **Provider Recommendation Page** — shows AI reasoning per provider, user makes final choice
3. **Booking Confirmation Page** — shows full booking simulation
4. **Live Tracking Page** — shows real-time state changes
5. **Admin Dashboard** — shows the entire system from above, every agent trace visible
6. **Follow-Up Automation Page** — shows post-booking AI workflow

These six pages prove: agentic reasoning, workflow execution, booking simulation, automation, and system monitoring — which are all explicitly required by the challenge.
