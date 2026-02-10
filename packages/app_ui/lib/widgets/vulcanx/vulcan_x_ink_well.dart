import 'package:flutter/material.dart';

import 'vulcan_x_stateless_widget.dart';

class VulcanXInkWell extends VulcanXStatelessWidget {
  final Widget? child;
  final GestureTapCallback? onTap;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final bool isSelected; // Added selection property
  final Color? selectedBorderColor; // Optional selected border color

  const VulcanXInkWell({
    super.key,
    this.child,
    this.onTap,
    this.borderRadius,
    this.isCircle = false,
    this.isSelected = false, // Default to false
    this.selectedBorderColor, // Optional color
  });

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    return Container(
      decoration: BoxDecoration(
        border: isSelected
            ? Border.all(
                color: selectedBorderColor ?? themeData.primaryColor,
                width: 2,
              )
            : null,
        borderRadius:
            !isCircle ? (borderRadius ?? BorderRadius.circular(8)) : null,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Stack(
        children: [
          child ?? const SizedBox.shrink(),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              shape: isCircle
                  ? const CircleBorder()
                  : RoundedRectangleBorder(
                      borderRadius: borderRadius ?? BorderRadius.circular(8),
                    ),
              child: InkWell(
                onTap: onTap,
                borderRadius: !isCircle ? borderRadius : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
