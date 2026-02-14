# LifePanel - Product Requirements Document (PRD)

## Document Info
| Field | Value |
|-------|-------|
| **Product Name** | LifePanel |
| **Version** | 0.1.0 (MVP) |
| **Author** | LifePanel Team |
| **Last Updated** | 2026-02-14 |
| **Status** | Draft |

---

## 1. Executive Summary

LifePanel is a fully offline Flutter application that empowers users to track and manage six core life areas -- **Money**, **Fuel** (nutrition), **Work**, **Mind**, **Body**, and **Home** -- through a single, unified interface styled with a vibrant comic book aesthetic.

Unlike fragmented tracking apps that each handle one concern, LifePanel consolidates all personal tracking into one app with a shared data architecture ("One Base, Six Skins"), ensuring consistency, discoverability, and holistic insight into daily life. The app requires no internet connection, stores all data locally using Isar Community database, and includes a "Smart Recovery" system that gently helps users catch up on missed days instead of punishing them.

The comic book UI is not merely cosmetic -- it transforms the often tedious act of logging data into an engaging, visually rewarding experience with bold colors, speech bubbles, onomatopoeia animations, and halftone patterns.

---

## 2. Problem Statement

### The Fragmentation Problem
People who want to track their finances, nutrition, fitness, mood, work tasks, and home maintenance currently need 5-10 separate apps. Each app has its own login, its own UI paradigm, its own subscription model, and its own data silo. Cross-domain insights (e.g., "Does my spending increase when my mood drops?") are impossible.

### The Cloud Dependency Problem
Nearly all modern tracking apps require cloud accounts, transmit sensitive personal data to third-party servers, and become unusable without an internet connection. Privacy-conscious users have few alternatives.

### The Abandonment Problem
Traditional trackers punish missed days with broken streaks, guilt-inducing empty charts, and lost momentum. Users who miss a weekend of logging often abandon the app entirely. No mainstream tracker offers a structured "catch-up" mechanism.

### The Boring UI Problem
Most tracking apps use sterile, utilitarian interfaces. Data entry feels like a chore. There is no delight, no personality, no reason to open the app beyond obligation.

---

## 3. Solution Overview

LifePanel addresses all four problems:

1. **Unified Architecture**: A single `TrackableEntry` entity serves as the foundation for all six life areas. Each area provides its own "skin" (custom UI, categories, and metadata) while sharing the same storage, query, and reporting infrastructure.

2. **Offline-First**: All data lives in Isar Community (a fast, embedded NoSQL database). Zero network calls. Zero accounts. Zero cloud dependencies. An optional future phase may add encrypted sync to personal cloud storage (OneDrive/Google Drive/iCloud).

3. **Smart Recovery**: When the app detects gaps in logging, it presents a friendly, guided bulk-fill interface. For money, it offers reconciliation ("Your last balance was $1,200 -- what is it now?"). For other areas, it provides quick-entry cards for each missed day. No guilt, no broken streaks.

4. **Comic Book UI**: Bold outlines, speech bubbles, halftone dot patterns, onomatopoeia animations ("POW!" when hitting a goal, "WHOOSH!" on page transitions), and comic fonts (Bangers + Comic Neue) make every interaction feel like stepping into a graphic novel.

---

## 4. Target User Persona

### Primary Persona: "The Holistic Tracker"
| Attribute | Detail |
|-----------|--------|
| **Name** | Alex |
| **Age** | 25-40 |
| **Tech Comfort** | High (uses multiple productivity apps) |
| **Privacy Stance** | Strongly prefers local/offline tools |
| **Pain Point** | Frustrated by managing 6+ separate tracking apps |
| **Goal** | Single app to track all life areas with minimal friction |
| **Behavior** | Logs daily (money, meals, tasks), weekly (workouts, mood), monthly (home maintenance) |
| **Device** | Android or iOS smartphone, primarily mobile usage |
| **Motivation** | Self-improvement through data awareness, not gamification |

### Secondary Persona: "The Comeback Kid"
| Attribute | Detail |
|-----------|--------|
| **Name** | Jordan |
| **Age** | 20-35 |
| **Pain Point** | Has abandoned multiple tracking apps after missing a few days |
| **Goal** | A tracker that welcomes them back instead of shaming them |
| **Behavior** | Inconsistent logging, bursts of activity followed by gaps |
| **Key Need** | Smart Recovery to fill gaps without feeling overwhelmed |

---

## 5. Core Features (MVP)

### 5.1 Dashboard (P0)

The main screen is a horizontal PageView with three swipeable screens:

**Screen 1 -- Life Overview (Yoga Figure)**
- Centered animated yoga/meditation figure (rendered with Flame engine)
- Six progress pie charts surrounding the figure, one per life area
- Each pie shows today's completion percentage for that area
- Tapping a pie navigates to that area's dashboard

**Screen 2 -- Area Snapshots**
- Six equal partitions arranged in a 2x3 or 3x2 grid
- Each partition shows a mini-chart or key metric for that area
- Examples: net balance for Money, calories consumed for Fuel, tasks completed for Work
- Tapping a partition navigates to that area's dashboard

**Screen 3 -- Daily Feed**
- Chronological list of all entries logged today
- Grouped by time-of-day (Morning, Afternoon, Evening, Night)
- Quick-add floating action button for any area
- Smart Recovery banner if gaps are detected

#### User Stories -- Dashboard
| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| D-01 | As a user, I want to see my overall life balance at a glance | Six pie charts show real-time completion for today |
| D-02 | As a user, I want to navigate to any life area in one tap | Tapping a pie or grid cell opens that area's dashboard |
| D-03 | As a user, I want to see everything I logged today | Daily feed shows all entries grouped by time of day |
| D-04 | As a user, I want to be reminded to catch up on missed days | Smart Recovery banner appears when gaps > 1 day are detected |

---

### 5.2 Money (P0)

Track income, expenses, transfers, budgets, and investments across multiple accounts.

**Sub-Areas**: Transactions, Accounts, Budgets, Investments, Transfers, Records, Categories

#### Key Pages
- **Money Dashboard**: Net balance across all accounts, spending today/this week/this month, budget progress bars, recent transactions
- **Add Transaction**: Numeric keypad, category/subcategory picker, account selector, date picker, recurring toggle, note field
- **Accounts**: List of accounts (bank, cash, credit card, wallet) with balances; add/edit account
- **Budgets**: Create budgets per category with monthly/weekly limits; progress bars showing spent vs. limit
- **Investments**: Track investment accounts with current value and notes
- **Transfers**: Move money between accounts
- **Records**: Full transaction history with date range filter, category filter, search
- **Categories**: Manage income/expense categories and subcategories

#### User Stories -- Money
| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| M-01 | As a user, I want to log an expense in under 5 seconds | Keypad opens immediately, amount + category = save |
| M-02 | As a user, I want to see my spending by category this month | Pie chart on money dashboard groups by category |
| M-03 | As a user, I want to set a monthly budget for groceries | Budget page allows category + amount + period |
| M-04 | As a user, I want to transfer between my bank and cash accounts | Transfer page debits one, credits the other atomically |
| M-05 | As a user, I want recurring transactions (rent, subscriptions) | Recurring toggle creates a rule; entries auto-generated |
| M-06 | As a user, I want to reconcile after missing days | Smart Recovery shows last known balance, asks for current |

---

### 5.3 Fuel (P0)

Track meals, water intake, supplements, recipes, groceries, meal prep, and diet plans.

**Sub-Areas**: Meals, Liquids, Supplements, Recipes, Groceries, Meal Prep, Diet

#### Key Pages
- **Fuel Dashboard**: Calories today vs. goal, water progress ring, macros breakdown, recent meals
- **Meals**: Log breakfast/lunch/dinner/snack with category, calories, note; meal history
- **Liquids**: Water tracker with glass/bottle increments and daily goal ring; also track coffee, tea, etc.
- **Supplements**: Log daily supplements with time taken
- **Recipes**: Add recipes with ingredients, prep/cook time, servings, instructions; browse saved recipes
- **Groceries**: Shopping list (to-buy items) and pantry inventory; check off items while shopping
- **Meal Prep**: Weekly meal plan grid (7 days x 4 meals); assign recipes to slots
- **Diet**: Set diet plan (calorie goal, macro targets); track adherence

#### User Stories -- Fuel
| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| F-01 | As a user, I want to log a meal with calories quickly | Category picker + numeric input + save in <5s |
| F-02 | As a user, I want to track my water intake throughout the day | Tap to add glass, ring fills up toward daily goal |
| F-03 | As a user, I want to plan my meals for the week | 7x4 grid allows assigning recipes or custom meals |
| F-04 | As a user, I want a grocery list I can check off at the store | Checkbox list, sorted by category/aisle |
| F-05 | As a user, I want to see my macro breakdown for today | Fuel dashboard shows protein/carb/fat bar chart |

---

### 5.4 Work (P0)

Track tasks, time clock (punch in/out), alarms, calendar events, and career goals.

**Sub-Areas**: Tasks, Clock, Alarms, Calendar, Career

#### Key Pages
- **Work Dashboard**: Tasks due today, hours clocked today/this week, upcoming events, career milestone progress
- **Tasks**: List view and kanban view (To Do / In Progress / Done); add task with title, description, priority, due date, tags
- **Clock**: Punch in/out with running timer; daily/weekly hours summary; overtime tracking
- **Alarms**: Set named alarms with repeat patterns; alarm history
- **Calendar**: Day/week/month views; add events with time, location, notes
- **Career**: Long-term career goals with milestones; track progress over months/years

#### User Stories -- Work
| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| W-01 | As a user, I want to manage my tasks in a kanban board | Drag-and-drop between To Do / In Progress / Done columns |
| W-02 | As a user, I want to track my work hours accurately | Punch in starts timer, punch out logs hours |
| W-03 | As a user, I want to see my calendar events for the week | Week view shows events with time blocks |
| W-04 | As a user, I want to set career goals and track milestones | Goal page with milestone checklist and progress bar |

---

### 5.5 Mind (P1)

Track mood, journal entries, social interactions, and stress levels.

**Sub-Areas**: Mood, Journal, Social, Stress

#### Key Pages
- **Mind Dashboard**: Mood trend (last 7 days), journal streak, social interaction count, stress level indicator
- **Mood**: Log mood with emoji picker or slider (1-10); optional note; history chart (line graph over time)
- **Journal**: Rich text journal entries with date, tags, and mood association; searchable history
- **Social**: Log social interactions (who, type: in-person/call/text, duration, quality rating)
- **Stress**: Rate stress level, log triggers, record coping strategies used; weekly trends

#### User Stories -- Mind
| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| MN-01 | As a user, I want to log my mood in 3 taps | Emoji picker -> optional note -> save |
| MN-02 | As a user, I want to write journal entries with tags | Rich text editor with tag input; entries searchable |
| MN-03 | As a user, I want to track which social interactions improve my mood | Social log correlates with mood entries by date |
| MN-04 | As a user, I want to see my stress patterns over time | Weekly stress chart shows triggers and trends |

---

### 5.6 Body (P1)

Track sleep, workouts, menstrual cycle, skin/hair routines, and health records.

**Sub-Areas**: Sleep, Workout, Menstrual, Skin/Hair, Health Records

#### Key Pages
- **Body Dashboard**: Hours slept last night, workouts this week, cycle day (if applicable), upcoming health appointments
- **Sleep**: Log sleep/wake times, quality rating, notes; weekly sleep chart
- **Workout**: Log workouts with exercise type, sets, reps, weight, duration; workout history
- **Menstrual**: Calendar view with period/ovulation/PMS tracking; log symptoms, flow level, mood
- **Skin/Hair**: Track daily/weekly routines (products used, skin condition, hair wash days)
- **Health Records**: Log weight, blood pressure, medications, doctor visits; attach notes to records

#### User Stories -- Body
| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| B-01 | As a user, I want to log my sleep quickly each morning | Sleep page pre-fills last night's date, just enter times |
| B-02 | As a user, I want to track my workout sets and reps | Exercise builder with set x rep x weight entry |
| B-03 | As a user, I want to predict my next period | Calendar shows predicted dates based on logged history |
| B-04 | As a user, I want to track my weight over time | Weight chart with trend line on Body dashboard |

---

### 5.7 Home (P1)

Track car maintenance, gardening, pets, cleaning, and home inventory.

**Sub-Areas**: Car, Garden, Pets, Cleaning, Home Inventory

#### Key Pages
- **Home Dashboard**: Upcoming car service, garden tasks this week, pet care summary, cleaning schedule, recent inventory additions
- **Car**: Service log (oil change, tires, inspection) with date, mileage, cost; reminders for next service
- **Garden**: Activity log (watering, planting, fertilizing); per-plant tracking
- **Pets**: Per-pet profiles with vet visits, feeding schedule, medication, weight tracking
- **Cleaning**: Room-based checklists (kitchen, bathroom, bedroom, etc.); weekly/monthly schedules
- **Home Inventory**: Track items with purchase date, warranty expiration, value; search by room/category

#### User Stories -- Home
| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| H-01 | As a user, I want to know when my car's next oil change is due | Car page shows next service date/mileage with reminder |
| H-02 | As a user, I want per-pet vet and feeding records | Pet profile with tabbed sections for each tracking type |
| H-03 | As a user, I want room-based cleaning checklists | Check off tasks by room; schedule resets weekly/monthly |
| H-04 | As a user, I want to know when warranties expire | Home inventory list sortable/filterable by warranty date |

---

### 5.8 Smart Recovery (P0)

The system that differentiates LifePanel from every other tracker.

**Detection**: On app open, check each area for logging gaps > 1 day.

**Presentation**: A friendly banner on the Daily Feed (Dashboard Screen 3) says "Welcome back! You have 3 days to catch up on. Want to fill them in?"

**Bulk-Fill UI**: A swipeable card stack, one card per missed day, with quick-entry fields appropriate to each area:
- **Money**: "Your last recorded balance was $X on [date]. What's your balance now?" with auto-reconciliation
- **Fuel**: Quick meal/water logging for each missed day
- **Work**: "Did you work on [date]?" with hours entry
- **Mind**: Mood slider for each missed day
- **Body**: Sleep times for each missed night
- **Home**: "Any home tasks completed?" checklist

**Philosophy**: No guilt. No broken streaks. Just helpful catch-up.

#### User Stories -- Smart Recovery
| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| SR-01 | As a user returning after 3 days, I want to catch up easily | Bulk-fill cards for each missed day, pre-filled where possible |
| SR-02 | As a user, I want money reconciliation after a gap | Enter current balance, app calculates difference and creates adjustment entry |
| SR-03 | As a user, I don't want to be shamed for missing days | No "streak broken" messages; tone is welcoming |

---

### 5.9 Comic Book UI (P0)

Not a feature in the traditional sense, but a critical differentiator.

**Visual Language**:
- **Fonts**: Bangers (headings, buttons) + Comic Neue (body text)
- **Colors**: Bold primary palette with area-specific accent colors
  - Money: Green (#2E7D32)
  - Fuel: Orange (#E65100)
  - Work: Blue (#1565C0)
  - Mind: Purple (#6A1B9A)
  - Body: Red (#C62828)
  - Home: Amber (#F57F17)
- **Outlines**: 2-3px black borders on cards, buttons, containers
- **Shadows**: 4px offset drop shadows (black, slight transparency)
- **Backgrounds**: Subtle halftone dot patterns
- **Speech Bubbles**: Used for tooltips, empty states, onboarding hints
- **Animations**: Onomatopoeia text ("POW!", "BOOM!", "WHOOSH!") on achievements and transitions
- **Page Transitions**: Comic panel slide/zoom effects

---

### 5.10 Recurring Engine (P0)

**Rules**: Each `RecurringRule` specifies frequency (daily, weekly on specific days, monthly on a date, custom interval), linked to an entry template.

**Processing**: On each app open, the engine checks all active rules, generates any entries that are due, and advances `nextDueDate`.

**Reminders**: Local notifications scheduled based on `Reminder` entities. Tapping a notification opens the relevant entry page.

---

## 6. Feature Prioritization Matrix

| Feature | Priority | Effort | Impact | Phase |
|---------|----------|--------|--------|-------|
| Dashboard (3 screens) | P0 | Large | High | 1, 8 |
| Money (full feature) | P0 | X-Large | High | 2 |
| Fuel (full feature) | P0 | X-Large | High | 3 |
| Work (full feature) | P0 | Large | High | 4 |
| Mind (full feature) | P1 | Medium | Medium | 5 |
| Body (full feature) | P1 | Large | Medium | 6 |
| Home (full feature) | P1 | Large | Medium | 7 |
| Smart Recovery | P0 | Medium | Very High | 8 |
| Comic UI Theme | P0 | Large | High | 1, 9 |
| Recurring Engine | P0 | Medium | High | 10 |
| Local Notifications | P0 | Small | Medium | 10 |
| Cloud Sync | P2 | X-Large | Medium | 12 |
| Export/Import | P1 | Medium | Medium | 12 |

---

## 7. Non-Functional Requirements

### 7.1 Performance
| Metric | Target |
|--------|--------|
| Cold startup time | < 2 seconds on mid-range device |
| Frame rate | 60 fps during normal usage |
| Entry logging latency | < 100ms from tap to Isar write |
| Query response time | < 200ms for any single query |
| Dashboard load time | < 500ms with all 6 area data |

### 7.2 Storage
| Metric | Target |
|--------|--------|
| App binary size | < 30 MB |
| Database size (year 1) | < 100 MB with heavy daily usage |
| Database size (year 3) | < 300 MB |

### 7.3 Reliability
| Metric | Target |
|--------|--------|
| Data durability | Zero data loss under any normal usage |
| Crash rate | < 0.1% of sessions |
| Error handling | All errors caught; user sees friendly comic-styled error panels |

### 7.4 Privacy & Security
- All data stored locally on device only
- No network calls whatsoever in MVP
- No analytics, no telemetry, no crash reporting to external services
- Local encryption ready (Isar supports encryption; can be enabled in future)
- No user accounts required

### 7.5 Accessibility
- Minimum touch targets: 48x48dp
- Screen reader support for all interactive elements
- Sufficient color contrast (WCAG AA) despite comic styling
- Scalable text (respect system font size preferences)

### 7.6 Platform Support
| Platform | Priority |
|----------|----------|
| Android (API 24+) | Primary |
| iOS (15+) | Primary |
| Web | Not planned for MVP |
| Desktop | Not planned for MVP |

---

## 8. Out of Scope (MVP)

The following are explicitly **not** included in the MVP release:

- **Cloud Sync**: No syncing to any cloud provider (OneDrive, Google Drive, iCloud). Phase 12 lays groundwork only.
- **Social Features**: No sharing, no leaderboards, no collaborative tracking.
- **AI/ML Suggestions**: No automated insights, predictions, or recommendations. The app presents data; the user draws conclusions.
- **Wearable Integration**: No Apple Watch, Wear OS, or fitness tracker connectivity.
- **Multi-Device Sync**: Single device only for MVP.
- **Theming/Customization**: Comic book theme is fixed. No dark mode toggle, no alternative themes.
- **Multi-Language Support**: English only for MVP.
- **Widgets**: No home screen widgets for MVP.
- **Biometric Lock**: No fingerprint/face unlock for MVP (encryption-ready only).
- **Data Visualization Export**: No PDF/image export of charts.

---

## 9. Success Metrics

### 9.1 Engagement Metrics (Self-Measured)
| Metric | Target |
|--------|--------|
| Daily active logging | User logs at least 3 entries per day |
| Area coverage | User actively tracks 3+ areas within first month |
| Retention (self-motivated) | User still logging after 30 days |
| Smart Recovery usage | 80% of gap detections result in partial or full fill |

### 9.2 Usability Metrics
| Metric | Target |
|--------|--------|
| Time to log any entry | < 5 seconds for simple entries (expense, water, mood) |
| Time to log complex entry | < 30 seconds (workout with sets, recipe) |
| Navigation depth | Any feature reachable in <= 3 taps from dashboard |
| Learning curve | Core features usable without tutorial |

### 9.3 Technical Metrics
| Metric | Target |
|--------|--------|
| Test coverage (domain + data) | >= 80% |
| Test coverage (presentation) | >= 50% widget test coverage on critical pages |
| Crash-free sessions | >= 99.9% |
| Isar query performance | All queries < 200ms |

---

## 10. Open Questions

| # | Question | Options | Decision |
|---|----------|---------|----------|
| 1 | Exact comic art style? | Hand-drawn / Pop Art / Manga-inspired / Western comic | TBD -- leaning Western comic with Pop Art colors |
| 2 | Cloud sync provider priority? | OneDrive / Google Drive / iCloud / All three | TBD -- likely user's choice with adapter pattern |
| 3 | Monetization model? | Free + donation / Freemium (6 areas free, unlock features) / One-time purchase | TBD -- leaning free + open source |
| 4 | Should the yoga figure be Flame or Rive? | Flame (already a dependency) / Rive (smoother animation) | TBD -- starting with Flame, may switch |
| 5 | Calendar view library? | Custom-built / table_calendar / syncfusion | TBD -- prefer custom for comic styling |
| 6 | How many default categories per area? | Minimal (5-8) / Comprehensive (15-20) | TBD -- leaning comprehensive with user customization |
| 7 | Should dark mode be a future feature? | Yes (Phase 13) / No (comic style doesn't suit dark) | TBD |
| 8 | Maximum gap for Smart Recovery? | 7 days / 14 days / 30 days / Unlimited | TBD -- leaning 14 days default, configurable |

---

## Appendix A: Glossary

| Term | Definition |
|------|-----------|
| **Area** | One of the six life areas: Money, Fuel, Work, Mind, Body, Home |
| **Sub-Area** | A specific tracking domain within an area (e.g., Meals within Fuel) |
| **TrackableEntry** | The unified data entity that stores all logged entries across all areas |
| **Smart Recovery** | The system for detecting and filling logging gaps |
| **Bulk-Fill** | The UI flow for quickly entering data for multiple missed days |
| **Reconciliation** | Money-specific recovery that computes missing transactions from balance changes |
| **Recurring Rule** | A template that auto-generates entries on a schedule |
| **Comic Component** | A reusable UI widget styled with the comic book theme |
| **One Base, Six Skins** | Architecture pattern where all areas share a common data model but present unique UIs |
