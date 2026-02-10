import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';

import 'vulcan_x_stateful_widget.dart';

class VulcanXSvgIconSelector extends VulcanXStatefulWidget {
  final List<SvgGenImage> svgIcons;
  final Function(int) onSelected;
  final int initialSelectedIndex;
  final double iconSize;

  const VulcanXSvgIconSelector({
    super.key,
    required this.svgIcons,
    required this.onSelected,
    this.initialSelectedIndex = 0,
    this.iconSize = 24.0,
  });

  @override
  VulcanXState<VulcanXSvgIconSelector> createState() =>
      _VulcanXSvgIconSelectorState();
}

class _VulcanXSvgIconSelectorState
    extends VulcanXState<VulcanXSvgIconSelector> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  void _onIconPressed(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onSelected(index);
  }

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.svgIcons.length,
        (index) => IconButton(
          icon: widget.svgIcons[index].svg(
            colorFilter: ColorFilter.mode(
              _selectedIndex == index
                  ? themeData.colorScheme.primary
                  : themeData.colorScheme.onSurface.withAlpha(128),
              BlendMode.srcIn,
            ),
            width: widget.iconSize,
            height: widget.iconSize,
          ),
          constraints: const BoxConstraints(),
          onPressed: () => _onIconPressed(index),
        ),
      ),
    );
  }
}
