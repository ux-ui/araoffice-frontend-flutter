import 'package:flutter/material.dart';

class BaseAnimationButton extends StatefulWidget {
  final Function()? onTap;
  final bool disabled;
  final Color? hoverColor;
  final Color? focusColor;
  final Color? splashColor;
  final Color? highlightColor;
  final double? radius;

  const BaseAnimationButton({
    super.key,
    this.onTap,
    this.hoverColor,
    this.focusColor,
    this.splashColor,
    this.highlightColor,
    this.disabled = false,
    this.radius,
  });

  @override
  State<BaseAnimationButton> createState() => _BaseAnimationButtonState();
}

class _BaseAnimationButtonState extends State<BaseAnimationButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: widget.disabled
          ? const SizedBox()
          : InkWell(
              radius: widget.radius ?? 8,
              borderRadius: BorderRadius.circular(widget.radius ?? 8),
              hoverColor:
                  widget.hoverColor ?? const Color(0xff00000D).withAlpha(13),
              focusColor:
                  widget.focusColor ?? const Color(0xff00000D).withAlpha(21),
              splashColor: const Color(0xff00000D).withAlpha(21),
              highlightColor: const Color(0xff00000D).withAlpha(13),
              onTap: () {
                widget.onTap?.call();
              },
            ),
    );
  }
}
