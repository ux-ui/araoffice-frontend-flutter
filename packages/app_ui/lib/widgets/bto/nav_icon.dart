import 'package:flutter/material.dart';

import '../../app_ui.dart';
import 'animation_button_effect.dart';

class NavIcon extends StatefulWidget {
  final Widget icon;
  // final SvgGenImage icon;
  final Color? color;
  final double size;
  final void Function()? onTap;
  final bool? disalbed;

  const NavIcon(
      {required this.icon,
      required this.size,
      // required this.image,
      this.onTap,
      this.color,
      this.disalbed,
      super.key});

  // factory NavIcon.svg({
  //   required double size,
  //   required void Function() onTap,
  //   required SvgGenImage image,
  // }) {
  //   return NavIcon(
  //     icon: image.svg(width: size, height: size),
  //     size: size,
  //     onTap: onTap,
  //   );
  // }

  @override
  State<NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<NavIcon> {
  Color selectedColor = Colors.transparent;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.disalbed ?? false ? Colors.grey : null,
      ),
      height: widget.size * 1.2,
      width: widget.size * 1.2,
      child: Stack(
        children: [
          Center(child: widget.icon
              // .svg(
              //     width: widget.size,
              //     height: widget.size,
              //     color: selectedColor)
              ),
          ClipOval(
              child: BaseAnimationButton(
            disabled: widget.disalbed ?? false,
            onTap: widget.onTap,
          ))
        ],
      ),
    );
  }
}
