import 'package:flutter/material.dart';

import 'animation_button_effect.dart';

class BtoIconButton extends StatelessWidget {
  const BtoIconButton(
      {required this.icon,
      required this.size,
      this.onTap,
      this.color,
      this.disabled,
      this.isBorder,
      this.hoverColor,
      this.focusColor,
      this.splashColor,
      this.highlightColor,
      super.key});

  final Widget icon;
  final Color? color;
  final double size;
  final void Function()? onTap;
  final bool? disabled;
  final bool? isBorder;
  final Color? hoverColor;
  final Color? focusColor;
  final Color? splashColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: disabled ?? false ? Colors.grey : null,
          border: isBorder ?? false
              ? Border.all(color: color ?? Colors.transparent)
              : null),
      height: size * 1.5,
      width: size * 1.5,
      child: Stack(
        children: [
          Center(child: icon),
          ClipOval(
              child: BaseAnimationButton(
            disabled: disabled ?? false,
            onTap: onTap,
          ))
        ],
      ),
    );
  }
}
