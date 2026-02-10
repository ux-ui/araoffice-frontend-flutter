import 'package:flutter/material.dart';

import '../../app_ui.dart';
import 'vulcan_x_stateful_widget.dart';
import 'vulcan_x_stateless_widget.dart';

class VulcanXButtonSelector extends VulcanXStatefulWidget {
  final List<String> options;
  final Function(int) onSelected;

  const VulcanXButtonSelector({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  VulcanXState<VulcanXButtonSelector> createState() => _ButtonSelectorState();
}

class _ButtonSelectorState extends VulcanXState<VulcanXButtonSelector> {
  int _selectedIndex = 0;

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.options.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 5,
              right: index == widget.options.length - 1 ? 0 : 5,
            ),
            child: VulcanXSelectableButton(
              text: widget.options[index],
              isSelected: _selectedIndex == index,
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onSelected(index);
              },
            ),
          ),
        );
      }),
    );
  }
}

class VulcanXSelectableButton extends VulcanXStatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const VulcanXSelectableButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.grey.withAlpha(77),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: context.bodyMedium
              ?.copyWith(color: isSelected ? Colors.black : Colors.grey[600]),
        ),
      ),
    );
  }
}
