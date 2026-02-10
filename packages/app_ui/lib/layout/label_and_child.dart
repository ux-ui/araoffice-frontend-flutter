import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';
import '../typography/app_text_styles.dart';

class LabelAndChild extends StatelessWidget {
  /// {@macro label_and_child}
  const LabelAndChild({
    required this.label,
    required this.child,
    this.tooltip,
    this.padding,
    this.background,
    this.indent,
    this.actions,
    this.isRequired = false,
    super.key,
  });

  /// child
  final Widget child;

  /// label
  final String label;

  /// tooltip callback
  final InlineSpan? tooltip;

  /// wrapper padding
  final EdgeInsetsGeometry? padding;

  /// background color
  final Color? background;

  /// title indent
  final double? indent;

  /// actions
  final List<Widget>? actions;

  /// isRequired
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: indent ?? 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyles.titleMedium.apply(
                            color: context.onSurface,
                          ),
                        ),
                      ),
                      if (isRequired)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            '*',
                            style: TextStyles.bodyMedium.apply(
                              color: context.error,
                            ),
                          ),
                        ),
                      /*if (tooltip != null)
                        Tooltip(
                          richMessage: tooltip,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          showDuration: const Duration(seconds: 10),
                          triggerMode: TooltipTriggerMode.tap,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Assets.icons.question.svg(
                              width: 20,
                            ),
                          ),
                        )
                      else*/
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: child,
          )
        ],
      ),
    );
  }
}
