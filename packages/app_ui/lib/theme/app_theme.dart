// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../app_ui.dart';
import '../src/generated/fonts.gen.dart';

/// {@template app_theme}
/// The Default App [ThemeData].
/// {@endtemplate}
class AppTheme {
  final double fontFactor;

  /// {@macro app_theme}
  const AppTheme({
    this.fontFactor = 1.0,
  });

  /// Default `ThemeData` for App UI.
  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _colorScheme,
      fontFamily: FontFamily.pretendard,
      appBarTheme: _appBarTheme,
      primaryColor: _colorScheme.primary,
      canvasColor: _colorScheme.background,
      scaffoldBackgroundColor: _colorScheme.background,
      textTheme: _textTheme.apply(
        fontSizeFactor: fontFactor,
      ),
      buttonTheme: _buttonTheme,
      splashColor: Colors.transparent,
      dialogTheme: _dialogTheme,
      chipTheme: _chipTheme,
      switchTheme: _switchTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      tooltipTheme: _tooltipTheme,
    );
  }

  TooltipThemeData get _tooltipTheme {
    return TooltipThemeData(
      textStyle: _textTheme.labelLarge?.apply(
        color: _colorScheme.onPrimary,
      ),
      decoration: BoxDecoration(
        color: _colorScheme.onSurface,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return BottomNavigationBarThemeData(
      elevation: 1,
      backgroundColor: _colorScheme.background,
      selectedItemColor: _colorScheme.primary,
      unselectedItemColor: _colorScheme.onSurface,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: _textTheme.titleSmall?.apply(
        color: _colorScheme.primary,
      ),
      unselectedLabelStyle: _textTheme.titleSmall?.apply(
        color: _colorScheme.onSurface,
      ),
    );
  }

  ButtonThemeData get _buttonTheme {
    return const ButtonThemeData();
  }

  ChipThemeData get _chipTheme {
    return const ChipThemeData();
  }

  DialogThemeData get _dialogTheme {
    return const DialogThemeData();
  }

  SwitchThemeData get _switchTheme {
    return const SwitchThemeData();
  }

  ColorScheme get _colorScheme {
    return lightMaterialScheme.toColorScheme();
  }

  FloatingActionButtonThemeData get _floatingActionButtonTheme {
    return const FloatingActionButtonThemeData();
  }

  AppBarTheme get _appBarTheme {
    return const AppBarTheme();
  }

  TextTheme get _textTheme => uiTextTheme;

  /// The UI text theme based on [UITextStyle].
  static const TextTheme uiTextTheme = TextTheme(
    displayLarge: TextStyles.displayLarge,
    displayMedium: TextStyles.displayMedium,
    displaySmall: TextStyles.displaySmall,
    headlineMedium: TextStyles.headlineMedium,
    headlineSmall: TextStyles.headlineSmall,
    titleLarge: TextStyles.titleLarge,
    titleMedium: TextStyles.titleMedium,
    titleSmall: TextStyles.titleSmall,
    bodyLarge: TextStyles.bodyLarge,
    bodyMedium: TextStyles.bodyMedium,
    labelLarge: TextStyles.labelLarge,
    bodySmall: TextStyles.bodySmall,
    labelSmall: TextStyles.labelSmall,
  );
}

/// {@template app_dark_theme}
/// Dark Mode App [ThemeData].
/// {@endtemplate}
class AppDarkTheme extends AppTheme {
  /// {@macro app_dark_theme}
  const AppDarkTheme({super.fontFactor = 1.0});

  @override
  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorScheme,
      fontFamily: FontFamily.pretendard,
      appBarTheme: _appBarTheme,
      primaryColor: _colorScheme.primary,
      canvasColor: _colorScheme.background,
      scaffoldBackgroundColor: _colorScheme.background,
      textTheme: _textTheme,
      buttonTheme: _buttonTheme,
      splashColor: Colors.transparent,
      dialogTheme: _dialogTheme,
      chipTheme: _chipTheme,
      switchTheme: _switchTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      tooltipTheme: _tooltipTheme,
    );
  }

  @override
  ColorScheme get _colorScheme {
    return darkMaterialScheme.toColorScheme();
  }
}
