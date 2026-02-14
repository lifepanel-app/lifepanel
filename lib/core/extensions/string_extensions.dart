extension StringX on String {
  /// Capitalize first letter.
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Convert snake_case to Title Case.
  String get snakeToTitle {
    return split('_').map((w) => w.capitalized).join(' ');
  }
}
