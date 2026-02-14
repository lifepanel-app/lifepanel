import 'package:flutter/material.dart';

/// Comic book style color palette for LifePanel.
abstract class ComicColors {
  // Primary comic palette
  static const Color primary = Color(0xFF1A1A2E);
  static const Color secondary = Color(0xFFE94560);
  static const Color accent = Color(0xFF0F3460);
  static const Color background = Color(0xFFFFF8E7);
  static const Color surface = Color(0xFFFFFFFF);

  // Comic text colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF555555);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Comic border/outline
  static const Color outline = Color(0xFF1A1A2E);
  static const Color outlineLight = Color(0xFF333333);

  // Comic shadow
  static const Color shadow = Color(0xFF1A1A2E);
  static const Color shadowLight = Color(0x401A1A2E);

  // Life area colors (bold comic primaries)
  static const Color money = Color(0xFF4CAF50);
  static const Color fuel = Color(0xFFFF9800);
  static const Color work = Color(0xFF2196F3);
  static const Color mind = Color(0xFF9C27B0);
  static const Color body = Color(0xFFF44336);
  static const Color home = Color(0xFF795548);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Halftone dot color
  static const Color halftone = Color(0x15000000);
}
