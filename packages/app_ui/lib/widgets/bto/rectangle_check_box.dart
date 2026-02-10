import 'package:flutter/material.dart';

import '../../app_ui.dart';

class RectangleCheckBox extends StatefulWidget {
  final bool isChecked;
  final bool isGroup;
  final double? buttonSize;
  final double? iconSize;
  final Widget? selectedIcon;
  final Color? selectedBackgroundColor;
  final Color? unselectedBackgroundColor;
  final Color? iconColor;
  final Function(bool)? onChanged;
  const RectangleCheckBox(
      {this.isChecked = false,
      this.isGroup = false,
      this.selectedIcon,
      this.onChanged,
      this.buttonSize = 24,
      this.iconSize = 12,
      this.selectedBackgroundColor,
      this.unselectedBackgroundColor,
      this.iconColor,
      super.key});

  @override
  State<RectangleCheckBox> createState() => _RectangleCheckBoxState();
}

class _RectangleCheckBoxState extends State<RectangleCheckBox> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.isChecked;
  }

  @override
  void didUpdateWidget(covariant RectangleCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isChecked != widget.isChecked) {
      setState(() {
        isChecked = widget.isChecked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.isGroup
          ? null
          : () {
              setState(() {
                isChecked = !isChecked;
              });
              widget.onChanged?.call(isChecked);
            },
      child: Container(
        width: widget.buttonSize,
        height: widget.buttonSize,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          color: isChecked
              ? widget.selectedBackgroundColor ?? context.primary
              : widget.unselectedBackgroundColor ?? context.surfaceContainer,
        ),
        child: widget.selectedIcon != null
            ? isChecked
                ? widget.selectedIcon
                : const SizedBox()
            : Icon(
                Icons.check,
                color: widget.iconColor ?? const Color(0xffFFFFFF),
                size: widget.iconSize,
              ),
      ),
    );
  }
}
