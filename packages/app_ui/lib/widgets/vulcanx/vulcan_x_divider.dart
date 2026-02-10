import 'package:flutter/material.dart';

import 'vulcan_x_stateless_widget.dart';

class VulcanXDivider extends VulcanXStatelessWidget {
  final double? space;
  const VulcanXDivider({
    super.key,
    this.space,
  });

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: space ?? 0),
      child: const Divider(),
    );
  }
}
