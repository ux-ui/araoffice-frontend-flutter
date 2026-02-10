import 'package:flutter/material.dart';

import 'vulcan_x_theme.dart';

abstract class VulcanXStatelessWidget extends StatelessWidget {
  final VulcanXTheme vulcanXTheme = const VulcanXTheme();

  const VulcanXStatelessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final themeData = brightness == Brightness.dark
        ? vulcanXTheme.darkThemeData
        : vulcanXTheme.lightThemeData;

    return Theme(
      data: themeData,
      child: buildWithTheme(context, themeData),
    );
  }

  Widget buildWithTheme(BuildContext context, ThemeData themeData);
}
