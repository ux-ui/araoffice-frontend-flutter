import 'package:flutter/material.dart';

class WrapList extends StatelessWidget {
  /// {@macro wrap_list}
  const WrapList({
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.countInRow = 2,
    this.spacing = 8,
    this.runSpacing = 8,
    super.key,
  }) : assert(countInRow > 0, 'countInRow must be greater than 0');

  /// items
  final List<Widget> items;

  /// wrap padding
  final EdgeInsetsGeometry padding;

  /// count in row
  final int countInRow;

  /// spacing
  final double spacing;

  /// vertical spacing
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final itemWidth =
              (constraints.maxWidth - spacing * (countInRow - 1)) / countInRow;

          return Wrap(
            runSpacing: runSpacing,
            spacing: spacing,
            children: List.generate(
              items.length,
              (index) {
                return SizedBox(
                  width: itemWidth.truncateToDouble(),
                  child: items[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
