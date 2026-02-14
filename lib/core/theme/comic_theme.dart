import 'package:flutter/material.dart';

import 'comic_colors.dart';
import 'comic_typography.dart';

/// Comic book style theme for LifePanel.
///
/// Bold outlines, drop shadows, hand-drawn feel.
abstract class ComicTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ComicColors.primary,
          brightness: Brightness.light,
          surface: ComicColors.surface,
        ),
        scaffoldBackgroundColor: ComicColors.background,
        textTheme: ComicTypography.textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: ComicColors.primary,
          foregroundColor: ComicColors.textOnPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: ComicColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: ComicColors.outline, width: 2.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ComicColors.secondary,
            foregroundColor: ComicColors.textOnPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: ComicColors.outline, width: 2.5),
            ),
            textStyle: const TextStyle(
              fontFamily: 'ComicNeue',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ComicColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ComicColors.outline, width: 2.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ComicColors.outline, width: 2.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ComicColors.secondary, width: 3),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: ComicColors.secondary,
          foregroundColor: ComicColors.textOnPrimary,
          elevation: 0,
          shape: CircleBorder(
            side: BorderSide(color: ComicColors.outline, width: 2.5),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: ComicColors.outline,
          thickness: 2,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: ComicColors.surface,
          side: const BorderSide(color: ComicColors.outline, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ComicColors.primary,
          brightness: Brightness.dark,
        ),
        textTheme: ComicTypography.textTheme,
        // TODO: Full dark theme customization
      );
}
