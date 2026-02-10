// AdjustedLeftDrawer 위젯
import 'package:flutter/material.dart';

class AnimatedContainerDrawer extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final Widget child;
  final double drawerWidth;
  final AlignmentGeometry alignment;

  const AnimatedContainerDrawer({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.child,
    this.drawerWidth = 250,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    // 닫힌 상태에서는 자식 위젯을 완전히 배제하여 불필요한 레이아웃/측정을 방지
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isOpen ? drawerWidth : 0,
      child: isOpen
          ? Align(
              alignment: alignment,
              child: SizedBox(
                width: drawerWidth,
                child: child,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
