# LifePanel - Architecture Document

## Document Info
| Field | Value |
|-------|-------|
| **Last Updated** | 2026-02-14 |
| **Status** | Draft |

---

## 1. System Overview

LifePanel is a **single Flutter application** with **no backend**. All data is stored locally using the Isar Community embedded NoSQL database. The app runs entirely offline on Android and iOS.

```
+--------------------------------------------------+
|                  LifePanel App                     |
|                                                    |
|  +----------------------------------------------+ |
|  |          Presentation Layer                   | |
|  |  Pages + Widgets + Riverpod 3 Providers       | |
|  |  GoRouter Navigation + Comic Components       | |
|  |  Flame Hybrid (Dashboard only)                | |
|  +----------------------------------------------+ |
|                      |                             |
|                      v                             |
|  +----------------------------------------------+ |
|  |            Domain Layer                       | |
|  |  Entities + Use Cases + Repository Interfaces | |
|  |  fpdart Either<Failure, T> for error handling | |
|  +----------------------------------------------+ |
|                      ^                             |
|                      |                             |
|  +----------------------------------------------+ |
|  |              Data Layer                       | |
|  |  Isar Models + Local DataSources              | |
|  |  Repository Implementations                   | |
|  +----------------------------------------------+ |
|                      |                             |
|                      v                             |
|  +----------------------------------------------+ |
|  |         Isar Community Database               | |
|  |  (Embedded NoSQL on device storage)           | |
|  +----------------------------------------------+ |
+--------------------------------------------------+
```

### Key Architectural Principles

1. **Clean Architecture**: Strict layer separation. Domain layer has zero dependencies on Flutter, Isar, or any framework. Dependency rule flows inward only.
2. **Feature-First Organization**: Each of the 6 life areas is a self-contained feature module with its own domain/data/presentation layers.
3. **One Base, Six Skins**: All features share the `TrackableEntry` entity and common repository infrastructure, but each provides unique UI and area-specific entities.
4. **Offline-First**: No network layer exists. All data operations are synchronous-fast local Isar operations.
5. **Reactive State**: Riverpod 3 with codegen provides compile-safe, auto-disposing, testable state management.
6. **Functional Error Handling**: No exceptions cross layer boundaries. All fallible operations return `Either<Failure, T>` from fpdart.

---

## 2. Architecture Decision Records (ADRs)

### ADR-001: Isar Community for Local Storage

**Status**: Accepted

**Context**: The app needs a fast, embedded database for Flutter that supports complex queries, indexing, and schema migration. The original Isar package by isar.dev was abandoned after the author joined the Realm/MongoDB team. The community fork (isar_community) continues active development.

**Decision**: Use `isar_community` (community fork of Isar) as the sole data persistence layer.

**Rationale**:
- Fast NoSQL embedded database designed specifically for Flutter/Dart
- Code generation for type-safe schemas
- Supports complex queries, composite indexes, and full-text search
- Flutter-native with synchronous and asynchronous APIs
- Zero server dependency -- data lives in a file on device
- Community fork is actively maintained with bug fixes and compatibility updates
- Schema migration handled automatically by Isar

**Consequences**:
- Tied to Isar's query language and data model (document-oriented, not relational)
- Must run `dart run build_runner build` after schema changes
- Community fork may lag behind Flutter version updates (mitigated by active community)

---

### ADR-002: Riverpod 3 with Codegen for State Management

**Status**: Accepted

**Context**: The app needs reactive state management that is testable, scalable to 6+ feature modules, and provides compile-time safety.

**Decision**: Use Riverpod 3 with the `@riverpod` annotation codegen approach.

**Rationale**:
- Compile-safe: Provider dependencies are checked at compile time
- Auto-dispose: Providers automatically clean up when no longer listened to
- Testable: Providers can be overridden in tests without any DI framework
- Codegen reduces boilerplate: `@riverpod` annotation generates provider definitions
- No BuildContext required for accessing state (unlike Provider package)
- Supports async, stream, and future providers natively
- Family providers for parameterized data (e.g., entries by date range)

**Consequences**:
- Requires `build_runner` for codegen (shared with Isar, so no additional tooling)
- Learning curve for team members unfamiliar with Riverpod 3 codegen syntax
- Generated files (`.g.dart`) must be committed or regenerated on clone

---

### ADR-003: Feature-First Folder Organization

**Status**: Accepted

**Context**: With 6 major features plus shared infrastructure, the project needs clear organizational boundaries.

**Decision**: Organize code by feature first, then by layer within each feature.

**Rationale**:
- Each feature (money, fuel, work, mind, body, home) is a cohesive unit
- Developers working on one feature don't need to navigate unrelated code
- Shared code lives in `lib/shared/` with the same layer structure
- Mirrors how the product is conceptualized (6 areas + shared foundation)

**Consequences**:
- Some code duplication between features (mitigated by shared layer)
- Must maintain discipline about what goes in shared vs. feature-specific

---

### ADR-004: Unified TrackableEntry Pattern ("One Base, Six Skins")

**Status**: Accepted

**Context**: All six areas fundamentally do the same thing: log timestamped entries with a numeric value, category, and metadata. Building six completely separate data models would create massive duplication.

**Decision**: Use a single `TrackableEntry` entity as the universal data container. Each area interprets the shared fields differently and uses `metadataJson` for area-specific data. Area-specific entities (Account, Recipe, etc.) are separate Isar collections that link to entries.

**Rationale**:
- Single query interface for cross-area operations (dashboard, daily feed, smart recovery)
- Consistent CRUD operations across all areas
- Area-specific richness preserved via metadata and linked entities
- Dramatically reduces codebase size vs. six separate entry types

**Consequences**:
- `metadataJson` is a flexible but untyped field -- must be carefully validated per area
- Queries that filter on metadata fields require JSON parsing (mitigated by indexing `area` and `subArea` as primary filters)
- Area-specific entities still needed for complex domain objects (Account, Recipe, Pet, etc.)

---

### ADR-005: get_it for DI + Riverpod for Reactivity

**Status**: Accepted

**Context**: The app needs dependency injection for constructing repositories, datasources, and use cases, plus reactive state management for the UI.

**Decision**: Use `get_it` as a service locator for constructing the dependency graph (repositories, datasources, use cases). Use Riverpod for reactive state in the presentation layer. Riverpod providers call use cases obtained from get_it.

**Rationale**:
- Separation of concerns: get_it handles construction, Riverpod handles reactivity
- Use cases and repositories are plain Dart classes registered in get_it -- no Riverpod coupling
- Domain and data layers remain framework-agnostic
- Riverpod providers are thin wrappers that delegate to use cases
- Testing: get_it registrations can be swapped for mocks; Riverpod providers can be overridden

**Pattern**:
```dart
// In DI setup (get_it)
sl.registerLazySingleton<MoneyRepository>(() => MoneyRepositoryImpl(sl()));
sl.registerLazySingleton(() => AddTransaction(sl()));

// In Riverpod provider
@riverpod
Future<Either<Failure, void>> addTransaction(
  AddTransactionRef ref,
  TransactionParams params,
) async {
  final useCase = sl<AddTransaction>();
  return useCase(params);
}
```

**Consequences**:
- Two DI/state systems to understand (get_it + Riverpod)
- Must ensure get_it is initialized before Riverpod providers are first accessed (handled in bootstrap)

---

### ADR-006: fpdart Either for Error Handling

**Status**: Accepted

**Context**: Dart's default error handling uses exceptions, which are invisible in function signatures and easy to forget to catch.

**Decision**: All fallible operations in the domain and data layers return `Either<Failure, T>` from the `fpdart` package. No exceptions propagate across layer boundaries.

**Rationale**:
- Function signatures explicitly declare failure modes
- Compiler helps ensure failures are handled (Either must be folded/matched)
- Different failure types (DatabaseFailure, ValidationFailure, NotFoundFailure) are explicit
- Pattern matching with `fold()` or `match()` provides exhaustive handling
- Consistent error handling across the entire codebase

**Pattern**:
```dart
// Repository interface
abstract class TrackableRepository {
  Future<Either<Failure, List<TrackableEntry>>> getEntries(DateRange range);
}

// Use case
class GetEntries {
  final TrackableRepository repository;
  GetEntries(this.repository);

  Future<Either<Failure, List<TrackableEntry>>> call(DateRange range) {
    return repository.getEntries(range);
  }
}

// Provider consuming the result
ref.watch(entriesProvider).when(
  data: (either) => either.fold(
    (failure) => ComicErrorPanel(failure.message),
    (entries) => EntryList(entries),
  ),
  ...
);
```

**Consequences**:
- Slightly more verbose than try/catch for simple cases
- Team must be comfortable with functional programming concepts
- fpdart is a well-maintained package but adds a dependency

---

### ADR-007: Flame Hybrid for Dashboard

**Status**: Accepted

**Context**: The main dashboard features an animated yoga/meditation figure surrounded by six progress pie charts. This requires smooth 2D animation that would be complex with standard Flutter widgets.

**Decision**: Use the Flame game engine embedded in a `GameWidget` for Dashboard Screen 1 only. The yoga figure and pie charts are Flame components. All other screens use standard Flutter widgets.

**Rationale**:
- Flame excels at 2D sprite animation and custom rendering
- The yoga figure requires skeletal/sprite animation that Flame handles natively
- Pie charts around the figure benefit from Flame's custom paint capabilities
- Embedding Flame in a single screen is lightweight (no full game architecture needed)
- fl_chart handles all other charts in the app (line, bar, pie in feature dashboards)

**Consequences**:
- Flame adds ~2MB to bundle size
- Dashboard Screen 1 has a different rendering paradigm than the rest of the app
- Must carefully manage Flame lifecycle (pause when off-screen, dispose properly)
- Interaction between Flame components and Flutter widgets requires `GameWidget` bridge

---

### ADR-008: Global Comic Component Library

**Status**: Accepted

**Context**: Every screen in the app must look like a comic book. If each feature builds its own styled widgets, inconsistency is inevitable and maintenance becomes a nightmare.

**Decision**: Centralize all comic-styled widgets in `lib/comic/` as a shared component library. Features import and compose these components; they never create their own styled primitives.

**Rationale**:
- Single source of truth for the comic visual language
- Changes to comic styling propagate to all features automatically
- Developers working on features focus on logic, not styling
- Components are categorized: core (card, button, scaffold) and composite (calendar, keypad, chart wrappers)
- Theme tokens (colors, fonts, shadows, borders) defined once in `comic_theme.dart`

**Component Hierarchy**:
```
lib/comic/
  comic_theme.dart          -- ThemeData, colors, typography, constants
  core/
    comic_card.dart          -- Base card with black border + drop shadow
    comic_button.dart        -- Bold button with press animation
    comic_scaffold.dart      -- Page scaffold with halftone background
    comic_app_bar.dart       -- App bar with comic font title
    comic_text_field.dart    -- Text input with comic border
    comic_chip.dart          -- Category/tag chip
    comic_toggle.dart        -- Toggle switch
    comic_dialog.dart        -- Dialog/modal with speech bubble option
    comic_bottom_sheet.dart  -- Bottom sheet with comic styling
    comic_snackbar.dart      -- Snackbar with onomatopoeia option
  composite/
    comic_calendar.dart      -- Calendar widget for date picking/display
    comic_keypad.dart        -- Numeric keypad for money/calorie entry
    comic_pie_chart.dart     -- fl_chart pie wrapped in comic style
    comic_line_chart.dart    -- fl_chart line wrapped in comic style
    comic_bar_chart.dart     -- fl_chart bar wrapped in comic style
    comic_progress_ring.dart -- Circular progress (water tracker, etc.)
    comic_category_picker.dart -- Category selection grid
    comic_time_picker.dart   -- Time input with comic styling
    comic_date_range.dart    -- Date range selector
    comic_empty_state.dart   -- Empty state with illustration + speech bubble
    comic_error_panel.dart   -- Error display with comic styling
  animations/
    onomatopoeia.dart        -- POW!, BOOM!, WHOOSH! overlays
    page_transitions.dart    -- Comic panel transition effects
    comic_shimmer.dart       -- Loading shimmer with halftone pattern
```

**Consequences**:
- Upfront investment in building the component library (Phase 1)
- All features depend on `lib/comic/` -- breaking changes affect everything
- Must resist the temptation to add feature-specific styling to comic components

---

## 3. Clean Architecture Layers

### Layer Diagram

```
+------------------------------------------------------------------+
|                     PRESENTATION LAYER                            |
|                                                                    |
|  +------------+  +-------------+  +-----------+  +-----------+   |
|  |   Pages    |  |   Widgets   |  | Riverpod  |  |  GoRouter |   |
|  | (Screens)  |  | (Comic UI)  |  | Providers |  |  (Routes) |   |
|  +-----+------+  +------+------+  +-----+-----+  +-----+-----+  |
|        |                |               |               |         |
+------------------------------------------------------------------+
         |                                |
         v                                v
+------------------------------------------------------------------+
|                       DOMAIN LAYER                                |
|                                                                    |
|  +------------+  +-------------+  +---------------------------+  |
|  |  Entities  |  |  Use Cases  |  | Repository Interfaces     |  |
|  | (Pure Dart)|  | (Pure Dart) |  | (Abstract, Pure Dart)     |  |
|  +------------+  +------+------+  +---------------------------+  |
|                         |                                         |
+------------------------------------------------------------------+
                          ^
                          | (implements)
+------------------------------------------------------------------+
|                        DATA LAYER                                 |
|                                                                    |
|  +----------------+  +------------------+  +------------------+  |
|  | Isar Models    |  | Local DataSources|  | Repository Impls |  |
|  | (.g.dart gen)  |  | (Isar queries)   |  | (delegates to DS)|  |
|  +----------------+  +------------------+  +------------------+  |
|                              |                                    |
+------------------------------------------------------------------+
                               |
                               v
                    +--------------------+
                    | Isar Community DB  |
                    | (device storage)   |
                    +--------------------+
```

### Layer Rules

| Rule | Description |
|------|-------------|
| **Dependency Direction** | Outer layers depend on inner layers. Domain never imports from Data or Presentation. |
| **Domain Purity** | Domain layer contains only pure Dart. No Flutter imports, no Isar imports, no third-party framework imports. Only `fpdart` for Either. |
| **Interface Segregation** | Repository interfaces live in Domain. Implementations live in Data. |
| **Entity Mapping** | Isar models (Data layer) map to Domain entities. Mapping logic lives in the Data layer. |
| **Provider Thinness** | Riverpod providers in Presentation are thin -- they delegate to Use Cases, not implement business logic. |
| **Error Boundary** | Data layer catches all Isar exceptions and wraps them in `Either.left(Failure)`. No exceptions escape to Domain or Presentation. |

---

## 4. Complete Folder Structure

```
lib/
+-- main.dart                          -- Entry point
+-- app.dart                           -- MaterialApp.router setup
+-- bootstrap.dart                     -- Isar init, get_it setup, startup logic
|
+-- core/
|   +-- error/
|   |   +-- failures.dart              -- Failure sealed class hierarchy
|   |   +-- exceptions.dart            -- Internal exception types (Data layer only)
|   +-- usecase/
|   |   +-- usecase.dart               -- Base UseCase<Type, Params> interface
|   +-- utils/
|   |   +-- date_utils.dart            -- Date range helpers, gap detection
|   |   +-- json_utils.dart            -- Safe JSON parsing for metadata
|   |   +-- constants.dart             -- App-wide constants
|   +-- extensions/
|   |   +-- either_extensions.dart     -- Convenience extensions on Either
|   |   +-- datetime_extensions.dart   -- DateTime formatting, comparison
|   |   +-- string_extensions.dart     -- String validation, formatting
|   +-- di/
|   |   +-- injection_container.dart   -- get_it setup, all registrations
|   |   +-- injection_container.config.dart  -- (if using injectable codegen)
|   +-- enums/
|   |   +-- life_area.dart             -- LifeArea enum (money, fuel, work, mind, body, home)
|   |   +-- sub_area.dart              -- SubArea enum per area
|   |   +-- recurring_type.dart        -- RecurringType enum
|   +-- router/
|       +-- app_router.dart            -- GoRouter configuration
|       +-- route_names.dart           -- Named route constants
|
+-- comic/
|   +-- comic_theme.dart               -- ThemeData, ColorScheme, TextTheme
|   +-- comic_colors.dart              -- Area-specific color palettes
|   +-- comic_typography.dart          -- Bangers + Comic Neue text styles
|   +-- comic_constants.dart           -- Border widths, shadow offsets, radii
|   +-- core/
|   |   +-- comic_card.dart
|   |   +-- comic_button.dart
|   |   +-- comic_scaffold.dart
|   |   +-- comic_app_bar.dart
|   |   +-- comic_text_field.dart
|   |   +-- comic_chip.dart
|   |   +-- comic_toggle.dart
|   |   +-- comic_dialog.dart
|   |   +-- comic_bottom_sheet.dart
|   |   +-- comic_snackbar.dart
|   +-- composite/
|   |   +-- comic_calendar.dart
|   |   +-- comic_keypad.dart
|   |   +-- comic_pie_chart.dart
|   |   +-- comic_line_chart.dart
|   |   +-- comic_bar_chart.dart
|   |   +-- comic_progress_ring.dart
|   |   +-- comic_category_picker.dart
|   |   +-- comic_time_picker.dart
|   |   +-- comic_date_range.dart
|   |   +-- comic_empty_state.dart
|   |   +-- comic_error_panel.dart
|   +-- animations/
|       +-- onomatopoeia.dart
|       +-- page_transitions.dart
|       +-- comic_shimmer.dart
|
+-- shared/
|   +-- domain/
|   |   +-- entities/
|   |   |   +-- trackable_entry.dart
|   |   |   +-- category.dart
|   |   |   +-- subcategory.dart
|   |   |   +-- recurring_rule.dart
|   |   |   +-- reminder.dart
|   |   +-- repositories/
|   |   |   +-- trackable_repository.dart
|   |   |   +-- category_repository.dart
|   |   |   +-- recurring_repository.dart
|   |   |   +-- reminder_repository.dart
|   |   +-- usecases/
|   |       +-- add_entry.dart
|   |       +-- get_entries.dart
|   |       +-- update_entry.dart
|   |       +-- delete_entry.dart
|   |       +-- get_entries_by_area.dart
|   |       +-- get_entries_by_date_range.dart
|   |       +-- detect_gaps.dart
|   |       +-- bulk_add_entries.dart
|   |       +-- manage_categories.dart
|   |       +-- process_recurring_rules.dart
|   +-- data/
|   |   +-- models/
|   |   |   +-- trackable_entry_model.dart    -- Isar collection + mapping
|   |   |   +-- category_model.dart
|   |   |   +-- subcategory_model.dart
|   |   |   +-- recurring_rule_model.dart
|   |   |   +-- reminder_model.dart
|   |   +-- datasources/
|   |   |   +-- trackable_local_datasource.dart
|   |   |   +-- category_local_datasource.dart
|   |   |   +-- recurring_local_datasource.dart
|   |   |   +-- reminder_local_datasource.dart
|   |   +-- repositories/
|   |       +-- trackable_repository_impl.dart
|   |       +-- category_repository_impl.dart
|   |       +-- recurring_repository_impl.dart
|   |       +-- reminder_repository_impl.dart
|   +-- presentation/
|       +-- providers/
|       |   +-- entries_provider.dart
|       |   +-- categories_provider.dart
|       |   +-- recurring_provider.dart
|       +-- pages/
|       |   +-- dashboard/
|       |   |   +-- dashboard_page.dart        -- PageView host
|       |   |   +-- life_overview_screen.dart  -- Screen 1 (Flame)
|       |   |   +-- area_snapshots_screen.dart -- Screen 2
|       |   |   +-- daily_feed_screen.dart     -- Screen 3
|       |   +-- smart_recovery/
|       |       +-- smart_recovery_page.dart
|       |       +-- bulk_fill_card.dart
|       |       +-- reconciliation_page.dart
|       +-- widgets/
|           +-- area_icon.dart
|           +-- entry_tile.dart
|           +-- area_navigation_grid.dart
|
+-- features/
    +-- money/
    |   +-- domain/
    |   |   +-- entities/
    |   |   |   +-- account.dart
    |   |   |   +-- budget.dart
    |   |   |   +-- investment.dart
    |   |   +-- repositories/
    |   |   |   +-- money_repository.dart
    |   |   +-- usecases/
    |   |       +-- add_transaction.dart
    |   |       +-- get_transactions.dart
    |   |       +-- transfer_funds.dart
    |   |       +-- create_budget.dart
    |   |       +-- get_budget_progress.dart
    |   |       +-- manage_accounts.dart
    |   |       +-- reconcile_balance.dart
    |   +-- data/
    |   |   +-- models/
    |   |   |   +-- account_model.dart
    |   |   |   +-- budget_model.dart
    |   |   |   +-- investment_model.dart
    |   |   +-- datasources/
    |   |   |   +-- money_local_datasource.dart
    |   |   +-- repositories/
    |   |       +-- money_repository_impl.dart
    |   +-- presentation/
    |       +-- providers/
    |       |   +-- money_providers.dart
    |       +-- pages/
    |       |   +-- money_dashboard_page.dart
    |       |   +-- add_transaction_page.dart
    |       |   +-- accounts_page.dart
    |       |   +-- budget_page.dart
    |       |   +-- investments_page.dart
    |       |   +-- transfer_page.dart
    |       |   +-- records_page.dart
    |       |   +-- money_categories_page.dart
    |       +-- widgets/
    |           +-- transaction_tile.dart
    |           +-- account_card.dart
    |           +-- budget_progress_bar.dart
    |
    +-- fuel/
    |   +-- domain/
    |   |   +-- entities/
    |   |   |   +-- recipe.dart
    |   |   |   +-- ingredient.dart
    |   |   |   +-- grocery_item.dart
    |   |   |   +-- diet_plan.dart
    |   |   +-- repositories/
    |   |   |   +-- fuel_repository.dart
    |   |   +-- usecases/
    |   |       +-- log_meal.dart
    |   |       +-- log_liquid.dart
    |   |       +-- manage_recipes.dart
    |   |       +-- manage_groceries.dart
    |   |       +-- create_meal_plan.dart
    |   |       +-- set_diet_plan.dart
    |   +-- data/
    |   |   +-- models/
    |   |   +-- datasources/
    |   |   +-- repositories/
    |   +-- presentation/
    |       +-- providers/
    |       +-- pages/
    |       |   +-- fuel_dashboard_page.dart
    |       |   +-- meals_page.dart
    |       |   +-- liquids_page.dart
    |       |   +-- supplements_page.dart
    |       |   +-- recipes_page.dart
    |       |   +-- groceries_page.dart
    |       |   +-- meal_prep_page.dart
    |       |   +-- diet_page.dart
    |       +-- widgets/
    |
    +-- work/
    |   +-- domain/
    |   |   +-- entities/
    |   |   |   +-- task.dart
    |   |   |   +-- time_clock.dart
    |   |   |   +-- alarm.dart
    |   |   |   +-- calendar_event.dart
    |   |   |   +-- career_goal.dart
    |   |   +-- repositories/
    |   |   +-- usecases/
    |   +-- data/
    |   +-- presentation/
    |       +-- providers/
    |       +-- pages/
    |       |   +-- work_dashboard_page.dart
    |       |   +-- tasks_page.dart
    |       |   +-- clock_page.dart
    |       |   +-- alarms_page.dart
    |       |   +-- calendar_page.dart
    |       |   +-- career_page.dart
    |       +-- widgets/
    |
    +-- mind/
    |   +-- domain/
    |   |   +-- entities/
    |   |   |   +-- mood_entry.dart
    |   |   |   +-- journal_entry.dart
    |   |   |   +-- social_interaction.dart
    |   |   |   +-- stress_level.dart
    |   |   +-- repositories/
    |   |   +-- usecases/
    |   +-- data/
    |   +-- presentation/
    |       +-- providers/
    |       +-- pages/
    |       |   +-- mind_dashboard_page.dart
    |       |   +-- mood_page.dart
    |       |   +-- journal_page.dart
    |       |   +-- social_page.dart
    |       |   +-- stress_page.dart
    |       +-- widgets/
    |
    +-- body/
    |   +-- domain/
    |   |   +-- entities/
    |   |   |   +-- sleep_entry.dart
    |   |   |   +-- workout.dart
    |   |   |   +-- menstrual_entry.dart
    |   |   |   +-- skin_hair_entry.dart
    |   |   |   +-- health_record.dart
    |   |   +-- repositories/
    |   |   +-- usecases/
    |   +-- data/
    |   +-- presentation/
    |       +-- providers/
    |       +-- pages/
    |       |   +-- body_dashboard_page.dart
    |       |   +-- sleep_page.dart
    |       |   +-- workout_page.dart
    |       |   +-- menstrual_page.dart
    |       |   +-- skin_hair_page.dart
    |       |   +-- health_records_page.dart
    |       +-- widgets/
    |
    +-- home/
        +-- domain/
        |   +-- entities/
        |   |   +-- car_record.dart
        |   |   +-- garden_entry.dart
        |   |   +-- pet.dart
        |   |   +-- pet_entry.dart
        |   |   +-- cleaning_task.dart
        |   |   +-- home_inventory_item.dart
        |   +-- repositories/
        |   +-- usecases/
        +-- data/
        +-- presentation/
            +-- providers/
            +-- pages/
            |   +-- home_dashboard_page.dart
            |   +-- car_page.dart
            |   +-- garden_page.dart
            |   +-- pets_page.dart
            |   +-- cleaning_page.dart
            |   +-- home_inventory_page.dart
            +-- widgets/

test/
+-- shared/
|   +-- domain/
|   |   +-- usecases/
|   +-- data/
|       +-- repositories/
|       +-- datasources/
+-- features/
|   +-- money/
|   +-- fuel/
|   +-- work/
|   +-- mind/
|   +-- body/
|   +-- home/
+-- comic/
+-- integration/

assets/
+-- fonts/
|   +-- Bangers-Regular.ttf
|   +-- ComicNeue-Regular.ttf
|   +-- ComicNeue-Bold.ttf
|   +-- ComicNeue-Light.ttf
+-- images/
|   +-- halftone_pattern.png
|   +-- splash_logo.png
|   +-- empty_states/
+-- animations/
    +-- yoga_figure/
```

---

## 5. State Management Strategy

### Riverpod 3 with Codegen

All reactive state in the presentation layer uses Riverpod 3 with the `@riverpod` annotation codegen.

#### Provider Types Used

| Provider Type | Use Case | Example |
|--------------|----------|---------|
| `@riverpod` (auto-dispose) | One-shot data fetches | `getEntriesForToday` |
| `@Riverpod(keepAlive: true)` | Long-lived state | `selectedAccount`, `activeArea` |
| `@riverpod` Stream | Reactive Isar watches | `watchEntries` (Isar query stream) |
| Family providers | Parameterized queries | `entriesByDateRange(start, end)` |
| Notifier providers | Mutable state with methods | `TransactionFormNotifier` |

#### Provider Organization

Each feature has a single `*_providers.dart` file containing all providers for that feature. Shared providers live in `shared/presentation/providers/`.

```dart
// Example: money_providers.dart

@riverpod
class MoneyDashboard extends _$MoneyDashboard {
  @override
  Future<MoneyDashboardState> build() async {
    final getOverview = sl<GetMoneyOverview>();
    final result = await getOverview(NoParams());
    return result.fold(
      (failure) => MoneyDashboardState.error(failure.message),
      (overview) => MoneyDashboardState.loaded(overview),
    );
  }
}

@riverpod
Future<Either<Failure, void>> addTransaction(
  AddTransactionRef ref,
  TransactionParams params,
) async {
  final useCase = sl<AddTransaction>();
  final result = await useCase(params);
  // Invalidate dashboard to refresh
  ref.invalidate(moneyDashboardProvider);
  return result;
}
```

### get_it for Construction

The `get_it` service locator handles the construction of all non-reactive dependencies:

```dart
// injection_container.dart

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Database
  final isar = await Isar.open([
    TrackableEntryModelSchema,
    CategoryModelSchema,
    // ... all schemas
  ]);
  sl.registerSingleton<Isar>(isar);

  // DataSources
  sl.registerLazySingleton<TrackableLocalDataSource>(
    () => TrackableLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<TrackableRepository>(
    () => TrackableRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => AddEntry(sl()));
  sl.registerLazySingleton(() => GetEntries(sl()));
  // ... etc for all use cases

  // Feature-specific registrations
  _initMoney();
  _initFuel();
  _initWork();
  _initMind();
  _initBody();
  _initHome();
}
```

---

## 6. Data Flow

### Write Flow (Logging an Entry)

```
User taps "Save" on Add Transaction page
         |
         v
Page calls ref.read(addTransactionProvider(params))
         |
         v
Riverpod provider delegates to sl<AddTransaction>() use case
         |
         v
AddTransaction.call(params) validates input
         |
         v
Calls MoneyRepository.addTransaction(entity)
         |
         v
MoneyRepositoryImpl maps entity -> Isar model
         |
         v
MoneyLocalDataSource.insert(model) writes to Isar
         |
         v
Returns Either<Failure, TransactionId>
         |
         v
Provider invalidates dashboard providers to trigger refresh
         |
         v
UI shows success feedback (comic "KA-CHING!" animation)
```

### Read Flow (Loading Dashboard)

```
Dashboard page builds, watches moneyDashboardProvider
         |
         v
MoneyDashboard notifier builds -> calls sl<GetMoneyOverview>()
         |
         v
GetMoneyOverview.call() delegates to MoneyRepository
         |
         v
MoneyRepositoryImpl queries multiple datasources
         |
         v
TrackableLocalDataSource.getByArea(LifeArea.money, dateRange)
AccountLocalDataSource.getAll()
BudgetLocalDataSource.getActive()
         |
         v
Results mapped from Isar models to domain entities
         |
         v
Returned as Either<Failure, MoneyOverview>
         |
         v
Provider exposes state to UI
         |
         v
Dashboard page renders with comic-styled widgets
```

---

## 7. Navigation Architecture

### GoRouter Configuration

```dart
final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    // Dashboard (main)
    GoRoute(
      path: '/dashboard',
      builder: (_, __) => const DashboardPage(),
    ),

    // Money routes
    ShellRoute(
      builder: (_, __, child) => MoneyShell(child: child),
      routes: [
        GoRoute(path: '/money', builder: (_, __) => const MoneyDashboardPage()),
        GoRoute(path: '/money/add', builder: (_, __) => const AddTransactionPage()),
        GoRoute(path: '/money/accounts', builder: (_, __) => const AccountsPage()),
        GoRoute(path: '/money/budgets', builder: (_, __) => const BudgetPage()),
        GoRoute(path: '/money/investments', builder: (_, __) => const InvestmentsPage()),
        GoRoute(path: '/money/transfer', builder: (_, __) => const TransferPage()),
        GoRoute(path: '/money/records', builder: (_, __) => const RecordsPage()),
        GoRoute(path: '/money/categories', builder: (_, __) => const MoneyCategoriesPage()),
      ],
    ),

    // ... similar ShellRoute for fuel, work, mind, body, home

    // Smart Recovery
    GoRoute(
      path: '/recovery',
      builder: (_, __) => const SmartRecoveryPage(),
    ),
  ],
);
```

### Navigation Patterns

| Pattern | Usage |
|---------|-------|
| Dashboard -> Area Dashboard | Tap pie chart or grid cell |
| Area Dashboard -> Sub-page | Tap card or list item |
| Any page -> Add Entry | FAB or dedicated add button |
| Back navigation | GoRouter pop with comic transition |
| Deep link | `/money/add?category=groceries` |

---

## 8. Flame Hybrid Integration

The Flame game engine is used **exclusively** on Dashboard Screen 1 for the yoga figure animation and surrounding progress pie charts.

### Architecture

```
DashboardPage (Flutter PageView)
  +-- LifeOverviewScreen (Flutter widget)
       +-- GameWidget<LifeOverviewGame> (Flame bridge)
            +-- LifeOverviewGame (Flame FlameGame)
                 +-- YogaFigureComponent (animated sprite/skeletal)
                 +-- ProgressPieComponent x 6 (custom paint)
                 +-- TapDetector -> callback to Flutter (navigate to area)
```

### Key Design Decisions

1. **Isolated**: Flame only runs in this single `GameWidget`. No Flame code elsewhere.
2. **Data Bridge**: Riverpod providers supply completion percentages to the Flame game via `GameWidget`'s `overlayBuilder` or direct setter methods.
3. **Lifecycle**: Game pauses when the PageView scrolls away from Screen 1. Resumed when scrolled back.
4. **Tap Handling**: Tapping a pie chart fires a callback to Flutter, which uses GoRouter to navigate. Flame does not handle navigation.
5. **Fallback**: If Flame performance is poor on a device, a static Flutter fallback is available (simple `CustomPaint` pies without the yoga figure animation).

---

## 9. Error Handling Architecture

### Failure Hierarchy

```dart
sealed class Failure {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;
  const ValidationFailure(super.message, {required this.fieldErrors, super.code});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}
```

### Error Flow

```
Isar throws exception
         |
         v
DataSource catches -> returns Either.left(DatabaseFailure(...))
         |
         v
Repository passes Either through (no re-wrapping)
         |
         v
UseCase may add validation logic -> Either.left(ValidationFailure(...))
         |
         v
Provider exposes Either to widget
         |
         v
Widget calls either.fold(
  (failure) => ComicErrorPanel(failure),  // comic-styled error display
  (data) => DataWidget(data),
)
```

---

## 10. Testing Strategy

### Test Pyramid

```
        /\
       /  \        Integration Tests (key flows)
      /----\
     /      \      Widget Tests (critical pages)
    /--------\
   /          \    Unit Tests (domain + data: 80% coverage target)
  /____________\
```

### Testing Tools

| Tool | Purpose |
|------|---------|
| `flutter_test` | Unit and widget tests |
| `mockito` + `build_runner` | Generating mocks for repositories and datasources |
| `riverpod` test utilities | Overriding providers in tests |
| `integration_test` | Full-app integration tests |

### Test Organization

- Unit tests mirror `lib/` structure in `test/`
- Each use case has a corresponding test file
- Each repository implementation has a corresponding test file
- Widget tests cover key pages (dashboards, add entry flows)
- Integration tests cover critical user journeys (log expense, check budget, smart recovery)

---

## 11. Build and Codegen

### Code Generation Pipeline

Both Isar and Riverpod use `build_runner` for code generation:

```bash
# Generate all code (Isar models + Riverpod providers)
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs
```

### Generated Files

| Source | Generated | Purpose |
|--------|-----------|---------|
| `*_model.dart` with `@collection` | `*_model.g.dart` | Isar schema + query builders |
| `*_provider.dart` with `@riverpod` | `*_provider.g.dart` | Riverpod provider definitions |

### CI Commands

```bash
# Full build verification
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --release
```
