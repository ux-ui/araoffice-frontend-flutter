import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';

import '../../app_ui.dart';

class VulcanXTwoSvgIconOutlinedButton extends StatelessWidget {
  final double? width;
  final double? height;
  final double? borderRadius;
  final String text;
  final SvgGenImage? prefixIcon;
  final SvgGenImage? suffixIcon;
  final VoidCallback onPressed;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderSideColor;
  final Color? iconColor;
  final double? iconWidth;
  final double? iconHeight;
  final bool? isColorFilter;

  const VulcanXTwoSvgIconOutlinedButton({
    super.key,
    required this.text,
    this.prefixIcon,
    this.suffixIcon,
    required this.onPressed,
    this.foregroundColor,
    this.backgroundColor = Colors.transparent,
    this.iconColor,
    this.iconWidth = 16.0,
    this.iconHeight = 16.0,
    this.borderSideColor,
    this.width,
    this.height,
    this.borderRadius,
    this.isColorFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderSideColor ?? context.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefixIcon != null) ...[
              prefixIcon!.svg(
                width: iconWidth,
                height: iconHeight,
                colorFilter: isColorFilter ?? false
                    ? ColorFilter.mode(
                        iconColor ?? Colors.transparent, BlendMode.srcIn)
                    : null,
              ),
              const SizedBox(width: 8),
            ],
            Text(text,
                style: context.bodyMedium?.copyWith(color: foregroundColor)),
            if (suffixIcon != null) ...[
              const Spacer(),
              const SizedBox(width: 8),
              suffixIcon!.svg(
                width: iconWidth,
                height: iconHeight,
                colorFilter: isColorFilter ?? false
                    ? ColorFilter.mode(
                        iconColor ?? Colors.transparent, BlendMode.srcIn)
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
