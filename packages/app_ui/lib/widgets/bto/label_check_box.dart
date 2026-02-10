import 'package:flutter/material.dart';

import 'circle_check_box.dart';

class LabelCheckBox extends StatefulWidget {
  final bool? isPrefixIcon;
  final bool? isSuffixIcon;
  final double checkSize;
  final Widget? label;
  final Function(bool)? onChanged;
  const LabelCheckBox(
      {this.isSuffixIcon = false,
      this.isPrefixIcon = false,
      this.checkSize = 12,
      this.label,
      this.onChanged,
      super.key});

  @override
  State<LabelCheckBox> createState() => _LabelCheckBoxState();
}

class _LabelCheckBoxState extends State<LabelCheckBox> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        titleAlignment: ListTileTitleAlignment.center,
        title: widget.label,
        leading: widget.isPrefixIcon!
            ? CircleCheckBox(
                isChecked: true,
                buttonSize: widget.checkSize,
                onChanged: (status) {
                  widget.onChanged?.call(status);
                },
              )
            : null,
        trailing: widget.isSuffixIcon!
            ? CircleCheckBox(
                isChecked: false,
                buttonSize: widget.checkSize,
                // onChanged: (bool? value) {},
                onChanged: (status) {
                  widget.onChanged?.call(status);
                },
              )
            : null);
  }
}
