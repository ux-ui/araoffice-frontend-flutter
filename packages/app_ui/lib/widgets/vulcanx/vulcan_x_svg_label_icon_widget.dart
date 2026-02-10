import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';

class VulcanXSvgLabelIconWidget extends StatelessWidget {
  final SvgGenImage icon;
  final double? width;
  final double? height;
  final String label;
  final TextStyle? labelStyle;
  final Axis direction;

  const VulcanXSvgLabelIconWidget({
    super.key,
    required this.icon,
    this.width,
    this.height,
    required this.label,
    this.labelStyle,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: direction == Axis.vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon.svg(width: width, height: height),
                const SizedBox(height: 4),
                Text(
                  label,
                  semanticsLabel: label,
                  style: labelStyle ?? const TextStyle(fontSize: 10.5),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon.svg(width: width, height: height),
                const SizedBox(width: 4),
                Text(
                  label,
                  semanticsLabel: label,
                  style: labelStyle ?? const TextStyle(fontSize: 10.5),
                ),
              ],
            ),
    );
  }
}

class VulcanXImageLabelIconWidget extends StatelessWidget {
  final AssetGenImage icon;
  final double? width;
  final double? height;
  final String label;
  final TextStyle? labelStyle;
  final Axis direction;

  const VulcanXImageLabelIconWidget({
    super.key,
    required this.icon,
    this.width,
    this.height,
    required this.label,
    this.labelStyle,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: direction == Axis.vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon.image(width: width, height: height),
                const SizedBox(height: 4),
                Text(
                  label,
                  semanticsLabel: label,
                  style: labelStyle ?? const TextStyle(fontSize: 10.5),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon.image(width: width, height: height),
                const SizedBox(width: 4),
                Text(
                  label,
                  semanticsLabel: label,
                  style: labelStyle ?? const TextStyle(fontSize: 10.5),
                ),
              ],
            ),
    );
  }
}
