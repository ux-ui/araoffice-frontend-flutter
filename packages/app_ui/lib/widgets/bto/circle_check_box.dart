import 'package:flutter/material.dart';

import '../../app_ui.dart';

class CircleCheckBox extends StatefulWidget {
  final bool isChecked;
  final bool isGroup;
  final Widget? selectedIcon;
  final bool? hideSelectedIcon;
  final double? buttonSize;
  final double? iconSize;
  final Color? selectedBackgroundColor;
  final Color? unselectedBackgroundColor;
  final Color? iconColor;
  final Color? borderColor;
  final Color? selectedBorderColor;
  final double? borderWidth;
  final Function(bool)? onChanged;

  const CircleCheckBox({
    super.key,
    required this.isChecked,
    this.selectedIcon,
    this.isGroup = false,
    this.onChanged,
    this.buttonSize = 12,
    this.iconSize = 12,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.iconColor,
    this.borderColor,
    this.selectedBorderColor,
    this.borderWidth,
    this.hideSelectedIcon = false,
  });

  @override
  State<CircleCheckBox> createState() => _CircleCheckBoxState();
}

class _CircleCheckBoxState extends State<CircleCheckBox> {
  bool isChecked = false;
  @override
  void initState() {
    super.initState();
    isChecked = widget.isChecked;
  }

  @override
  void didUpdateWidget(covariant CircleCheckBox oldWidget) {
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
          : widget.onChanged == null
              ? null
              : () {
                  setState(() {
                    isChecked = !isChecked;
                  });
                  widget.onChanged?.call(isChecked);
                },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isChecked
                ? widget.selectedBorderColor ?? Colors.transparent
                : widget.borderColor ?? Colors.transparent,
            width: widget.borderWidth ?? 1.0,
          ),
        ),
        child: CircleAvatar(
          radius: widget.buttonSize,
          backgroundColor: isChecked
              ? widget.selectedBackgroundColor ?? context.primary
              : widget.unselectedBackgroundColor ?? context.surfaceContainer,
          child: (widget.hideSelectedIcon == true)
              ? const SizedBox()
              : widget.selectedIcon != null
                  ? isChecked
                      ? widget.selectedIcon
                      : const SizedBox()
                  : Icon(
                      Icons.check,
                      color: widget.iconColor ?? const Color(0xffFFFFFF),
                      size: widget.iconSize,
                    ),
        ),
      ),
    );
  }
}
