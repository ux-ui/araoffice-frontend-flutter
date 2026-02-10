import 'package:flutter/material.dart';

import '../../app_ui.dart';
import 'vulcan_x_stateless_widget.dart';

class VulcanXLabelMoreMenu extends VulcanXStatelessWidget {
  final String label;
  final List<PopupMenuItem<dynamic>> items;
  final Widget? trailing;
  const VulcanXLabelMoreMenu({
    super.key,
    required this.label,
    required this.items,
    this.trailing,
  });

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    return Row(
      children: [
        Expanded(
            child: Text(
          label,
          style: context.bodyLarge,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        )),
        trailing ?? const SizedBox.shrink(),
        VulcanXMoreMenu(items: items),
      ],
    );
  }
}
