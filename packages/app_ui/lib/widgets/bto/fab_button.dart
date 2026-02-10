import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app_ui.dart';
import 'animation_button_effect.dart';

class FabButton extends StatelessWidget {
  const FabButton({
    super.key,
    this.color,
    this.onTap,
    this.elevation,
    required this.size,
    required this.icon,
  });

  final SvgPicture? icon;
  final Color? color;
  final double size;
  final double? elevation;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation ?? 3.0,
      shape: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        height: size * 1.6,
        width: size * 1.6,
        child: Stack(
          children: [
            Center(child: icon),
            ClipOval(
                child: BaseAnimationButton(
              onTap: onTap,
            ))
          ],
        ),
      ),
    );
  }
}
