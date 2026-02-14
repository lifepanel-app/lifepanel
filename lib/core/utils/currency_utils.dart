import 'package:intl/intl.dart';

/// Currency formatting utilities.
abstract class CurrencyUtils {
  static final _usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _compactFormat = NumberFormat.compact();

  /// Format as currency (e.g., $1,234.56).
  static String format(double amount, {String symbol = '\$'}) {
    if (symbol == '\$') return _usdFormat.format(amount);
    return NumberFormat.currency(symbol: symbol, decimalDigits: 2).format(amount);
  }

  /// Format as compact (e.g., 1.2K, 3.4M).
  static String compact(double amount) => _compactFormat.format(amount);
}
