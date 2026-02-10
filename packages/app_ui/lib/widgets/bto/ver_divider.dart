import 'package:flutter/widgets.dart';

import '../../app_ui.dart';

class VerDivider extends StatelessWidget {
  final double width;
  final Color? color;
  final EdgeInsets? padding;

  const VerDivider({
    super.key,
    this.width = 1,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding,
      height: double.maxFinite,
      width: width,
      color: color ?? context.outline,
    );
  }
}
