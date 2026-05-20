# HelperHive — AI System Brainstorm
**What the AI does, how it works, and where each piece of data comes from**

---

## Overview

HelperHive is a frontend-only Flutter app for the hackathon. All AI workflows are simulated using mock data and timed state transitions to demonstrate the full orchestration flow. The AI logic described below represents what the system does — on the frontend this is shown through the AI Processing page and agent workflow animations.

---

## Customer Side — Full AI Flow

---

### Step 1: Voice / Text Input

The customer speaks or types their service request. If voice, it gets converted to text using a Speech-to-Text API before being fed to the AI.

The AI parses the text and extracts:
- **Service type** — AC repair, electrician, plumber, etc.
- **Location hints** — any area or place mentioned in the request
- **Urgency hints** — words like "kal", "abhi", "jaldi", "emergency"

Example input:
> "Mujhe kal DHA mein AC theek karwana hai"

AI extracts: Service = AC Repair, Urgency = Tomorrow, Location hint = DHA

---

### Step 2: Location Resolution

After intent is extracted, the AI resolves the exact service address. It does not assume — it checks what the customer already provided.

**Logic flow:**

- **One saved address** → AI confirms:
  *"Should we use your Home address in DHA Phase 5?"*

- **Multiple saved addresses** → AI reads context:
  - If request mentions "office" → picks office address
  - If unclear → shows saved address list and asks customer to pick

- **No saved address** → AI asks customer to drop a map pin or type the address manually

**Why this matters:**
Customers often say a general area like "DHA" without specifying phase or house number. Instead of asking them to repeat everything, the AI uses the address they already saved during signup as the primary source of truth.

**Address setup rule:**
- Address setup is the first thing both customers and providers see after signup
- All addresses are saved as GPS coordinates (map pin), not just text labels
- This is mandatory — all distance calculations and map features depend on real coordinates

---

### Step 3: Issue Detail Questions

Once location is confirmed, the AI asks follow-up questions based on the service type it detected. These questions are not generic — they change per category.

**Examples:**

| Service | AI Questions |
|---|---|
| AC Repair | "Is it not cooling, making noise, not turning on, or leaking water?" |
| Electrician | "Is it a wiring issue, tripped breaker, no power in a room, or a fitting problem?" |
| Plumber | "Is it a leakage, blocked drain, low pressure, or an installation job?" |
| Geyser | "Is it not heating, leaking, or making a noise?" |

**What these answers are used for:**
1. Packaged into the booking so the provider sees a clear issue summary before arriving
2. Fed into the AI material/tool suggestion system
3. Included alongside any images the customer uploads

**Image input:**
If the customer uploads a photo of the issue alongside their voice/text input, the AI acknowledges it and includes it in the provider briefing automatically. The provider sees the image and a note: *"Customer attached image — review before arrival."*

---

### Step 4: Provider Cards

After issue details are collected, the AI runs provider ranking and returns **2–3 provider cards**.

**Each card shows:**
- Provider name
- Distance from customer address
- Overall star rating
- Availability status

The customer taps a card to open the full shop detail screen. The customer picks who they want. **The AI does not auto-book** — the final selection is always the customer's decision.

**How ranking works:**
The AI combines three data sources to calculate a score:

| Factor | Source |
|---|---|
| Distance | Google Maps API (coordinates of both addresses) |
| Rating | App database (calculated from customer reviews) |
| Availability | App database (hours the shop owner set) |
| Specialization match | App database (worker skills the shop owner registered) |

---

### Step 5: Time Selection + Cross-Reference

The customer picks their preferred date and time.

The AI cross-references this with the provider's available hours from the database.

**Two outcomes:**
- **Time available** → moves to booking confirmation
- **Time not available** → AI shows the provider's next open slots and asks the customer to pick one

This prevents bookings from landing outside business hours without telling the customer.

---

### Step 6: Confirmation Summary

Before the booking is created, the customer sees a clean summary screen of everything the AI collected:

- Service type
- Issue description (from follow-up answers)
- Uploaded image (if any)
- Selected address (with map pin)
- Selected provider
- Requested time
- Estimated charges

The customer confirms. Only after confirmation is the booking created. This screen exists so the customer can verify the AI understood everything correctly before anything is sent to the provider.

---

### Step 7: Booking Goes to Pending

Booking is created with status: **Pending**.

The provider receives a notification containing:
- AI-generated issue summary
- Customer images (if uploaded)
- Requested time
- Customer location (map pin)
- AI-suggested materials and tools

---

## Provider Side — AI Involvement

---

### Incoming Request

When a booking arrives, the provider sees:

1. **AI Issue Summary** — a clean briefing generated from the customer's follow-up answers
   Example: *"Customer reports AC not cooling. Unit is 2 years old. Outdoor unit accessible."*

2. **AI Material Suggestion** — tools and parts the provider should likely bring
   Example: *"Likely needs: cooling gas refill, pressure gauge, capacitor check"*

3. **Customer images** — attached directly from the booking

4. **Customer location** — displayed on map

The provider can then **Accept** or **Decline** the request.

---

### Decline Fallback

If the provider declines, the AI does not wait for the customer to search again manually.

It automatically:
1. Removes the declined provider from the results
2. Re-runs the same ranking with the same request details
3. Surfaces the next best available provider
4. Notifies the customer: *"Your previous provider wasn't available. Here's another match."*

The customer does not need to start over.

---

### Availability Negotiation

If the customer's requested time doesn't work for the provider, instead of a flat decline, the AI suggests alternative slots from the provider's available schedule.

The provider can propose a different time, which the customer then accepts or rejects. This keeps the booking alive instead of losing it to a cancellation.

---

## What AI Is Actually Doing — Full Summary

| What | How |
|---|---|
| Voice to text | Speech-to-Text API |
| Intent extraction | NLP — pulls service type, urgency, location hints |
| Location resolution | Checks saved addresses, confirms or asks |
| Issue clarification | Dynamic follow-up questions per service category |
| Image handling | Attached to booking, shown to provider |
| Provider ranking | Combines distance (Maps) + rating + availability + specialization |
| Material prediction | Rule-based suggestions per issue type |
| Time cross-reference | Checks provider schedule before confirming slot |
| Confirmation summary | Shows customer everything AI collected before booking |
| Decline fallback | Re-runs provider search automatically |
| Issue summary for provider | AI converts customer answers into a clean briefing |
| Availability negotiation | AI proposes alternative slots if requested time is taken |

---

## Data Sources — Where Everything Comes From

### From Google Maps API
- Distance between customer and provider (using saved coordinates)
- Estimated travel and arrival time
- Route display on the live tracking screen
- Provider location pin on map
- Address resolution when customer drops a pin (reverse geocoding)

### From App Database — Shop Owner Input
- Shop name and description
- Service categories offered
- Worker names and their specialization tags
- Available hours and days
- Shop address (pinned on map during signup)
- Shop profile photo

### From App Database — Customer Activity
- Overall star rating (average of all submitted reviews)
- Number of completed bookings
- Individual review text and scores
- Reported issues or complaints

### From AI Processing
- Extracted service type, urgency, location hints
- Issue summary sent to provider
- Material and tool suggestions
- Ranking score per provider
- Follow-up question set per service type
- Decline fallback search results

---

## Address Rule — Applies to Both Sides

**Address setup is mandatory after signup for both customers and providers.**

- Customers set their primary home address first — this is used as the default for all bookings
- Customers can add more addresses (office, other) and the AI will pick the right one based on context or ask
- Providers pin their shop address on the map during signup — this is used for all distance calculations

All addresses are stored as **GPS coordinates**, not text strings. This is required for:
- Distance calculation via Maps API
- Live tracking map
- Provider location pins on Admin Dashboard
- Arrival time estimates

If coordinates are not stored from day one, none of the map features will work. This must be locked into the mock data structure before building any other location-dependent screen.

---

## Frontend Note

This is a Flutter frontend project. All AI workflows described above are **simulated on the frontend** using mock data and timed state transitions. The AI Processing page shows each agent step with realistic delays to demonstrate the orchestration flow to hackathon judges. No live AI backend is connected — the goal is to show the complete user experience and system logic visually.
