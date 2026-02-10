import 'package:flutter/material.dart';

import '../colors/matrial_color_schemes.dart';

extension AppColorSchemeExtension on BuildContext {
  Color get primary => Theme.of(this).colorScheme.primary;
  Color get onPrimary => Theme.of(this).colorScheme.onPrimary;
  Color get primaryContainer => Theme.of(this).colorScheme.primaryContainer;
  Color get onPrimaryContainer => Theme.of(this).colorScheme.onPrimaryContainer;
  Color get secondary => Theme.of(this).colorScheme.secondary;
  Color get onSecondary => Theme.of(this).colorScheme.onSecondary;
  Color get secondaryContainer => Theme.of(this).colorScheme.secondaryContainer;
  Color get onSecondaryContainer =>
      Theme.of(this).colorScheme.onSecondaryContainer;
  Color get tertiary => Theme.of(this).colorScheme.tertiary;
  Color get onTertiary => Theme.of(this).colorScheme.onTertiary;
  Color get tertiaryContainer => Theme.of(this).colorScheme.tertiaryContainer;
  Color get onTertiaryContainer =>
      Theme.of(this).colorScheme.onTertiaryContainer;
  Color get error => Theme.of(this).colorScheme.error;
  Color get errorContainer => Theme.of(this).colorScheme.errorContainer;
  Color get onError => Theme.of(this).colorScheme.onError;
  Color get onErrorContainer => Theme.of(this).colorScheme.onErrorContainer;
  Color get background => Theme.of(this).colorScheme.surface;
  Color get onBackground => Theme.of(this).colorScheme.onSurface;
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get onSurface => Theme.of(this).colorScheme.onSurface;
  Color get surfaceVariant =>
      Theme.of(this).colorScheme.surfaceContainerHighest;
  Color get onSurfaceVariant => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get outline => Theme.of(this).colorScheme.outline;
  Color get onInverseSurface => Theme.of(this).colorScheme.onInverseSurface;
  Color get inverseSurface => Theme.of(this).colorScheme.inverseSurface;
  Color get inversePrimary => Theme.of(this).colorScheme.inversePrimary;
  Color get shadow => Theme.of(this).colorScheme.shadow;
  Color get surfaceTint => Theme.of(this).colorScheme.surfaceTint;
  Color get outlineVariant => Theme.of(this).colorScheme.outlineVariant;
  Color get scrim => Theme.of(this).colorScheme.scrim;

  // Additional fixed and varied surface container colors
  Color get onPrimaryFixed => Theme.of(this).brightness == Brightness.dark
      ? darkMaterialScheme.onPrimaryFixed
      : lightMaterialScheme.onPrimaryFixed;
  Color get primaryFixedDim => Theme.of(this).brightness == Brightness.dark
      ? darkMaterialScheme.primaryFixedDim
      : lightMaterialScheme.primaryFixedDim;
  Color get onPrimaryFixedVariant =>
      Theme.of(this).brightness == Brightness.dark
          ? darkMaterialScheme.onPrimaryFixedVariant
          : lightMaterialScheme.onPrimaryFixedVariant;
  Color get secondaryFixed => Theme.of(this).brightness == Brightness.dark
      ? darkMaterialScheme.secondaryFixed
      : lightMaterialScheme.secondaryFixed;
  Color get onSecondaryFixed => Theme.of(this).brightness == Brightness.dark
      ? darkMaterialScheme.onSecondaryFixed
      : lightMaterialScheme.onSecondaryFixed;
  Color get secondaryFixedDim => Theme.of(this).brightness == Brightness.dark
      ? darkMaterialScheme.secondaryFixedDim
      : lightMaterialScheme.secondaryFixedDim;
  Color get onSecondaryFixedVariant =>
      Theme.of(this).brightness == Brightness.dark
          ? darkMaterialScheme.onSecondaryFixedVariant
          : lightMaterialScheme.onSecondaryFixedVariant;
  Color get tertiaryFixed => Theme.of(this).brightness == Brightness.dark
      ? darkMaterialScheme.tertiaryFixed
      : lightMaterialScheme.tertiaryFixed;
  Color get onTertiaryFixed => Theme.of(this).brightness == Brightness.dark
      ? darkMaterialScheme.onTertiaryFixed
      : lightMaterialScheme.onTertiaryFixed;
  Color get tertiaryFixedDim => Theme.of(this).brightness == Brightness.dark
      ? darkMaterialScheme.tertiaryFixedDim
      : lightMaterialScheme.tertiaryFixedDim;
  Color get onTertiaryFixedVariant =>
      Theme.of(this).brightness == Brightness.dark
          ? darkMaterialScheme.onTertiaryFixedVariant
          : lightMaterialScheme.onTertiaryFixedVariant;
  Color get surfaceContainer => Theme.of(this).brightness == Brightness.dark
      ? darkMaterialScheme.surfaceContainer
      : lightMaterialScheme.surfaceContainer;
  Color get surfaceDim => Theme.of(this).brightness == Brightness.dark
      ? darkMaterialScheme.surfaceDim
      : lightMaterialScheme.surfaceDim;
  Color get surfaceContainerLow => Theme.of(this).brightness == Brightness.dark
      ? darkMaterialScheme.surfaceContainerLow
      : lightMaterialScheme.surfaceContainerLow;
  Color get surfaceContainerLowest =>
      Theme.of(this).brightness == Brightness.dark
          ? darkMaterialScheme.surfaceContainerLowest
          : lightMaterialScheme.surfaceContainerLowest;
  Color get surfaceContainerHigh => Theme.of(this).brightness == Brightness.dark
      ? darkMaterialScheme.surfaceContainerHigh
      : lightMaterialScheme.surfaceContainerHigh;
  Color get surfaceContainerHighest =>
      Theme.of(this).brightness == Brightness.dark
          ? darkMaterialScheme.surfaceContainerHighest
          : lightMaterialScheme.surfaceContainerHighest;
  Color get surfaceBright => Theme.of(this).brightness == Brightness.dark
      ? darkMaterialScheme.surfaceBright
      : lightMaterialScheme.surfaceBright;
}

extension AppTextThemeExtension on BuildContext {
  TextStyle? get displayLarge => Theme.of(this).textTheme.displayLarge;
  TextStyle? get displayMedium => Theme.of(this).textTheme.displayMedium;
  TextStyle? get displaySmall => Theme.of(this).textTheme.displaySmall;
  TextStyle? get headlineLarge => Theme.of(this).textTheme.headlineLarge;
  TextStyle? get headlineMedium => Theme.of(this).textTheme.headlineMedium;
  TextStyle? get headlineSmall => Theme.of(this).textTheme.headlineSmall;
  TextStyle? get titleLarge => Theme.of(this).textTheme.titleLarge;
  TextStyle? get titleMedium => Theme.of(this).textTheme.titleMedium;
  TextStyle? get titleSmall => Theme.of(this).textTheme.titleSmall;
  TextStyle? get bodyLarge => Theme.of(this).textTheme.bodyLarge;
  TextStyle? get bodyMedium => Theme.of(this).textTheme.bodyMedium;
  TextStyle? get bodySmall => Theme.of(this).textTheme.bodySmall;
  TextStyle? get labelLarge => Theme.of(this).textTheme.labelLarge;
  TextStyle? get labelMedium => Theme.of(this).textTheme.labelMedium;
  TextStyle? get labelSmall => Theme.of(this).textTheme.labelSmall;
}
