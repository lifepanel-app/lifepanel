# LifePanel - Project Context

## Context Management
When context is getting full, run `/save-progress` to save current state.
When starting a new session, run `/resume` to pick up where you left off.

## Quick Status
**Phase**: Phase 0 - Project Setup
**Last Updated**: 2026-02-14

## Commands
| Command | Description |
|---------|-------------|
| `/save-progress` | Save progress before context fills |
| `/resume` | Resume from last session |
| `/status` | Show project status |
| `/commit [msg]` | Git commit with message |
| `/push` | Push to remote |
| `/feature [name]` | Generate feature scaffold |
| `/test [target]` | Generate tests |
| `/analyze-requirements` | Analyze requirements folder |

## What Is This?
LifePanel is a fully offline Flutter app that tracks every aspect of human life across 6 core areas: Money, Fuel (food/nutrition), Work, Mind, Body, and Home. It uses a comic book style design language throughout, with a unified "one base, six skins" architecture where all tracking flows through a single TrackableEntry system.

The app philosophy: tracking should be effortless, forgiving (smart recovery when you miss days), and fun (comic book aesthetics with game-like visual elements).

### The 6 Life Areas
1. **Money** - Income, expenses, accounts, budgets, investments, transfers, categories, records
2. **Fuel** - Meals, liquids, supplements, recipes, groceries/inventory, meal prep, diet plans
3. **Work** - Tasks, time clock, alarms, calendar, career goals
4. **Mind** - Mood tracking, social interactions, journaling, stress levels
5. **Body** - Sleep, workouts, menstrual cycle, skin/hair routines, health records
6. **Home** - Car maintenance, garden, pets, cleaning/organizing, home inventory

## Core Features
1. **Unified Tracking** - One TrackableEntry abstraction powers all 6 areas
2. **3-Screen Dashboard** - Yoga progress view, 6-area overview, daily feed
3. **Smart Recovery** - Graceful catch-up when user misses tracking days
4. **Comic Book UI** - Centralized comic component library (speech bubbles, halftone, bold outlines)
5. **Flame-Powered Dashboard** - Game engine visuals for yoga figure + animated pie charts
6. **Recurring Engine** - Automated recurring entries with reminders
7. **Category System** - Hierarchical categories/subcategories scoped per area
8. **Fully Offline** - All data stored locally with Isar; optional cloud sync later

## Tech Stack
| Layer | Technology | Why |
|-------|-----------|-----|
| Framework | Flutter 3.x | Cross-platform, single codebase |
| State Management | Riverpod 3 (codegen) | Compile-safe, auto-dispose, testable |
| Local Database | Isar Community 3.3 | Fast NoSQL, Flutter-native, code generation |
| DI | get_it 8.x | Simple service locator for construction-time wiring |
| Error Handling | fpdart (Either) | Functional error handling, no exceptions across layers |
| Routing | GoRouter | Declarative routing with deep linking |
| Dashboard Visuals | Flame + Rive | Game engine for animated yoga figure + pie charts |
| Comic Animations | flutter_animate + Lottie | Page transitions, micro-interactions, onomatopoeia |
| Charts | fl_chart | Pie, bar, line charts with comic styling |
| Models | freezed + equatable | Immutable models with value equality |

## Architecture Overview

### Clean Architecture (Feature-First)
```
Presentation → Domain ← Data
```
- **Domain**: Entities, repository interfaces, use cases. NO framework imports.
- **Data**: Isar models, local datasources, repository implementations.
- **Presentation**: Pages, widgets, Riverpod providers. Calls use cases only.

### "One Base, Six Skins" Pattern
All entries flow through: `TrackableEntry { area, subArea, numericValue, unit, categoryId, isRecurring, metadata }`

Shared generic pages (dashboard, entry form, list, records, categories, overview) are config-driven and reused across all 6 areas. Feature folders only contain what's truly unique.

### Global Comic Component Library (`lib/comic/`)
Every UI component is built once and used everywhere:
- `comic_calendar` - Work, Body, Fuel, Home
- `comic_keypad` - Money, Fuel, Body
- `comic_pie_chart` - Dashboard + all 6 overviews
- `comic_checklist` - Fuel, Work, Home
- `comic_progress_ring` - Fuel (water), Money (budget), Body (sleep)
- `comic_slider` - Mind (mood/stress), Body (quality/pain)

### Flame Hybrid Approach
- Dashboard Screen 1: Flame GameWidget for yoga figure + animated pies
- All other pages: Standard Flutter widgets wrapped in comic components

## Data Model Overview
### Core Entities
- **TrackableEntry** - Universal tracking record (area, subArea, value, unit, category, recurring, metadata)
- **Category / Subcategory** - Hierarchical, scoped by area+subArea
- **RecurringRule** - Recurrence definition (daily/weekly/monthly/yearly/custom)
- **Reminder** - Scheduled notification linked to entries

### Area-Specific Entities
- **Money**: Account, Budget, Investment
- **Fuel**: Recipe, Ingredient, GroceryItem, DietPlan
- **Work**: Task, TimeClock, Alarm, CalendarEvent, CareerGoal
- **Mind**: MoodEntry, JournalEntry, SocialInteraction, StressLevel
- **Body**: SleepEntry, Workout, MenstrualEntry, SkinHairEntry, HealthRecord
- **Home**: CarRecord, GardenEntry, Pet, PetEntry, CleaningTask, HomeInventoryItem

## Current Focus
Phase 0 - Setting up project foundation: folder structure, dependencies, documentation, and starter files. Next: Phase 1 (Shared Layer + Dashboard Shell).

## Key Decisions Made
1. **Isar Community** over original Isar (abandoned since 2023; community fork is maintained)
2. **fpdart** over dartz (modern, actively maintained, better docs)
3. **Riverpod 3 with codegen** for compile-safe state management
4. **Feature-first organization** with shared unified base
5. **Flame hybrid** - game engine for dashboard only, standard widgets elsewhere
6. **Global comic component library** - all UI components centralized in `lib/comic/`
7. **TrackableEntry pattern** - single abstraction powers all 6 life areas
8. **Smart Recovery** - skip > gap; reconciliation for money; bulk-fill for recurring items

## Project Structure
```
lib/
├── main.dart
├── app.dart
├── bootstrap.dart
├── core/          # Constants, errors, theme, router, DI, database, utils
├── comic/         # GLOBAL comic component library (widgets, composites, effects, game)
├── shared/        # UNIFIED base code (domain, data, presentation generics)
├── features/
│   ├── dashboard/ # 3-screen main dashboard
│   ├── money/     # Money-specific only
│   ├── fuel/      # Fuel-specific only
│   ├── work/      # Work-specific only
│   ├── mind/      # Mind-specific only
│   ├── body/      # Body-specific only
│   └── home_life/ # Home-specific only
└── l10n/          # Localization
```
