import 'package:flutter/material.dart';

import '../../theme/theme_extension.dart';
import '../../typography/app_text_styles.dart';

/// A badge that displays a text.
class TextBadge extends StatelessWidget {
  /// Creates a [TextBadge].
  const TextBadge({
    required this.label,
    this.color,
    this.textStyle = TextStyles.labelLarge,
    this.padding,
    super.key,
  });

  final Color? color;
  final TextStyle textStyle;
  final EdgeInsetsGeometry? padding;

  /// The text to display.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? context.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(label, style: textStyle),
    );
  }
}
