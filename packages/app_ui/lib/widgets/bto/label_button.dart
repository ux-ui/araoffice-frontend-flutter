import 'package:flutter/material.dart';

import '../../app_ui.dart';

// Lable with Container
class LabelButton extends StatelessWidget {
  const LabelButton(
      {super.key,
      required this.label,
      this.leading,
      this.textStyle = TextStyles.titleSmall,
      this.onPressed,
      this.backgroundColor,
      this.textColor,
      this.borderRadius,
      this.padding,
      this.isBorder = true,
      this.borderColor,
      this.borderWidth,
      this.isExtended = false});

  final String label;
  final TextStyle textStyle;
  final Function()? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final bool? isBorder;
  final double? borderWidth;
  final Color? borderColor;
  final bool isExtended;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      radius: borderRadius ?? 20,
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? context.primary,
          borderRadius: BorderRadius.circular(borderRadius ?? 20),
          border: isBorder == true
              ? Border.all(
                  color: borderColor ?? context.primary,
                  width: borderWidth ?? 1,
                )
              : null,
        ),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        child: Row(children: [
          isExtended ? const Spacer() : const SizedBox(),
          leading ?? const SizedBox(),
          Text(label,
              style: textStyle.apply(color: textColor ?? context.onPrimary)),
          isExtended ? const Spacer() : const SizedBox(),
        ]),
      ),
    );
  }
}
