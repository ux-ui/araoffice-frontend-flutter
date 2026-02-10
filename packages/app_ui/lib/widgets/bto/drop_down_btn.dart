import 'package:flutter/material.dart';

import '../../app_ui.dart';

class BtoDropDownBtn<T> extends StatefulWidget {
  const BtoDropDownBtn(
      {required this.items,
      required this.value,
      required this.onChanged,
      this.padding,
      this.border,
      this.backgroundColor,
      this.borderRadius,
      this.isDisabled = false,
      this.height,
      this.hint,
      this.isExpanded = false,
      super.key});

  final List<DropdownMenuItem<String>>? items;
  final dynamic value;
  final Function(T?) onChanged;
  final EdgeInsets? padding;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final bool isDisabled;
  final double? height;
  final Widget? hint;
  final bool isExpanded;

  @override
  State<BtoDropDownBtn> createState() => _BtoDropDownBtnState();
}

class _BtoDropDownBtnState extends State<BtoDropDownBtn> {
  @override
  Widget build(BuildContext context) {
    return widget.isDisabled
        ? Container(
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Text(
                  widget.value,
                  style: context.titleSmall
                      ?.apply(color: context.onSurface.withAlpha(77)),
                ),
                Icon((Icons.arrow_drop_down),
                    color: context.onSurface.withAlpha(77))
              ],
            ))
        : Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              border: widget.border,
            ),
            child: DropdownButton(
              items: widget.items,
              onChanged: (value) {
                widget.onChanged(value);
              },
              isExpanded: widget.isExpanded,
              hint: widget.hint,
              underline: Container(),
              value: widget.value,
              icon: Icon(Icons.arrow_drop_down, color: context.onSurface),
              elevation: 8,
              style: context.titleSmall,
              padding:
                  widget.padding ?? const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          );
  }
}
