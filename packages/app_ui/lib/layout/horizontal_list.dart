import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';
import '../typography/app_text_styles.dart';

/// A widget that displays a horizontal list of items.
class HorizontalList extends StatelessWidget {
  /// Creates a widget that displays a horizontal list of items.
  const HorizontalList({
    required this.items,
    this.gap,
    this.padding = EdgeInsets.zero,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.backgroundColor,
    super.key,
  });

  /// The widgets to display.
  final List<Widget> items;

  /// The gap between each item.
  final double? gap;

  /// The amount of space by which to inset the items.
  final EdgeInsetsGeometry padding;

  /// How the children should be placed along the cross axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// background color
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      color: backgroundColor,
      child: Builder(
        builder: (context) {
          if (items.isEmpty) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            primary: true,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            child: Row(
                crossAxisAlignment: crossAxisAlignment,
                children: List.generate((items.length * 2) - 1, (index) {
                  if (index.isEven) {
                    return items[index ~/ 2];
                  } else {
                    return SizedBox(width: gap);
                  }
                })),
          );
        },
      ),
    );
  }
}

/// A widget that displays a horizontal list of items.
class DynamicHorizonList extends StatelessWidget {
  /// Creates a widget that displays a horizontal list of items.
  const DynamicHorizonList({
    required this.items,
    this.progress = false,
    this.defaultHeight = 160,
    this.emptyString,
    super.key,
  });

  final bool progress;

  final String? emptyString;

  final double defaultHeight;

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (_) {
        if (progress) {
          return SizedBox(
            width: double.infinity,
            height: defaultHeight,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (!progress && items.isEmpty) {
          return Container(
            width: double.infinity,
            height: defaultHeight,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                emptyString ?? '',
                style: TextStyles.bodySmall.apply(
                  color: context.onSurfaceVariant,
                ),
              ),
            ),
          );
        } else {
          return HorizontalList(
            backgroundColor: Colors.transparent,
            gap: 8,
            items: items,
          );
        }
      },
    );
  }
}
