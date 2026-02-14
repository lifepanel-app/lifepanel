# LifePanel

Track every aspect of your life — fully offline, beautifully comic.

## Philosophy

Life is complex but tracking it shouldn't be. LifePanel unifies 6 core life areas into a single app with a fun comic book aesthetic. One unified tracking system powers everything — whether you're logging an expense, a meal, or a workout. Miss a few days? Smart recovery helps you catch up without guilt.

## Features

- **Money** - Income, expenses, accounts, budgets, investments, transfers
- **Fuel** - Meals, hydration, supplements, recipes, groceries, meal prep, diet plans
- **Work** - Tasks, time clock, alarms, calendar, career goals
- **Mind** - Mood tracking, journaling, social interactions, stress levels
- **Body** - Sleep, workouts, menstrual cycle, skin/hair routines, health records
- **Home** - Car maintenance, garden, pets, cleaning schedules, home inventory

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| State Management | Riverpod 3 |
| Local Database | Isar Community |
| DI | get_it |
| Dashboard Visuals | Flame + Rive |
| Charts | fl_chart |
| Animations | flutter_animate + Lottie |
| Error Handling | fpdart (Either) |
| Routing | GoRouter |

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK 3.x

### Setup
```bash
git clone https://github.com/lifepanel-app/lifepanel.git
cd lifepanel
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Architecture

LifePanel uses **Clean Architecture** with a **feature-first** organization and a **"One Base, Six Skins"** pattern:

- `lib/core/` - Constants, theme, routing, DI, database, utilities
- `lib/comic/` - Global comic-style UI component library
- `lib/shared/` - Unified TrackableEntry system (one base for all 6 areas)
- `lib/features/` - Area-specific code only (money, fuel, work, mind, body, home)

## Development with Claude Code

| Command | Description |
|---------|-------------|
| `/status` | Project status overview |
| `/resume` | Continue from last session |
| `/save-progress` | Save before context fills |
| `/feature [name]` | Generate new feature scaffold |
| `/commit [msg]` | Git commit with message |
| `/push` | Push to remote |
| `/test [target]` | Generate tests |

## Documentation

- [Product Requirements](docs/prd.md)
- [Architecture](docs/architecture.md)
- [Data Model](docs/data-model.md)
- [Internal Data Interfaces](docs/api-design.md)
- [Implementation Plan](docs/implementation-plan.md)
- [Progress Tracker](docs/PROGRESS.md)

## License

MIT
