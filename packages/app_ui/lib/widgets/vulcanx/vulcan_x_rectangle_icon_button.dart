import 'package:flutter/material.dart';

class VulcanXRectangleIconButton extends StatelessWidget {
  final double? width;
  final double? height;
  final String tooltip;
  final VoidCallback onPressed;
  final Widget icon;
  final bool isOutlined;
  final Color? fillColor;

  const VulcanXRectangleIconButton._({
    super.key,
    this.width,
    this.height,
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    required this.isOutlined,
    this.fillColor,
  });

  factory VulcanXRectangleIconButton.outlined({
    Key? key,
    double? width,
    double? height,
    required String tooltip,
    required VoidCallback onPressed,
    required Widget icon,
  }) {
    return VulcanXRectangleIconButton._(
      key: key,
      width: width,
      height: height,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: icon,
      isOutlined: true,
    );
  }

  factory VulcanXRectangleIconButton.filled({
    Key? key,
    double? width,
    double? height,
    required String tooltip,
    required VoidCallback onPressed,
    required Widget icon,
    Color? fillColor,
  }) {
    return VulcanXRectangleIconButton._(
      key: key,
      width: width,
      height: height,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: icon,
      isOutlined: false,
      fillColor: fillColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: isOutlined
          ? IconButton.outlined(
              tooltip: tooltip,
              icon: icon,
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: onPressed,
            )
          : IconButton.filled(
              tooltip: tooltip,
              icon: icon,
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
                backgroundColor: fillColor ?? Colors.grey[200],
              ),
              onPressed: onPressed,
            ),
    );
  }
}
