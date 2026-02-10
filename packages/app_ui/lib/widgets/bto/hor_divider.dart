import 'package:flutter/widgets.dart';

import '../../app_ui.dart';

class HorDivider extends StatelessWidget {
  final double height;
  final Color? color;

  const HorDivider({
    super.key,
    this.height = 1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.maxFinite,
      color: color ?? context.outline,
    );
  }
}
