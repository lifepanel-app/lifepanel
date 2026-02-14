extension DateTimeX on DateTime {
  /// Returns date only (no time component).
  DateTime get dateOnly => DateTime(year, month, day);

  /// Whether this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Whether this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Number of days between this and [other].
  int daysBetween(DateTime other) {
    return dateOnly.difference(other.dateOnly).inDays.abs();
  }

  /// Start of the current week (Monday).
  DateTime get startOfWeek {
    final diff = weekday - DateTime.monday;
    return dateOnly.subtract(Duration(days: diff));
  }

  /// Start of the current month.
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// End of the current month.
  DateTime get endOfMonth => DateTime(year, month + 1, 0);
}
