// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../app_ui.dart';
import '../../src/generated/fonts.gen.dart';

/// {@template vulcanx_theme}
/// The VulcanX App [ThemeData] provider.
/// {@endtemplate}
class VulcanXTheme {
  final double fontFactor;

  /// {@macro vulcanx_theme}
  const VulcanXTheme({
    this.fontFactor = 1.0,
  });

  /// Light theme data for the app
  ThemeData get lightThemeData {
    return _buildThemeData(
      brightness: Brightness.light,
      colorScheme: lightMaterialScheme.toColorScheme(),
    );
  }

  /// Dark theme data for the app
  ThemeData get darkThemeData {
    return _buildThemeData(
      brightness: Brightness.dark,
      colorScheme: darkMaterialScheme.toColorScheme(),
    );
  }

  ThemeData _buildThemeData({
    required Brightness brightness,
    required ColorScheme colorScheme,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: FontFamily.pretendard,
      appBarTheme: _appBarTheme,
      primaryColor: colorScheme.primary,
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      outlinedButtonTheme: _outlinedButtonTheme,
      textTheme: _textTheme.apply(fontSizeFactor: fontFactor).apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ),
      buttonTheme: _buttonTheme,
      splashColor: Colors.transparent,
      dialogTheme: _dialogTheme,
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      filledButtonTheme: _filledButtonTheme,
      chipTheme: _chipTheme,
      switchTheme: _switchTheme(colorScheme),
      floatingActionButtonTheme: _floatingActionButtonTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme(colorScheme),
      tooltipTheme: _tooltipTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      dividerTheme: _dividerTheme(colorScheme),
      popupMenuTheme: _popupMenuTheme,
    );
  }

  PopupMenuThemeData get _popupMenuTheme {
    return const PopupMenuThemeData(
      color: Colors.white, // 팝업메뉴 배경색을 흰색으로 설정
      elevation: 4, // 그림자 깊이
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );
  }

  DividerThemeData _dividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outline,
      thickness: 0,
      indent: 0,
      endIndent: 0,
      space: 0,
    );
  }

  TooltipThemeData _tooltipTheme(ColorScheme colorScheme) {
    return TooltipThemeData(
      textStyle: _textTheme.labelLarge?.apply(
        color: colorScheme.onPrimary,
      ),
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  BottomNavigationBarThemeData _bottomNavigationBarTheme(
      ColorScheme colorScheme) {
    return BottomNavigationBarThemeData(
      elevation: 1,
      backgroundColor: colorScheme.background,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: _textTheme.titleSmall?.apply(
        color: colorScheme.primary,
      ),
      unselectedLabelStyle: _textTheme.titleSmall?.apply(
        color: colorScheme.onSurface,
      ),
    );
  }

  InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.outline, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.outline, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.error, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.error, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  ButtonThemeData get _buttonTheme {
    return const ButtonThemeData();
  }

  DialogThemeData get _dialogTheme {
    return const DialogThemeData();
  }

  SwitchThemeData _switchTheme(ColorScheme colorScheme) {
    return SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return colorScheme.primary; // 켜진 상태의 동그라미 색상
        }
        return Colors.white; // 꺼진 상태의 동그라미 색상
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return colorScheme.primary.withValues(alpha: 0.2); // 켜진 상태의 트랙 색상
        }
        return Colors.grey.withValues(alpha: 0.3); // 꺼진 상태의 트랙 색상
      }),
      trackOutlineColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.transparent; // 켜진 상태의 테두리 색상
        }
        return Colors.grey.withValues(alpha: 0.5); // 꺼진 상태의 테두리 색상
      }),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 전체 터치 영역 크기 축소
      splashRadius: 20.0, // 터치 효과(리플) 반경 크기
    );
  }

  ChipThemeData get _chipTheme {
    return const ChipThemeData(
      backgroundColor: Colors.black, // 배경색 제거
      shape: StadiumBorder(
        side: BorderSide(width: 0, color: Colors.transparent), // 테두리 제거
      ),
      labelStyle: TextStyle(
        color: Colors.white, // 텍스트 색상
        fontSize: 14, // 텍스트 크기 (필요에 따라 조정)
        fontWeight: FontWeight.normal, // 글꼴 두께 (필요에 따라 조정)
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 내부 패딩
    );
  }

  FloatingActionButtonThemeData get _floatingActionButtonTheme {
    return const FloatingActionButtonThemeData();
  }

  ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        shadowColor: Colors.transparent,
        textStyle: _textTheme.bodyMedium?.apply(color: colorScheme.primary),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return colorScheme.onPrimary.withValues(alpha: 0.12);
          }
          if (states.contains(MaterialState.hovered)) {
            return colorScheme.onPrimary.withValues(alpha: 0.08);
          }
          if (states.contains(MaterialState.focused)) {
            return colorScheme.onPrimary.withValues(alpha: 0.12);
          }
          return Colors.transparent;
        }),
      ),
    );
  }

  OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  FilledButtonThemeData get _filledButtonTheme {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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
