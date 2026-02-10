import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_ui.dart';
import 'vulcan_x_stateless_widget.dart';

class VulcanXTextField extends VulcanXStatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final bool? isSearchIcon;
  final TextAlign? textAlign;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? prefix;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final Widget? suffixIcon;
  final Widget? suffix;
  final String? suffixText;
  final TextStyle? suffixStyle;
  final double? width;
  final double? height;
  final bool autofocus;
  final bool readOnly;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;
  final Function(bool)? onFocusChanged;
  final Function()? onEditingComplete;
  final String? errorText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  const VulcanXTextField({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.prefix,
    this.prefixText,
    this.prefixStyle,
    this.suffixIcon,
    this.suffix,
    this.suffixText,
    this.suffixStyle,
    this.width,
    this.height = 40.0,
    this.textAlign,
    this.isSearchIcon,
    this.onTap,
    this.autofocus = false,
    this.readOnly = false,
    this.focusNode,
    this.onSubmitted,
    this.onFocusChanged,
    this.onEditingComplete,
    this.errorText,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    // 로컬 FocusNode 생성 (focusNode가 제공되지 않은 경우)
    // final effectiveFocusNode = focusNode;

    // 이전 포커스 상태를 저장할 변수
    bool wasFocused = false;

    // FocusNode 리스너 추가
    // effectiveFocusNode?.addListener(() {
    //   final hasFocus = effectiveFocusNode.hasFocus;
    //   onFocusChanged?.call(hasFocus);

    //   // 포커스가 해제될 때 onSubmitted 호출
    //   if (wasFocused && !hasFocus && onSubmitted != null) {
    //     final currentText = controller?.text ?? '';
    //     onSubmitted?.call(currentText);
    //   }

    //   wasFocused = hasFocus;
    // });

    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
          controller: controller,
          textAlign: textAlign ?? TextAlign.start,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: context.surfaceContainerHigh),
            prefixIcon: (isSearchIcon == true)
                ? Icon(Icons.search, size: 20, color: context.outline)
                : prefixIcon,
            prefix: prefix,
            prefixText: prefixText,
            prefixStyle: prefixStyle,
            suffixIcon: suffixIcon,
            suffix: suffix,
            suffixText: suffixText,
            suffixStyle: suffixStyle,
            errorText: errorText,
            isDense: true,
            counterText: (maxLength != null) ? null : '',
          ),
          maxLength: maxLength,
          autofocus: autofocus,
          readOnly: readOnly,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: (text) {
            // if (text.characters.length > maxLength) {
            //   controller?.text = text.characters.take(maxLength!).toString();
            // }
            onChanged?.call(text);
          },
          onTap: readOnly
              ? () {
                  //FocusScope.of(context).unfocus();
                  onTap?.call();
                }
              : onTap,
          onFieldSubmitted: onSubmitted,
          enableInteractiveSelection: !readOnly,
          showCursor: !readOnly,
          focusNode: focusNode,
          validator: validator,
          onEditingComplete: onEditingComplete,
          inputFormatters: inputFormatters),
    );
  }
}
