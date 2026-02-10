import 'package:flutter/material.dart';

import 'vulcan_x_theme.dart';

abstract class VulcanXStatefulWidget extends StatefulWidget {
  const VulcanXStatefulWidget({super.key});

  @override
  VulcanXState createState();
}

abstract class VulcanXState<T extends VulcanXStatefulWidget> extends State<T> {
  final VulcanXTheme vulcanXTheme = const VulcanXTheme();

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
