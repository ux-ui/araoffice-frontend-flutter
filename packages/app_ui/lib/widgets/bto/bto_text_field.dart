import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_ui.dart';

class BtoTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextStyle? textStyle;
  final FocusNode? focusNode;
  final bool isPassword;
  final bool autofocus;
  final bool readOnly;
  final bool showCounter;
  final bool enabled;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final TextStyle? helperStyle;
  final int? minLines;
  final int? maxLines;
  final bool expands;
  final bool? showClearIcon;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? inputType;
  final TextInputAction? textInputAction;
  final IconButton? suffixIcon;
  final double? radius;
  final double contentPaddingVertical;
  final double contentPaddingHorizontal;
  final InputDecoration? decoration;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final Function(String)? onChanged;
  final VoidCallback? onEditingComplete;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onClickClear;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? disabledBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final TapRegionCallback? onTapOutside;

  const BtoTextField({
    super.key,
    required this.controller,
    this.textStyle,
    this.focusNode,
    this.isPassword = false,
    this.autofocus = false,
    this.showCounter = false,
    this.enabled = true,
    this.readOnly = false,
    this.labelText,
    this.hintText,
    this.errorText,
    this.helperText,
    this.helperStyle,
    this.minLines,
    this.maxLines,
    this.expands = false,
    this.showClearIcon = false,
    this.maxLength,
    this.inputFormatters,
    this.inputType,
    this.textInputAction,
    this.suffixIcon,
    this.radius = 5.0,
    this.contentPaddingVertical = 14.0,
    this.contentPaddingHorizontal = 8.0,
    this.decoration,
    this.textAlign,
    this.textAlignVertical,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.onClickClear,
    this.enabledBorder,
    this.focusedBorder,
    this.disabledBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.onTapOutside,
  });

  @override
  Widget build(BuildContext context) {
    int? validMaxLines = maxLines;
    if (minLines != null) {
      validMaxLines = math.max(minLines!, maxLines ?? 1);
    }
    double newRadius = radius ?? 5.0;
    IconButton? suffixClearIcon;
    if (suffixIcon != null) {
      suffixClearIcon = suffixIcon;
    } else {
      suffixClearIcon = onClickClear != null
          ? IconButton(
              icon: Icon(Icons.clear, size: 20, color: context.primary),
              onPressed: () {
                onClickClear != null
                    ? onClickClear?.call()
                    : controller?.clear();
              },
            )
          : null;
    }

    return TextFormField(
      controller: controller,
      style: textStyle,
      focusNode: focusNode,
      obscureText: isPassword,
      autocorrect: false,
      onTapOutside: onTapOutside,
      autofocus: autofocus,
      enableSuggestions: false,
      readOnly: readOnly,
      enabled: enabled,
      minLines: minLines,
      maxLines: validMaxLines,
      expands: expands,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      keyboardType: inputType,
      cursorColor: context.primary,
      cursorWidth: 0.8,
      textAlign: textAlign ?? TextAlign.start,
      textAlignVertical: textAlignVertical ?? TextAlignVertical.top,
      decoration: decoration ??
          InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                vertical: contentPaddingVertical,
                horizontal: contentPaddingHorizontal),
            isDense: true,
            counterText: showCounter ? null : '',
            labelText: labelText,
            helperText: helperText,
            helperStyle: helperStyle ??
                context.labelSmall
                    ?.apply(color: context.onSurfaceVariant.withAlpha(102)),
            labelStyle: context.bodyLarge,
            hintText: hintText,
            hintStyle: context.bodyLarge
                ?.apply(color: context.onSurfaceVariant.withAlpha(128)),
            errorText: errorText,
            errorStyle: context.bodyLarge?.apply(color: context.error),
            enabledBorder: enabledBorder ??
                OutlineInputBorder(
                    borderSide: BorderSide(color: context.surfaceContainer),
                    borderRadius: BorderRadius.circular(newRadius)),
            focusedBorder: focusedBorder ??
                OutlineInputBorder(
                    borderSide: BorderSide(
                      color: context.primary,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(newRadius)),
            disabledBorder: disabledBorder ??
                OutlineInputBorder(
                    borderSide: BorderSide(
                        color: context.surfaceContainer.withAlpha(128)),
                    borderRadius: BorderRadius.circular(newRadius)),
            errorBorder: errorBorder ??
                OutlineInputBorder(
                    borderSide: BorderSide(color: context.primary),
                    borderRadius: BorderRadius.circular(newRadius)),
            focusedErrorBorder: focusedBorder ??
                OutlineInputBorder(
                    borderSide: BorderSide(color: context.primary),
                    borderRadius: BorderRadius.circular(newRadius)),
            suffixIcon: showClearIcon ?? false ? suffixClearIcon : null,
          ),
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
    );
  }
}
