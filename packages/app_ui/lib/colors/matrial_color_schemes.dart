import 'package:flutter/material.dart';

const lightMaterialScheme = MaterialScheme(
  brightness: Brightness.light,
  primary: Color(0xff00A5AE),
  surfaceTint: Color(0xff00A5AE),
  onPrimary: Color(0xffffffff),
  primaryContainer: Color(0xffCBEFEF),
  onPrimaryContainer: Color(0xff00132F),
  secondary: Color(0xff000000),
  onSecondary: Color(0xffffffff),
  secondaryContainer: Color(0xffE9E9E9),
  onSecondaryContainer: Color(0xff262626),
  tertiary: Color(0xffF19800),
  onTertiary: Color(0xffffffff),
  tertiaryContainer: Color(0xffFFDDB9),
  onTertiaryContainer: Color(0xff2B1700),
  error: Color(0xffEF4444),
  onError: Color(0xffffffff),
  errorContainer: Color(0xffFFDADA),
  onErrorContainer: Color(0xff410002),
  background: Color(0xffffffff),
  onBackground: Color(0xff242424),
  surface: Color(0xffffffff),
  onSurface: Color(0xff242424),
  surfaceVariant: Color(0xffF4F4F4),
  onSurfaceVariant: Color(0xff4D4D4D),
  outline: Color(0xffE1E1E1),
  outlineVariant: Color(0xff797979),
  shadow: Color(0xff000000),
  scrim: Color(0xff000000),
  inverseSurface: Color(0xff323135),
  inverseOnSurface: Color(0xffEFEFEF),
  inversePrimary: Color(0xff80D4DB),
  primaryFixed: Color(0xff9CF0F7),
  onPrimaryFixed: Color(0xff002022),
  primaryFixedDim: Color(0xff80D4DB),
  onPrimaryFixedVariant: Color(0xff004F54),
  secondaryFixed: Color(0xffE2E2E2),
  onSecondaryFixed: Color(0xff3A3A3A),
  secondaryFixedDim: Color(0xffD0D0D0),
  onSecondaryFixedVariant: Color(0xff787878),
  tertiaryFixed: Color(0xffF9BB72),
  onTertiaryFixed: Color(0xff31111D),
  tertiaryFixedDim: Color(0xffF9BB72),
  onTertiaryFixedVariant: Color(0xff663E00),
  surfaceDim: Color(0xffAEAEAE),
  surfaceBright: Color(0xffFAFAFA),
  surfaceContainerLowest: Color(0xffF9F9F9),
  surfaceContainerLow: Color(0xffF4F4F4),
  surfaceContainer: Color(0xffEFEFEF),
  surfaceContainerHigh: Color(0xffE4E4E4),
  surfaceContainerHighest: Color(0xffE9E9E9),
);

const darkMaterialScheme = MaterialScheme(
  brightness: Brightness.dark,
  primary: Color(0xff00A5AE),
  surfaceTint: Color(0xff00A5AE),
  onPrimary: Color(0xffffffff),
  primaryContainer: Color(0xffCBEFEF),
  onPrimaryContainer: Color(0xff00132F),
  secondary: Color(0xff000000),
  onSecondary: Color(0xffffffff),
  secondaryContainer: Color(0xffE9E9E9),
  onSecondaryContainer: Color(0xff262626),
  tertiary: Color(0xffF19800),
  onTertiary: Color(0xffffffff),
  tertiaryContainer: Color(0xffFFDDB9),
  onTertiaryContainer: Color(0xff2B1700),
  error: Color(0xffEF4444),
  onError: Color(0xffffffff),
  errorContainer: Color(0xffFFDADA),
  onErrorContainer: Color(0xff410002),
  background: Color(0xffffffff),
  onBackground: Color(0xff242424),
  surface: Color(0xffffffff),
  onSurface: Color.fromARGB(255, 10, 6, 6),
  surfaceVariant: Color(0xffE1E1E1),
  onSurfaceVariant: Color(0xff4D4D4D),
  outline: Color(0xffE1E1E1),
  outlineVariant: Color(0xff797979),
  shadow: Color(0xff000000),
  scrim: Color(0xff000000),
  inverseSurface: Color(0xff323135),
  inverseOnSurface: Color(0xffEFEFEF),
  inversePrimary: Color(0xff80D4DB),
  primaryFixed: Color(0xff9CF0F7),
  onPrimaryFixed: Color(0xff002022),
  primaryFixedDim: Color(0xff80D4DB),
  onPrimaryFixedVariant: Color(0xff004F54),
  secondaryFixed: Color(0xffE2E2E2),
  onSecondaryFixed: Color(0xff3A3A3A),
  secondaryFixedDim: Color(0xffD0D0D0),
  onSecondaryFixedVariant: Color(0xff787878),
  tertiaryFixed: Color(0xffF9BB72),
  onTertiaryFixed: Color(0xff31111D),
  tertiaryFixedDim: Color(0xffF9BB72),
  onTertiaryFixedVariant: Color(0xff663E00),
  surfaceDim: Color(0xffAEAEAE),
  surfaceBright: Color(0xffFAFAFA),
  surfaceContainerLowest: Color(0xffF9F9F9),
  surfaceContainerLow: Color(0xffF4F4F4),
  surfaceContainer: Color(0xffEFEFEF),
  surfaceContainerHigh: Color(0xffE4E4E4),
  surfaceContainerHighest: Color(0xffE9E9E9),
);

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return lightMaterialScheme;
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return darkMaterialScheme;
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary,
    required this.surfaceTint,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixedVariant,
    required this.secondaryFixed,
    required this.onSecondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.onTertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixedVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHigh: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}
