import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';

import '../vulcanx/vulcan_x_rounded_container.dart';

class VulcanXSvgLabelIconButton extends StatelessWidget {
  final SvgGenImage icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color? selectedColor;
  final Color unselectedColor;

  const VulcanXSvgLabelIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
    this.selectedColor,
    this.unselectedColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    Color currentColor = isSelected
        ? (selectedColor ?? Theme.of(context).colorScheme.primary)
        : unselectedColor;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: VulcanXRoundedContainer(
        isBoxShadow: false,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon.svg(
                width: 24.0,
                height: 24.0,
                colorFilter: ColorFilter.mode(
                  currentColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                label,
                semanticsLabel: label,
                style: TextStyle(
                  color: currentColor,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
