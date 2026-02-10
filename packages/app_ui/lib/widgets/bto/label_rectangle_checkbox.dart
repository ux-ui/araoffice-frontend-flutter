import 'package:flutter/material.dart';

import '../../app_ui.dart';

class LabelRectangleCheckbox extends StatelessWidget {
  final String label;
  final bool? isChecked;
  final Function(bool value) onChanged;
  const LabelRectangleCheckbox(
      {super.key,
      required this.label,
      required this.onChanged,
      this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RectangleCheckBox(
          isChecked: isChecked ?? false,
          onChanged: (value) => onChanged.call(value),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
