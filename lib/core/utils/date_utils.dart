import 'package:intl/intl.dart';

/// Date formatting utilities for LifePanel.
abstract class AppDateUtils {
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _timeFormat = DateFormat('h:mm a');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy h:mm a');
  static final _shortDate = DateFormat('MMM d');
  static final _dayName = DateFormat('EEEE');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
  static String formatShortDate(DateTime date) => _shortDate.format(date);
  static String formatDayName(DateTime date) => _dayName.format(date);

  /// Returns "Morning", "Afternoon", "Evening", or "Night" for a given hour.
  static String timeOfDay(int hour) {
    if (hour < 6) return 'Night';
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    if (hour < 21) return 'Evening';
    return 'Night';
  }
}
