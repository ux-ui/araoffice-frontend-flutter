import 'package:flutter/material.dart';

import 'vulcan_x_ink_well.dart';

class VulcanXInkWellSelector extends StatefulWidget {
  final List<Widget> children;
  final List<VoidCallback> onTaps;
  final int? initialSelectedIndex;
  final Color? selectedBorderColor;
  final Axis direction;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final int? maxItems; // Optional: limit items per row/column

  const VulcanXInkWellSelector({
    super.key,
    required this.children,
    required this.onTaps,
    this.initialSelectedIndex,
    this.selectedBorderColor,
    this.direction = Axis.horizontal,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.alignment = WrapAlignment.start,
    this.maxItems,
  }) : assert(children.length == onTaps.length);

  @override
  State<VulcanXInkWellSelector> createState() => _VulcanXInkWellSelectorState();
}

class _VulcanXInkWellSelectorState extends State<VulcanXInkWellSelector> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialSelectedIndex;
  }

  @override
  void didUpdateWidget(VulcanXInkWellSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedIndex != oldWidget.initialSelectedIndex) {
      selectedIndex = widget.initialSelectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.direction == Axis.horizontal) {
      return Wrap(
        spacing: widget.spacing,
        runSpacing: widget.runSpacing,
        alignment: widget.alignment,
        children: _buildChildren(),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: _buildChildren(),
        ),
      );
    }
  }

  List<Widget> _buildChildren() {
    return List.generate(
      widget.children.length,
      (index) => VulcanXInkWell(
        isSelected: (widget.selectedBorderColor == null)
            ? false
            : selectedIndex == index,
        selectedBorderColor: widget.selectedBorderColor,
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
          widget.onTaps[index].call();
        },
        child: widget.children[index],
      ),
    );
  }
}
