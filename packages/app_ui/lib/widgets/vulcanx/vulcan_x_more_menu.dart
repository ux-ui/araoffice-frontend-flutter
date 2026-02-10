import 'package:flutter/material.dart';

import '../../app_ui.dart';

class VulcanXMoreMenu extends StatefulWidget {
  const VulcanXMoreMenu({
    super.key,
    required this.items,
    this.icon,
    this.iconSize,
    this.onTap,
    this.backgroundColor,
    this.offset = const Offset(-10, 0),
    this.tooltip,
    this.showToolTip,
  });

  final List<PopupMenuItem> items;
  final Widget? icon;
  final double? iconSize;
  final Offset offset;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final String? tooltip;
  final bool? showToolTip;

  @override
  State<VulcanXMoreMenu> createState() => _VulcanXMoreMenuState();
}

class _VulcanXMoreMenuState extends State<VulcanXMoreMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: widget.offset,
      tooltip: widget.tooltip ?? '',
      padding: EdgeInsets.zero,
      color: widget.backgroundColor ?? context.background,
      iconSize: widget.iconSize,
      icon: widget.icon ??
          Icon(
            Icons.more_vert,
            color: context.onSurface,
          ),
      itemBuilder: (context) {
        return widget.items;
      },
      onSelected: (value) {
        widget.onTap?.call();
      },
    );
  }
}
