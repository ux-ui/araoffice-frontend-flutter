import 'package:flutter/material.dart';

class HoverableAnimatedTap extends StatefulWidget {
  final Widget? child;
  final GestureTapCallback? onTap;
  const HoverableAnimatedTap({super.key, this.child, this.onTap});

  @override
  State<HoverableAnimatedTap> createState() => _HoverableAnimatedTapState();
}

class _HoverableAnimatedTapState extends State<HoverableAnimatedTap> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap?.call(),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: isHovered
                ? (Matrix4.identity()..translate(0, -5, 0))
                : Matrix4.identity(),
            child: widget.child ?? const SizedBox.shrink()),
      ),
    );
  }
}
