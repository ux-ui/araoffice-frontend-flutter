import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_ui.dart';
import 'vulcan_x_stateless_widget.dart';

class VulcanXLabelTextField extends VulcanXStatelessWidget {
  final double? width;
  final double? height;
  final double? textFieldWidth;
  final double? textFieldHeight;
  final double? spaceBetween;
  final String? label;
  final Widget? labelWidget;
  final String? unit;
  final String? initialValue;
  final Widget? prefix;
  final Widget? suffixIcon;
  final Widget? prefixCenterIcon;
  final TextAlign? textAlign;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? onFocusChanged;
  final String? hintText;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  const VulcanXLabelTextField({
    super.key,
    this.label,
    this.labelWidget,
    this.unit,
    this.initialValue,
    this.onChanged,
    this.width,
    this.height = 40,
    this.textFieldWidth,
    this.textFieldHeight,
    this.spaceBetween,
    this.prefix,
    this.suffixIcon,
    this.textAlign,
    this.onSubmitted,
    this.onFocusChanged,
    this.focusNode,
    this.prefixCenterIcon,
    this.hintText,
    this.inputFormatters,
  });

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          labelWidget ?? Text(label ?? '', style: context.bodyMedium),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prefixCenterIcon != null) prefixCenterIcon!,
                Flexible(
                  child: VulcanXTextField(
                    width: textFieldWidth,
                    height: textFieldHeight,
                    hintText: hintText,
                    controller: TextEditingController(text: initialValue)
                      ..selection = TextSelection.fromPosition(
                          TextPosition(offset: initialValue!.length)),
                    prefix: prefix,
                    suffixText: unit,
                    suffixIcon: suffixIcon,
                    suffixStyle: TextStyle(color: context.outline),
                    textAlign: textAlign ?? TextAlign.start,
                    onChanged: (value) => onChanged?.call(value),
                    onSubmitted: (value) => onSubmitted?.call(value),
                    onFocusChanged: (value) => onFocusChanged?.call(value),
                    focusNode: focusNode,
                    inputFormatters: inputFormatters,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
