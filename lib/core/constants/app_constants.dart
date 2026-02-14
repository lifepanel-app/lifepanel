/// App-wide constants for LifePanel.
abstract class AppConstants {
  static const String appName = 'LifePanel';
  static const String appVersion = '0.1.0';

  // Database
  static const String isarDbName = 'lifepanel_db';

  // Defaults
  static const int defaultMoodScale = 10;
  static const int defaultStressScale = 10;
  static const double defaultWaterGoalMl = 2000.0;
  static const int defaultSleepGoalHours = 8;

  // Animation durations
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Dashboard
  static const int dashboardScreenCount = 3;
  static const int lifeAreaCount = 6;
}
