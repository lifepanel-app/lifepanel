import 'package:flutter/material.dart';

import '../constants/asset_paths.dart';
import 'comic_colors.dart';

/// Comic book style typography for LifePanel.
abstract class ComicTypography {
  /// Bangers font for headers — bold, impactful, comic-style.
  static const String _headerFont = AssetPaths.bangersFont;

  /// Comic Neue for body text — readable, friendly, hand-drawn feel.
  static const String _bodyFont = AssetPaths.comicNeueFont;

  static TextTheme get textTheme => const TextTheme(
        // Display styles (Bangers - comic headers)
        displayLarge: TextStyle(
          fontFamily: _headerFont,
          fontSize: 40,
          color: ComicColors.textPrimary,
          letterSpacing: 1.5,
        ),
        displayMedium: TextStyle(
          fontFamily: _headerFont,
          fontSize: 32,
          color: ComicColors.textPrimary,
          letterSpacing: 1.2,
        ),
        displaySmall: TextStyle(
          fontFamily: _headerFont,
          fontSize: 28,
          color: ComicColors.textPrimary,
          letterSpacing: 1.0,
        ),

        // Headline styles (Bangers)
        headlineLarge: TextStyle(
          fontFamily: _headerFont,
          fontSize: 24,
          color: ComicColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: _headerFont,
          fontSize: 20,
          color: ComicColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: _headerFont,
          fontSize: 18,
          color: ComicColors.textPrimary,
        ),

        // Title styles (Comic Neue Bold)
        titleLarge: TextStyle(
          fontFamily: _bodyFont,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ComicColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: _bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ComicColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: _bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: ComicColors.textPrimary,
        ),

        // Body styles (Comic Neue Regular)
        bodyLarge: TextStyle(
          fontFamily: _bodyFont,
          fontSize: 16,
          color: ComicColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: _bodyFont,
          fontSize: 14,
          color: ComicColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: _bodyFont,
          fontSize: 12,
          color: ComicColors.textSecondary,
        ),

        // Label styles (Comic Neue)
        labelLarge: TextStyle(
          fontFamily: _bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: ComicColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: _bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: ComicColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontFamily: _bodyFont,
          fontSize: 10,
          color: ComicColors.textSecondary,
        ),
      );
}
