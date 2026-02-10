import 'package:flutter/material.dart';

class VulcanXText extends StatefulWidget {
  final String text;
  final double? width;
  final double? height;
  final AlignmentGeometry alignment;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextStyle? style;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BoxDecoration? decoration;
  final Color? borderColor; // borderColor 필드 추가
  final bool isHover; // 호버 효과 활성화 여부
  final Color? hoverColor; // 호버 시 배경색
  final Color? hoverBorderColor; // 호버 시 테두리 색상
  final TextStyle? hoverTextStyle; // 호버 시 텍스트 스타일

  const VulcanXText({
    super.key,
    required this.text,
    this.style,
    this.suffixIcon,
    this.prefixIcon,
    this.width,
    this.height,
    this.alignment = Alignment.centerLeft,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.decoration,
    this.borderColor,
    this.isHover = false,
    this.hoverColor,
    this.hoverBorderColor,
    this.hoverTextStyle,
  });

  // outline 스타일을 위한 factory 생성자
  factory VulcanXText.outline({
    Key? key,
    required String text,
    TextStyle? style,
    Widget? suffixIcon,
    Widget? prefixIcon,
    double? width,
    double height = 38,
    AlignmentGeometry alignment = Alignment.centerLeft,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    VoidCallback? onTap,
    Color? borderColor,
    double borderWidth = 1.0,
    bool isHover = false,
    Color? hoverColor,
    Color? hoverBorderColor,
    TextStyle? hoverTextStyle,
  }) {
    return VulcanXText(
      key: key,
      text: text,
      style: style,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      onTap: onTap,
      borderColor: borderColor, // borderColor 전달
      isHover: isHover,
      hoverColor: hoverColor,
      hoverBorderColor: hoverBorderColor,
      hoverTextStyle: hoverTextStyle,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  @override
  State<VulcanXText> createState() => _VulcanXTextState();
}

class _VulcanXTextState extends State<VulcanXText> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    // 호버 상태에 따른 스타일 결정
    final currentTextStyle = _isHovering && widget.hoverTextStyle != null
        ? widget.hoverTextStyle
        : widget.style;

    // 호버 상태에 따른 decoration 결정
    BoxDecoration? currentDecoration = widget.decoration;
    if (_isHovering && widget.isHover) {
      if (widget.hoverColor != null || widget.hoverBorderColor != null) {
        final originalDecoration = widget.decoration ?? const BoxDecoration();
        currentDecoration = originalDecoration.copyWith(
          color: widget.hoverColor ?? originalDecoration.color,
          border: widget.hoverBorderColor != null
              ? Border.all(
                  color: widget.hoverBorderColor!,
                  width: originalDecoration.border?.top.width ?? 1.0,
                )
              : originalDecoration.border,
        );
      }
    }

    Widget child = InkWell(
      onTap: widget.onTap?.call,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: currentDecoration,
        padding: widget.padding,
        child: Align(
          alignment: widget.alignment,
          child: Row(
            mainAxisSize:
                widget.width != null ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (widget.prefixIcon != null) ...[
                widget.prefixIcon ?? const SizedBox.shrink(),
                const SizedBox(width: 8)
              ],
              Text(
                widget.text,
                style: currentTextStyle,
              ),
              if (widget.suffixIcon != null) ...[
                const SizedBox(width: 8),
                widget.suffixIcon ?? const SizedBox.shrink()
              ],
            ],
          ),
        ),
      ),
    );

    // 호버 효과가 활성화된 경우 MouseRegion으로 감싸기
    if (widget.isHover) {
      child = MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: child,
      );
    }

    return child;
  }
}
