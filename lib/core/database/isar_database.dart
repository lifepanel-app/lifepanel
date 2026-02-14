/// Isar database initialization and schema registration.
///
/// All Isar collection schemas are registered here.
/// Called during bootstrap before the app starts.
// TODO: Implement once Isar models are created in Phase 1
//
// Usage:
// ```dart
// final isar = await initIsarDatabase();
// ```
//
// Future<Isar> initIsarDatabase() async {
//   final dir = await getApplicationDocumentsDirectory();
//   return Isar.open(
//     [
//       TrackableEntryModelSchema,
//       CategoryModelSchema,
//       SubcategoryModelSchema,
//       RecurringRuleModelSchema,
//       ReminderModelSchema,
//       AccountModelSchema,
//       BudgetModelSchema,
//       InvestmentModelSchema,
//       RecipeModelSchema,
//       GroceryItemModelSchema,
//       DietPlanModelSchema,
//       TaskModelSchema,
//       TimeClockModelSchema,
//       AlarmModelSchema,
//       CalendarEventModelSchema,
//       MoodEntryModelSchema,
//       JournalEntryModelSchema,
//       SocialInteractionModelSchema,
//       StressLevelModelSchema,
//       SleepEntryModelSchema,
//       WorkoutModelSchema,
//       MenstrualEntryModelSchema,
//       SkinHairEntryModelSchema,
//       HealthRecordModelSchema,
//       CarRecordModelSchema,
//       GardenEntryModelSchema,
//       PetModelSchema,
//       PetEntryModelSchema,
//       CleaningTaskModelSchema,
//       HomeInventoryItemModelSchema,
//     ],
//     directory: dir.path,
//     name: AppConstants.isarDbName,
//   );
// }
