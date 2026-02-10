import 'package:flutter/material.dart';

import 'vulcan_x_stateless_widget.dart';

class VulcanXOutlinedButton extends VulcanXStatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final IconAlignment? iconAlignment;
  final bool disabled;

  const VulcanXOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 36,
    this.padding,
    this.iconAlignment = IconAlignment.start,
    this.disabled = false,
  }) : icon = null;

  const VulcanXOutlinedButton.icon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.child,
    this.width,
    this.height = 36,
    this.padding,
    this.iconAlignment = IconAlignment.start,
    this.disabled = false,
  });

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    final buttonStyle = themeData.outlinedButtonTheme.style?.copyWith(
          minimumSize: WidgetStateProperty.all(
              Size(width ?? 0, height)), // width를 0으로 설정
          padding: WidgetStateProperty.all(
              padding ?? const EdgeInsets.symmetric(horizontal: 8.0)),
        ) ??
        ButtonStyle(
          minimumSize: WidgetStateProperty.all(
              Size(width ?? 0, height)), // width를 0으로 설정
          padding: WidgetStateProperty.all(
              padding ?? const EdgeInsets.symmetric(horizontal: 8.0)),
        );

    final buttonChild = icon == null
        ? child
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconAlignment == IconAlignment.start) icon!,
              child,
              if (iconAlignment == IconAlignment.end) ...[
                const Spacer(),
                icon!
              ],
            ],
          );

    return IntrinsicWidth(
      stepWidth: width,
      child: SizedBox(
        height: height,
        child: OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        ),
      ),
    );
  }
}
