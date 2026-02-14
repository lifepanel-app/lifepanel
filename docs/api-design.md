# LifePanel - Internal Data Layer Interfaces

## Document Info
| Field | Value |
|-------|-------|
| **Last Updated** | 2026-02-14 |
| **Status** | Draft |

> **Note**: LifePanel is a fully offline app with no backend server. This document defines the **internal repository interfaces** and **data source contracts** that form the boundary between the Domain and Data layers in the Clean Architecture.

---

## 1. Overview

All data operations in LifePanel flow through repository interfaces defined in the Domain layer. The Data layer provides implementations that interact with Isar Community database.

### Error Handling Convention

Every fallible operation returns `Either<Failure, T>` from the `fpdart` package. The left side contains a typed `Failure`, the right side contains the success value.

```dart
import 'package:fpdart/fpdart.dart';

// All repositories use this return pattern
Future<Either<Failure, T>> operation();
```

### Failure Types

```dart
/// Base sealed class for all failures in the app.
sealed class Failure {
  final String message;
  final String? code;
  final StackTrace? stackTrace;
  const Failure(this.message, {this.code, this.stackTrace});
}

/// Failure originating from database operations (Isar read/write errors).
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code, super.stackTrace});
}

/// Failure when a requested entity is not found.
class NotFoundFailure extends Failure {
  final String entityType;
  final dynamic entityId;
  const NotFoundFailure(
    super.message, {
    required this.entityType,
    this.entityId,
    super.code,
    super.stackTrace,
  });
}

/// Failure when input validation fails.
class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;
  const ValidationFailure(
    super.message, {
    required this.fieldErrors,
    super.code,
    super.stackTrace,
  });
}

/// Failure when a constraint is violated (e.g., duplicate UUID, insufficient balance).
class ConstraintFailure extends Failure {
  final String constraint;
  const ConstraintFailure(
    super.message, {
    required this.constraint,
    super.code,
    super.stackTrace,
  });
}

/// Failure for unexpected/unknown errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.code, super.stackTrace});
}
```

### Common Parameter Types

```dart
/// Date range for queries.
class DateRange {
  final DateTime start;
  final DateTime end;
  const DateRange({required this.start, required this.end});
}

/// Pagination parameters.
class PageParams {
  final int offset;
  final int limit;
  const PageParams({this.offset = 0, this.limit = 50});
}

/// Sort order.
enum SortOrder { ascending, descending }

/// No parameters marker.
class NoParams {
  const NoParams();
}
```

---

## 2. Shared Repository Interfaces

### 2.1 TrackableRepository

The primary repository for the unified `TrackableEntry` entity. Used by all six life areas.

```dart
abstract class TrackableRepository {
  // ── CREATE ──

  /// Insert a new entry into the database.
  /// Returns the generated Isar id on success.
  Future<Either<Failure, int>> addEntry(TrackableEntry entry);

  /// Insert multiple entries at once (used by Smart Recovery bulk-fill
  /// and recurring engine).
  /// Returns the list of generated Isar ids on success.
  Future<Either<Failure, List<int>>> addEntries(List<TrackableEntry> entries);

  // ── READ ──

  /// Get a single entry by its Isar id.
  Future<Either<Failure, TrackableEntry>> getEntryById(int id);

  /// Get a single entry by its UUID.
  Future<Either<Failure, TrackableEntry>> getEntryByUuid(String uuid);

  /// Get all entries within a date range, across all areas.
  /// Used by the Daily Feed (Dashboard Screen 3).
  Future<Either<Failure, List<TrackableEntry>>> getEntriesByDateRange(
    DateRange dateRange, {
    SortOrder sortOrder = SortOrder.descending,
    PageParams? pageParams,
  });

  /// Get entries for a specific life area within a date range.
  /// Used by area dashboards.
  Future<Either<Failure, List<TrackableEntry>>> getEntriesByArea(
    LifeArea area,
    DateRange dateRange, {
    SortOrder sortOrder = SortOrder.descending,
    PageParams? pageParams,
  });

  /// Get entries for a specific area and sub-area within a date range.
  /// Most common query pattern for feature pages.
  Future<Either<Failure, List<TrackableEntry>>> getEntriesBySubArea(
    LifeArea area,
    SubArea subArea,
    DateRange dateRange, {
    SortOrder sortOrder = SortOrder.descending,
    PageParams? pageParams,
  });

  /// Get entries for a specific category within a date range.
  /// Used by category reports and budget tracking.
  Future<Either<Failure, List<TrackableEntry>>> getEntriesByCategory(
    int categoryId,
    DateRange dateRange, {
    SortOrder sortOrder = SortOrder.descending,
    PageParams? pageParams,
  });

  /// Get the count of entries for an area within a date range.
  /// Used for dashboard progress calculations without loading full entities.
  Future<Either<Failure, int>> getEntryCount(
    LifeArea area,
    DateRange dateRange,
  );

  /// Get the sum of numericValue for entries matching criteria.
  /// Used for totals (spending, calories, hours, etc.).
  Future<Either<Failure, double>> getNumericSum(
    LifeArea area,
    SubArea subArea,
    DateRange dateRange,
  );

  /// Get the most recent entry for a given area and sub-area.
  /// Used by Smart Recovery to detect gaps.
  Future<Either<Failure, TrackableEntry?>> getLatestEntry(
    LifeArea area,
    SubArea subArea,
  );

  // ── UPDATE ──

  /// Update an existing entry. The entry must have a valid id.
  Future<Either<Failure, void>> updateEntry(TrackableEntry entry);

  // ── DELETE ──

  /// Delete an entry by its Isar id.
  Future<Either<Failure, void>> deleteEntry(int id);

  /// Delete multiple entries by their Isar ids.
  /// Used for bulk operations (e.g., deleting all entries from a cancelled
  /// recurring rule).
  Future<Either<Failure, void>> deleteEntries(List<int> ids);

  // ── WATCH (Reactive) ──

  /// Watch entries for a specific area and date range.
  /// Returns a stream that emits whenever the matching entries change.
  /// Used by Riverpod stream providers for reactive UI updates.
  Stream<Either<Failure, List<TrackableEntry>>> watchEntriesByArea(
    LifeArea area,
    DateRange dateRange,
  );

  /// Watch all entries for today across all areas.
  /// Used by Daily Feed for real-time updates.
  Stream<Either<Failure, List<TrackableEntry>>> watchTodayEntries();

  // ── GAP DETECTION ──

  /// Detect logging gaps for a specific area.
  /// Returns a list of dates where no entries exist within the given range.
  /// Used by Smart Recovery.
  Future<Either<Failure, List<DateTime>>> detectGaps(
    LifeArea area,
    DateRange dateRange,
  );

  /// Detect logging gaps across all areas.
  /// Returns a map of area -> list of gap dates.
  Future<Either<Failure, Map<LifeArea, List<DateTime>>>> detectAllGaps(
    DateRange dateRange,
  );
}
```

---

### 2.2 CategoryRepository

```dart
abstract class CategoryRepository {
  // ── CREATE ──

  /// Add a new category.
  Future<Either<Failure, int>> addCategory(Category category);

  /// Add a new subcategory.
  Future<Either<Failure, int>> addSubcategory(Subcategory subcategory);

  // ── READ ──

  /// Get all active categories for a given area and sub-area.
  /// Sorted by sortOrder. Used by the category picker widget.
  Future<Either<Failure, List<Category>>> getCategories(
    LifeArea area,
    SubArea subArea,
  );

  /// Get all subcategories for a given category.
  /// Sorted by sortOrder.
  Future<Either<Failure, List<Subcategory>>> getSubcategories(int categoryId);

  /// Get a single category by id.
  Future<Either<Failure, Category>> getCategoryById(int id);

  /// Get a single subcategory by id.
  Future<Either<Failure, Subcategory>> getSubcategoryById(int id);

  /// Get all categories across all areas (for export/backup).
  Future<Either<Failure, List<Category>>> getAllCategories();

  // ── UPDATE ──

  /// Update an existing category.
  Future<Either<Failure, void>> updateCategory(Category category);

  /// Update an existing subcategory.
  Future<Either<Failure, void>> updateSubcategory(Subcategory subcategory);

  /// Reorder categories by updating their sortOrder fields.
  Future<Either<Failure, void>> reorderCategories(
    List<int> categoryIdsInNewOrder,
  );

  // ── DELETE (Soft) ──

  /// Deactivate a category (soft delete). Sets isActive = false.
  /// Does NOT delete associated entries (they keep the categoryId).
  Future<Either<Failure, void>> deactivateCategory(int id);

  /// Deactivate a subcategory (soft delete).
  Future<Either<Failure, void>> deactivateSubcategory(int id);

  // ── SEED ──

  /// Initialize default categories for all areas if they don't exist.
  /// Called during first app launch / bootstrap.
  Future<Either<Failure, void>> seedDefaultCategories();
}
```

---

### 2.3 RecurringRepository

```dart
abstract class RecurringRepository {
  // ── CREATE ──

  /// Create a new recurring rule linked to an entry template.
  Future<Either<Failure, int>> addRule(RecurringRule rule);

  // ── READ ──

  /// Get all active rules that are due (nextDueDate <= now).
  /// Used by the recurring engine on app start.
  Future<Either<Failure, List<RecurringRule>>> getDueRules();

  /// Get all active rules.
  Future<Either<Failure, List<RecurringRule>>> getActiveRules();

  /// Get a rule by its id.
  Future<Either<Failure, RecurringRule>> getRuleById(int id);

  /// Get the rule associated with a specific entry template.
  Future<Either<Failure, RecurringRule?>> getRuleByTemplateId(
    int entryTemplateId,
  );

  // ── UPDATE ──

  /// Update a rule (e.g., advance nextDueDate, increment occurrenceCount).
  Future<Either<Failure, void>> updateRule(RecurringRule rule);

  // ── DELETE ──

  /// Deactivate a rule (set isActive = false).
  /// Does NOT delete already-generated entries.
  Future<Either<Failure, void>> deactivateRule(int id);

  /// Hard delete a rule and optionally its generated entries.
  Future<Either<Failure, void>> deleteRule(
    int id, {
    bool deleteGeneratedEntries = false,
  });

  // ── PROCESS ──

  /// Process all due rules: generate entries for each, advance nextDueDate.
  /// Returns the number of entries generated.
  /// This is the main method called by the recurring engine.
  Future<Either<Failure, int>> processDueRules();
}
```

---

### 2.4 ReminderRepository

```dart
abstract class ReminderRepository {
  // ── CREATE ──

  /// Schedule a new reminder.
  Future<Either<Failure, int>> addReminder(Reminder reminder);

  // ── READ ──

  /// Get all active reminders.
  Future<Either<Failure, List<Reminder>>> getActiveReminders();

  /// Get reminders for a specific area.
  Future<Either<Failure, List<Reminder>>> getRemindersByArea(
    LifeArea area,
    SubArea subArea,
  );

  /// Get upcoming reminders (next 24 hours).
  Future<Either<Failure, List<Reminder>>> getUpcomingReminders();

  /// Get a reminder by id.
  Future<Either<Failure, Reminder>> getReminderById(int id);

  // ── UPDATE ──

  /// Update a reminder.
  Future<Either<Failure, void>> updateReminder(Reminder reminder);

  // ── DELETE ──

  /// Deactivate a reminder (set isActive = false).
  Future<Either<Failure, void>> deactivateReminder(int id);

  /// Delete a reminder permanently.
  Future<Either<Failure, void>> deleteReminder(int id);

  // ── SCHEDULING ──

  /// Sync all active reminders with the local notification system.
  /// Should be called after any reminder CRUD operation.
  Future<Either<Failure, void>> syncNotifications();
}
```

---

## 3. Money Repository Interfaces

### 3.1 MoneyRepository

```dart
abstract class MoneyRepository {
  // ── ACCOUNTS ──

  /// Add a new financial account.
  Future<Either<Failure, int>> addAccount(Account account);

  /// Get all active accounts sorted by sortOrder.
  Future<Either<Failure, List<Account>>> getAccounts();

  /// Get a single account by id.
  Future<Either<Failure, Account>> getAccountById(int id);

  /// Update an account (name, type, color, icon, sortOrder).
  Future<Either<Failure, void>> updateAccount(Account account);

  /// Update an account's balance directly.
  /// Used by Smart Recovery reconciliation.
  Future<Either<Failure, void>> updateAccountBalance(
    int accountId,
    double newBalance,
  );

  /// Deactivate an account (soft delete).
  Future<Either<Failure, void>> deactivateAccount(int id);

  /// Get the total balance across all active accounts.
  Future<Either<Failure, double>> getTotalBalance();

  // ── TRANSACTIONS ──

  /// Add a transaction entry and update the associated account balance.
  /// This is an atomic operation: entry insert + balance update.
  /// Returns the entry id.
  Future<Either<Failure, int>> addTransaction(
    TrackableEntry entry,
    int accountId,
    String transactionType, // 'income', 'expense'
  );

  /// Transfer money between two accounts.
  /// Creates two entries (debit + credit) and updates both balances atomically.
  /// Returns a tuple of (debitEntryId, creditEntryId).
  Future<Either<Failure, (int, int)>> transferFunds(
    int fromAccountId,
    int toAccountId,
    double amount,
    String? note,
    DateTime timestamp,
  );

  /// Get transactions for a specific account within a date range.
  Future<Either<Failure, List<TrackableEntry>>> getTransactionsByAccount(
    int accountId,
    DateRange dateRange, {
    SortOrder sortOrder = SortOrder.descending,
    PageParams? pageParams,
  });

  /// Get spending by category for a date range.
  /// Returns a map of categoryId -> total amount.
  /// Used by spending pie charts.
  Future<Either<Failure, Map<int, double>>> getSpendingByCategory(
    DateRange dateRange,
  );

  // ── BUDGETS ──

  /// Create a new budget.
  Future<Either<Failure, int>> addBudget(Budget budget);

  /// Get all active budgets.
  Future<Either<Failure, List<Budget>>> getActiveBudgets();

  /// Get a budget by id.
  Future<Either<Failure, Budget>> getBudgetById(int id);

  /// Update a budget.
  Future<Either<Failure, void>> updateBudget(Budget budget);

  /// Deactivate a budget.
  Future<Either<Failure, void>> deactivateBudget(int id);

  /// Get budget progress: how much has been spent against the budget limit.
  /// Returns a map of budgetId -> (spent, limit, percentage).
  Future<Either<Failure, Map<int, BudgetProgress>>> getBudgetProgress(
    DateRange dateRange,
  );

  // ── INVESTMENTS ──

  /// Add a new investment.
  Future<Either<Failure, int>> addInvestment(Investment investment);

  /// Get all active investments.
  Future<Either<Failure, List<Investment>>> getInvestments();

  /// Update an investment (e.g., new current value).
  Future<Either<Failure, void>> updateInvestment(Investment investment);

  /// Deactivate an investment.
  Future<Either<Failure, void>> deactivateInvestment(int id);

  /// Get total investment value across all active investments.
  Future<Either<Failure, double>> getTotalInvestmentValue();

  // ── RECONCILIATION (Smart Recovery) ──

  /// Reconcile an account after a gap.
  /// Takes the account id and new balance.
  /// Computes the difference and creates an adjustment entry.
  Future<Either<Failure, int>> reconcileAccount(
    int accountId,
    double currentBalance,
    DateTime reconciliationDate,
  );

  // ── OVERVIEW ──

  /// Get the money area overview for the dashboard.
  /// Aggregates: total balance, today's spending, this week's spending,
  /// this month's spending, budget statuses, recent transactions.
  Future<Either<Failure, MoneyOverview>> getOverview();
}

/// Budget progress data class.
class BudgetProgress {
  final double spent;
  final double limit;
  final double percentage; // spent / limit
  const BudgetProgress({
    required this.spent,
    required this.limit,
    required this.percentage,
  });
}

/// Money area overview data class.
class MoneyOverview {
  final double totalBalance;
  final double todaySpending;
  final double weekSpending;
  final double monthSpending;
  final List<BudgetProgress> budgetStatuses;
  final List<TrackableEntry> recentTransactions;
  final double totalInvestmentValue;
  const MoneyOverview({
    required this.totalBalance,
    required this.todaySpending,
    required this.weekSpending,
    required this.monthSpending,
    required this.budgetStatuses,
    required this.recentTransactions,
    required this.totalInvestmentValue,
  });
}
```

---

## 4. Fuel Repository Interfaces

### 4.1 FuelRepository

```dart
abstract class FuelRepository {
  // ── MEALS ──

  /// Log a meal entry.
  Future<Either<Failure, int>> logMeal(
    TrackableEntry entry,
    String mealType,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    int? recipeId,
  );

  /// Get meals for a date range.
  Future<Either<Failure, List<TrackableEntry>>> getMeals(DateRange dateRange);

  /// Get total calories and macros for a specific day.
  Future<Either<Failure, DailyNutrition>> getDailyNutrition(DateTime date);

  // ── LIQUIDS ──

  /// Log a liquid intake.
  Future<Either<Failure, int>> logLiquid(
    TrackableEntry entry,
    String liquidType,
    int volumeMl,
  );

  /// Get total liquid intake for a specific day.
  Future<Either<Failure, int>> getDailyLiquidIntake(DateTime date);

  /// Get liquid intake breakdown by type for a day.
  Future<Either<Failure, Map<String, int>>> getLiquidBreakdown(DateTime date);

  // ── SUPPLEMENTS ──

  /// Log a supplement intake.
  Future<Either<Failure, int>> logSupplement(
    TrackableEntry entry,
    String supplementName,
    String dosage,
  );

  /// Get supplements logged for a day.
  Future<Either<Failure, List<TrackableEntry>>> getDailySupplements(
    DateTime date,
  );

  // ── RECIPES ──

  /// Add a new recipe with ingredients.
  Future<Either<Failure, int>> addRecipe(
    Recipe recipe,
    List<Ingredient> ingredients,
  );

  /// Get all recipes.
  Future<Either<Failure, List<Recipe>>> getRecipes();

  /// Get a recipe by id with its ingredients.
  Future<Either<Failure, (Recipe, List<Ingredient>)>> getRecipeWithIngredients(
    int recipeId,
  );

  /// Update a recipe.
  Future<Either<Failure, void>> updateRecipe(
    Recipe recipe,
    List<Ingredient> ingredients,
  );

  /// Delete a recipe and its ingredients.
  Future<Either<Failure, void>> deleteRecipe(int id);

  // ── GROCERIES ──

  /// Add an item to the grocery shopping list.
  Future<Either<Failure, int>> addGroceryItem(GroceryItem item);

  /// Get all items on the shopping list (not yet purchased).
  Future<Either<Failure, List<GroceryItem>>> getShoppingList();

  /// Get pantry inventory items.
  Future<Either<Failure, List<GroceryItem>>> getPantryInventory();

  /// Toggle purchased status of a grocery item.
  Future<Either<Failure, void>> toggleGroceryPurchased(int id);

  /// Move a purchased item to pantry.
  Future<Either<Failure, void>> moveToPantry(int id);

  /// Delete a grocery item.
  Future<Either<Failure, void>> deleteGroceryItem(int id);

  // ── DIET PLANS ──

  /// Create or update a diet plan.
  Future<Either<Failure, int>> saveDietPlan(DietPlan plan);

  /// Get the active diet plan.
  Future<Either<Failure, DietPlan?>> getActiveDietPlan();

  /// Deactivate the current diet plan.
  Future<Either<Failure, void>> deactivateDietPlan(int id);

  // ── OVERVIEW ──

  /// Get the fuel area overview for the dashboard.
  Future<Either<Failure, FuelOverview>> getOverview();
}

/// Daily nutrition summary.
class DailyNutrition {
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int mealCount;
  const DailyNutrition({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.mealCount,
  });
}

/// Fuel area overview.
class FuelOverview {
  final DailyNutrition todayNutrition;
  final int todayWaterMl;
  final int waterGoalMl;
  final DietPlan? activeDietPlan;
  final List<TrackableEntry> recentMeals;
  final int supplementsTakenToday;
  const FuelOverview({
    required this.todayNutrition,
    required this.todayWaterMl,
    required this.waterGoalMl,
    required this.activeDietPlan,
    required this.recentMeals,
    required this.supplementsTakenToday,
  });
}
```

---

## 5. Work Repository Interfaces

### 5.1 WorkRepository

```dart
abstract class WorkRepository {
  // ── TASKS ──

  /// Add a new task.
  Future<Either<Failure, int>> addTask(Task task);

  /// Get all tasks, optionally filtered by status.
  Future<Either<Failure, List<Task>>> getTasks({String? statusFilter});

  /// Get tasks due today or overdue.
  Future<Either<Failure, List<Task>>> getDueTasks();

  /// Get a task by id.
  Future<Either<Failure, Task>> getTaskById(int id);

  /// Update a task (including status changes for kanban).
  Future<Either<Failure, void>> updateTask(Task task);

  /// Move a task to a new status (kanban drag-and-drop).
  Future<Either<Failure, void>> moveTask(
    int taskId,
    String newStatus,
    int newSortOrder,
  );

  /// Delete a task.
  Future<Either<Failure, void>> deleteTask(int id);

  // ── TIME CLOCK ──

  /// Punch in (start a work session).
  Future<Either<Failure, int>> punchIn({String? note, String? project});

  /// Punch out (end the current work session).
  /// Computes hours worked and creates a TrackableEntry.
  Future<Either<Failure, void>> punchOut(int timeClockId, {String? note});

  /// Get the currently active time clock (punched in, not yet out).
  Future<Either<Failure, TimeClock?>> getActiveTimeClock();

  /// Get time clock records for a date range.
  Future<Either<Failure, List<TimeClock>>> getTimeClockRecords(
    DateRange dateRange,
  );

  /// Get total hours worked for a date range.
  Future<Either<Failure, double>> getTotalHoursWorked(DateRange dateRange);

  // ── ALARMS ──

  /// Add a new alarm.
  Future<Either<Failure, int>> addAlarm(Alarm alarm);

  /// Get all alarms.
  Future<Either<Failure, List<Alarm>>> getAlarms();

  /// Update an alarm.
  Future<Either<Failure, void>> updateAlarm(Alarm alarm);

  /// Toggle an alarm's active state.
  Future<Either<Failure, void>> toggleAlarm(int id);

  /// Delete an alarm.
  Future<Either<Failure, void>> deleteAlarm(int id);

  // ── CALENDAR ──

  /// Add a calendar event.
  Future<Either<Failure, int>> addCalendarEvent(CalendarEvent event);

  /// Get events for a date range.
  Future<Either<Failure, List<CalendarEvent>>> getCalendarEvents(
    DateRange dateRange,
  );

  /// Get events for a specific day.
  Future<Either<Failure, List<CalendarEvent>>> getDayEvents(DateTime date);

  /// Update an event.
  Future<Either<Failure, void>> updateCalendarEvent(CalendarEvent event);

  /// Delete an event.
  Future<Either<Failure, void>> deleteCalendarEvent(int id);

  // ── CAREER GOALS ──

  /// Add a career goal.
  Future<Either<Failure, int>> addCareerGoal(CareerGoal goal);

  /// Get all career goals.
  Future<Either<Failure, List<CareerGoal>>> getCareerGoals();

  /// Update a career goal (including milestone completion).
  Future<Either<Failure, void>> updateCareerGoal(CareerGoal goal);

  /// Delete a career goal.
  Future<Either<Failure, void>> deleteCareerGoal(int id);

  // ── OVERVIEW ──

  /// Get the work area overview for the dashboard.
  Future<Either<Failure, WorkOverview>> getOverview();
}

/// Work area overview.
class WorkOverview {
  final List<Task> todayTasks;
  final int completedTodayCount;
  final double hoursWorkedToday;
  final double hoursWorkedThisWeek;
  final TimeClock? activeTimeClock;
  final List<CalendarEvent> upcomingEvents;
  final List<CareerGoal> activeGoals;
  const WorkOverview({
    required this.todayTasks,
    required this.completedTodayCount,
    required this.hoursWorkedToday,
    required this.hoursWorkedThisWeek,
    required this.activeTimeClock,
    required this.upcomingEvents,
    required this.activeGoals,
  });
}
```

---

## 6. Mind Repository Interfaces

### 6.1 MindRepository

```dart
abstract class MindRepository {
  // ── MOOD ──

  /// Log a mood entry.
  Future<Either<Failure, int>> logMood(
    TrackableEntry entry,
    MoodEntry moodData,
  );

  /// Get mood entries for a date range.
  Future<Either<Failure, List<MoodEntry>>> getMoodEntries(DateRange dateRange);

  /// Get the average mood level for a date range.
  Future<Either<Failure, double>> getAverageMood(DateRange dateRange);

  /// Get mood trend data (daily averages for charting).
  Future<Either<Failure, Map<DateTime, double>>> getMoodTrend(
    DateRange dateRange,
  );

  // ── JOURNAL ──

  /// Add a journal entry.
  Future<Either<Failure, int>> addJournalEntry(
    TrackableEntry entry,
    JournalEntry journalData,
  );

  /// Get journal entries for a date range.
  Future<Either<Failure, List<JournalEntry>>> getJournalEntries(
    DateRange dateRange,
  );

  /// Search journal entries by text content.
  Future<Either<Failure, List<JournalEntry>>> searchJournals(String query);

  /// Get journal entries by tag.
  Future<Either<Failure, List<JournalEntry>>> getJournalsByTag(String tag);

  /// Update a journal entry.
  Future<Either<Failure, void>> updateJournalEntry(JournalEntry entry);

  /// Delete a journal entry.
  Future<Either<Failure, void>> deleteJournalEntry(int id);

  // ── SOCIAL ──

  /// Log a social interaction.
  Future<Either<Failure, int>> logSocialInteraction(
    TrackableEntry entry,
    SocialInteraction interaction,
  );

  /// Get social interactions for a date range.
  Future<Either<Failure, List<SocialInteraction>>> getSocialInteractions(
    DateRange dateRange,
  );

  /// Get interaction count for a date range.
  Future<Either<Failure, int>> getSocialInteractionCount(DateRange dateRange);

  // ── STRESS ──

  /// Log a stress level.
  Future<Either<Failure, int>> logStressLevel(
    TrackableEntry entry,
    StressLevel stressData,
  );

  /// Get stress entries for a date range.
  Future<Either<Failure, List<StressLevel>>> getStressEntries(
    DateRange dateRange,
  );

  /// Get average stress for a date range.
  Future<Either<Failure, double>> getAverageStress(DateRange dateRange);

  /// Get stress trend data (daily averages).
  Future<Either<Failure, Map<DateTime, double>>> getStressTrend(
    DateRange dateRange,
  );

  // ── OVERVIEW ──

  /// Get the mind area overview for the dashboard.
  Future<Either<Failure, MindOverview>> getOverview();
}

/// Mind area overview.
class MindOverview {
  final double todayMood;
  final List<double> weekMoodTrend; // last 7 days
  final int journalStreakDays;
  final int socialInteractionsThisWeek;
  final double todayStress;
  const MindOverview({
    required this.todayMood,
    required this.weekMoodTrend,
    required this.journalStreakDays,
    required this.socialInteractionsThisWeek,
    required this.todayStress,
  });
}
```

---

## 7. Body Repository Interfaces

### 7.1 BodyRepository

```dart
abstract class BodyRepository {
  // ── SLEEP ──

  /// Log a sleep entry.
  Future<Either<Failure, int>> logSleep(
    TrackableEntry entry,
    SleepEntry sleepData,
  );

  /// Get sleep entries for a date range.
  Future<Either<Failure, List<SleepEntry>>> getSleepEntries(
    DateRange dateRange,
  );

  /// Get average sleep hours for a date range.
  Future<Either<Failure, double>> getAverageSleepHours(DateRange dateRange);

  /// Get sleep quality trend (daily quality ratings).
  Future<Either<Failure, Map<DateTime, int>>> getSleepQualityTrend(
    DateRange dateRange,
  );

  // ── WORKOUT ──

  /// Log a workout.
  Future<Either<Failure, int>> logWorkout(
    TrackableEntry entry,
    Workout workoutData,
  );

  /// Get workouts for a date range.
  Future<Either<Failure, List<Workout>>> getWorkouts(DateRange dateRange);

  /// Get workout count for a date range (e.g., workouts this week).
  Future<Either<Failure, int>> getWorkoutCount(DateRange dateRange);

  /// Get total calories burned in workouts for a date range.
  Future<Either<Failure, int>> getTotalCaloriesBurned(DateRange dateRange);

  // ── MENSTRUAL ──

  /// Log a menstrual entry.
  Future<Either<Failure, int>> logMenstrualEntry(
    TrackableEntry entry,
    MenstrualEntry menstrualData,
  );

  /// Get menstrual entries for a date range.
  Future<Either<Failure, List<MenstrualEntry>>> getMenstrualEntries(
    DateRange dateRange,
  );

  /// Get the current cycle day based on logged data.
  Future<Either<Failure, int?>> getCurrentCycleDay();

  /// Get predicted next period start date based on historical cycle lengths.
  Future<Either<Failure, DateTime?>> getPredictedNextPeriod();

  /// Get average cycle length from logged data.
  Future<Either<Failure, int?>> getAverageCycleLength();

  // ── SKIN/HAIR ──

  /// Log a skin/hair routine entry.
  Future<Either<Failure, int>> logSkinHairEntry(
    TrackableEntry entry,
    SkinHairEntry skinHairData,
  );

  /// Get skin/hair entries for a date range.
  Future<Either<Failure, List<SkinHairEntry>>> getSkinHairEntries(
    DateRange dateRange,
  );

  // ── HEALTH RECORDS ──

  /// Log a health record.
  Future<Either<Failure, int>> logHealthRecord(
    TrackableEntry entry,
    HealthRecord healthData,
  );

  /// Get health records for a date range.
  Future<Either<Failure, List<HealthRecord>>> getHealthRecords(
    DateRange dateRange,
  );

  /// Get health records by type (e.g., all weight entries).
  Future<Either<Failure, List<HealthRecord>>> getHealthRecordsByType(
    String recordType,
    DateRange dateRange,
  );

  /// Get the latest health record of a given type.
  Future<Either<Failure, HealthRecord?>> getLatestHealthRecord(
    String recordType,
  );

  // ── OVERVIEW ──

  /// Get the body area overview for the dashboard.
  Future<Either<Failure, BodyOverview>> getOverview();
}

/// Body area overview.
class BodyOverview {
  final SleepEntry? lastNightSleep;
  final double avgSleepHoursThisWeek;
  final int workoutsThisWeek;
  final int? currentCycleDay;
  final DateTime? nextPredictedPeriod;
  final HealthRecord? latestWeight;
  final List<HealthRecord> upcomingAppointments;
  const BodyOverview({
    required this.lastNightSleep,
    required this.avgSleepHoursThisWeek,
    required this.workoutsThisWeek,
    required this.currentCycleDay,
    required this.nextPredictedPeriod,
    required this.latestWeight,
    required this.upcomingAppointments,
  });
}
```

---

## 8. Home Repository Interfaces

### 8.1 HomeRepository

```dart
abstract class HomeRepository {
  // ── CAR ──

  /// Log a car service/maintenance record.
  Future<Either<Failure, int>> logCarRecord(
    TrackableEntry entry,
    CarRecord carData,
  );

  /// Get all car records for a date range.
  Future<Either<Failure, List<CarRecord>>> getCarRecords(DateRange dateRange);

  /// Get upcoming car service reminders.
  Future<Either<Failure, List<CarRecord>>> getUpcomingCarServices();

  // ── GARDEN ──

  /// Log a garden activity.
  Future<Either<Failure, int>> logGardenEntry(
    TrackableEntry entry,
    GardenEntry gardenData,
  );

  /// Get garden entries for a date range.
  Future<Either<Failure, List<GardenEntry>>> getGardenEntries(
    DateRange dateRange,
  );

  /// Get garden entries for a specific plant.
  Future<Either<Failure, List<GardenEntry>>> getGardenEntriesByPlant(
    String plantName,
  );

  // ── PETS ──

  /// Add a new pet profile.
  Future<Either<Failure, int>> addPet(Pet pet);

  /// Get all active pets.
  Future<Either<Failure, List<Pet>>> getPets();

  /// Get a pet by id.
  Future<Either<Failure, Pet>> getPetById(int id);

  /// Update a pet profile.
  Future<Either<Failure, void>> updatePet(Pet pet);

  /// Deactivate a pet.
  Future<Either<Failure, void>> deactivatePet(int id);

  /// Log a pet entry (feeding, walk, vet visit, etc.).
  Future<Either<Failure, int>> logPetEntry(
    TrackableEntry entry,
    PetEntry petData,
  );

  /// Get entries for a specific pet.
  Future<Either<Failure, List<PetEntry>>> getPetEntries(
    int petId,
    DateRange dateRange,
  );

  /// Get entries for a specific pet by type.
  Future<Either<Failure, List<PetEntry>>> getPetEntriesByType(
    int petId,
    String entryType,
    DateRange dateRange,
  );

  // ── CLEANING ──

  /// Add a cleaning task to a room's checklist.
  Future<Either<Failure, int>> addCleaningTask(CleaningTask task);

  /// Get all cleaning tasks, optionally filtered by room.
  Future<Either<Failure, List<CleaningTask>>> getCleaningTasks({
    String? roomFilter,
  });

  /// Get overdue cleaning tasks.
  Future<Either<Failure, List<CleaningTask>>> getOverdueCleaningTasks();

  /// Mark a cleaning task as completed.
  /// Creates a TrackableEntry and updates lastCompleted/nextDue.
  Future<Either<Failure, void>> completeCleaningTask(
    int taskId,
    DateTime completedAt,
  );

  /// Update a cleaning task definition.
  Future<Either<Failure, void>> updateCleaningTask(CleaningTask task);

  /// Delete a cleaning task.
  Future<Either<Failure, void>> deleteCleaningTask(int id);

  // ── HOME INVENTORY ──

  /// Add an item to home inventory.
  Future<Either<Failure, int>> addInventoryItem(HomeInventoryItem item);

  /// Get all active inventory items.
  Future<Either<Failure, List<HomeInventoryItem>>> getInventoryItems({
    String? roomFilter,
    String? categoryFilter,
  });

  /// Get items with expiring warranties (within next N days).
  Future<Either<Failure, List<HomeInventoryItem>>> getExpiringWarranties(
    int withinDays,
  );

  /// Search inventory items by name.
  Future<Either<Failure, List<HomeInventoryItem>>> searchInventory(
    String query,
  );

  /// Update an inventory item.
  Future<Either<Failure, void>> updateInventoryItem(HomeInventoryItem item);

  /// Deactivate an inventory item (no longer owned).
  Future<Either<Failure, void>> deactivateInventoryItem(int id);

  // ── OVERVIEW ──

  /// Get the home area overview for the dashboard.
  Future<Either<Failure, HomeOverview>> getOverview();
}

/// Home area overview.
class HomeOverview {
  final List<CarRecord> upcomingCarServices;
  final List<GardenEntry> recentGardenActivity;
  final List<Pet> activePets;
  final List<CleaningTask> overdueCleaningTasks;
  final int cleaningTasksDueToday;
  final List<HomeInventoryItem> expiringWarranties;
  const HomeOverview({
    required this.upcomingCarServices,
    required this.recentGardenActivity,
    required this.activePets,
    required this.overdueCleaningTasks,
    required this.cleaningTasksDueToday,
    required this.expiringWarranties,
  });
}
```

---

## 9. Data Source Contracts

Data sources are the lowest layer, directly interfacing with Isar. They handle raw database operations and throw internal exceptions (which repository implementations catch and convert to `Either<Failure, T>`).

### 9.1 TrackableLocalDataSource

```dart
/// Local data source for TrackableEntry Isar operations.
/// Methods throw [DatabaseException] on failure.
/// Repository implementations catch these and return Either<Failure, T>.
abstract class TrackableLocalDataSource {
  Future<int> insert(TrackableEntryModel model);
  Future<List<int>> insertAll(List<TrackableEntryModel> models);
  Future<TrackableEntryModel?> getById(int id);
  Future<TrackableEntryModel?> getByUuid(String uuid);
  Future<List<TrackableEntryModel>> getByDateRange(
    DateTime start,
    DateTime end, {
    bool descending = true,
    int? offset,
    int? limit,
  });
  Future<List<TrackableEntryModel>> getByArea(
    String area,
    DateTime start,
    DateTime end, {
    bool descending = true,
    int? offset,
    int? limit,
  });
  Future<List<TrackableEntryModel>> getByAreaAndSubArea(
    String area,
    String subArea,
    DateTime start,
    DateTime end, {
    bool descending = true,
    int? offset,
    int? limit,
  });
  Future<List<TrackableEntryModel>> getByCategory(
    int categoryId,
    DateTime start,
    DateTime end, {
    bool descending = true,
    int? offset,
    int? limit,
  });
  Future<int> countByArea(String area, DateTime start, DateTime end);
  Future<double> sumNumericBySubArea(
    String area,
    String subArea,
    DateTime start,
    DateTime end,
  );
  Future<TrackableEntryModel?> getLatest(String area, String subArea);
  Future<void> update(TrackableEntryModel model);
  Future<void> delete(int id);
  Future<void> deleteMany(List<int> ids);
  Stream<List<TrackableEntryModel>> watchByArea(
    String area,
    DateTime start,
    DateTime end,
  );
  Stream<List<TrackableEntryModel>> watchToday();
  Future<List<DateTime>> findGapDates(
    String area,
    DateTime start,
    DateTime end,
  );
}
```

### 9.2 Pattern for All Other DataSources

Each feature-specific data source follows the same contract pattern:

```dart
/// Template for feature-specific local data sources.
abstract class FeatureLocalDataSource<T> {
  Future<int> insert(T model);
  Future<T?> getById(int id);
  Future<List<T>> getAll({String? filter, int? offset, int? limit});
  Future<void> update(T model);
  Future<void> delete(int id);
}
```

Feature-specific data sources extend this pattern with domain-specific queries (e.g., `getByRoom` for CleaningTask, `getByPetId` for PetEntry).

---

## 10. Query Patterns Summary

| Pattern | Repository Method | DataSource Query | Index Used |
|---------|------------------|-----------------|------------|
| Today's entries (all areas) | `getEntriesByDateRange(today)` | `getByDateRange(todayStart, todayEnd)` | `[timestamp]` |
| Area dashboard data | `getEntriesByArea(money, thisMonth)` | `getByArea("money", monthStart, monthEnd)` | `[area, timestamp]` |
| Sub-area page data | `getEntriesBySubArea(fuel, meals, thisWeek)` | `getByAreaAndSubArea("fuel", "meals", ...)` | `[area, subArea, timestamp]` |
| Category spending | `getSpendingByCategory(thisMonth)` | `getByCategory(catId, monthStart, monthEnd)` | `[categoryId]` |
| Gap detection | `detectGaps(money, last14days)` | `findGapDates("money", ...)` | `[area, timestamp]` |
| Latest entry | `getLatestEntry(fuel, meals)` | `getLatest("fuel", "meals")` | `[area, subArea, timestamp]` |
| Due recurring rules | `getDueRules()` | `getByNextDueDate(now)` | `[isActive, nextDueDate]` |
| Upcoming reminders | `getUpcomingReminders()` | `getByReminderTime(now, tomorrow)` | `[isActive, reminderTime]` |
| Tasks by status | `getTasks(statusFilter: "todo")` | `getByStatus("todo")` | `[status, sortOrder]` |
| Shopping list | `getShoppingList()` | `getUnpurchased()` | `[isPurchased]` |
| Expiring warranties | `getExpiringWarranties(30)` | `getByWarrantyExpiry(now, now+30days)` | `[warrantyExpires]` |

---

## 11. Batch Operations

### Smart Recovery Bulk-Fill

```dart
/// Bulk-fill operation used by Smart Recovery.
/// Takes a list of entries for missed days and inserts them all.
///
/// For Money entries, this also:
/// 1. Creates adjustment entries for balance reconciliation
/// 2. Updates account balances accordingly
///
/// Returns the count of successfully inserted entries.
Future<Either<Failure, int>> bulkFillEntries(
  List<TrackableEntry> entries, {
  Map<int, double>? accountReconciliations, // accountId -> new balance
});
```

### Recurring Engine Batch Processing

```dart
/// Process all due recurring rules in a single batch.
/// For each due rule:
/// 1. Generate entry from template with correct timestamp
/// 2. Insert entry
/// 3. Advance rule's nextDueDate
/// 4. Increment occurrenceCount
/// 5. Deactivate rule if maxOccurrences reached or endDate passed
///
/// Returns count of generated entries.
Future<Either<Failure, int>> processDueRules();
```

### Category Reordering

```dart
/// Reorder categories in a single batch update.
/// Takes a list of category IDs in their new display order.
/// Updates sortOrder for each in a single Isar write transaction.
Future<Either<Failure, void>> reorderCategories(
  List<int> categoryIdsInNewOrder,
);
```

---

## 12. Error Scenarios

| Operation | Possible Failures | Failure Type |
|-----------|------------------|--------------|
| Insert entry | Isar write fails, disk full | `DatabaseFailure` |
| Insert entry | Invalid area/subArea | `ValidationFailure` |
| Get entry by id | Entry not found | `NotFoundFailure` |
| Transfer funds | Source account has insufficient balance | `ConstraintFailure` |
| Transfer funds | Source or destination account not found | `NotFoundFailure` |
| Add budget | Duplicate budget for same category+period | `ConstraintFailure` |
| Update account balance | Account not found | `NotFoundFailure` |
| Punch out | No active time clock | `NotFoundFailure` |
| Process recurring rules | Template entry deleted | `NotFoundFailure` |
| Search journals | Empty query string | `ValidationFailure` |
| Reconcile account | Account not found | `NotFoundFailure` |
| Delete category | Category has entries (warning only, soft-delete) | N/A (succeeds with deactivation) |
| Any Isar operation | Unexpected Isar error | `UnexpectedFailure` |
