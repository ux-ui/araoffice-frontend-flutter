import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditorContextMenu extends StatelessWidget {
  final Offset position;
  final ValueChanged<String>? onTap;

  const EditorContextMenu({
    super.key,
    required this.position,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withAlpha(51),
                ),
              ),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //가장 위로
                    _buildMenuItem(context, 'context_menu_top'.tr,
                        onTap != null ? () => onTap!('top') : null),
                    _buildDivider(),
                    //가장 아래로
                    _buildMenuItem(context, 'context_menu_bottom'.tr,
                        onTap != null ? () => onTap!('bottom') : null),
                    _buildDivider(),
                    //위로
                    _buildMenuItem(context, 'context_menu_upper'.tr,
                        onTap != null ? () => onTap!('upper') : null),
                    _buildDivider(),
                    //아래로
                    _buildMenuItem(context, 'context_menu_lower'.tr,
                        onTap != null ? () => onTap!('lower') : null),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String text,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                  color: onTap == null
                      ? Colors.grey
                      : Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey.withAlpha(51),
    );
  }
}
