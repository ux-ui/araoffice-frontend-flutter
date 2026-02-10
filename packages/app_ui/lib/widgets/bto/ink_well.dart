import 'package:flutter/material.dart';

import '../../theme/theme_extension.dart';
import 'animation_button_effect.dart';

class InkWellContainer extends StatelessWidget {
  final Widget child;
  final void Function()? onTap;
  final double? width;
  final double? height;
  final double? radius;
  const InkWellContainer({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.onTap,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          BaseAnimationButton(
            onTap: onTap,
            hoverColor: context.primary.withAlpha(13),
            focusColor: context.primary.withAlpha(21),
            splashColor: context.primary.withAlpha(21),
            highlightColor: context.primary.withAlpha(13),
            radius: radius,
          ),
        ],
      ),
    );
  }
}
