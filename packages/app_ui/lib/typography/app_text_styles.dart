import 'package:flutter/material.dart';

import '../src/generated/fonts.gen.dart';

/// The app consists of two main text style definitions: UI and Content.
///
/// Content text style is primarily used for all content-based components,
/// e.g. news feed including articles and sections, while the UI text style
/// is used for the rest of UI components.
///
/// The default app's [TextTheme] is [AppTheme.uiTextTheme].
///
/// Use [ContentThemeOverrideBuilder] to override the default [TextTheme]
/// to [AppTheme.contentTextTheme].

abstract class TextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 44,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w700,
    fontFamily: FontFamily.pretendard,
    height: 52 / 44,
    letterSpacing: 0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 40,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w700,
    fontFamily: FontFamily.pretendard,
    height: 48 / 40,
    letterSpacing: 0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w700,
    fontFamily: FontFamily.pretendard,
    height: 44 / 36,
    letterSpacing: 0,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamily.pretendard,
    height: 40 / 32,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamily.pretendard,
    height: 36 / 28,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamily.pretendard,
    height: 32 / 24,
    letterSpacing: 0,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamily.pretendard,
    height: 28 / 22,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamily.pretendard,
    height: 24 / 16,
    letterSpacing: 0,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamily.pretendard,
    height: 20 / 14,
    letterSpacing: 0,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w400,
    fontFamily: FontFamily.pretendard,
    height: 24 / 16,
    letterSpacing: 0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w400,
    fontFamily: FontFamily.pretendard,
    height: 20 / 14,
    letterSpacing: 0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w400,
    fontFamily: FontFamily.pretendard,
    height: 16 / 12,
    letterSpacing: 0,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamily.pretendard,
    height: 20 / 14,
    letterSpacing: 0,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamily.pretendard,
    height: 16 / 12,
    letterSpacing: 0,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamily.pretendard,
    height: 16 / 11,
    letterSpacing: 0,
  );
}
