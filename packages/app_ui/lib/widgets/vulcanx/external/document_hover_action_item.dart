import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';

import '../../widgets.dart';

class DocumentHoverActionItem extends StatefulWidget {
  final int? index;
  final String pageId;
  final String label;
  final String url;
  final List<PopupMenuItem>? items;
  final VoidCallback? onTitleTap;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;
  final VoidCallback? onRename;

  const DocumentHoverActionItem({
    super.key,
    this.index,
    required this.pageId,
    required this.label,
    required this.url,
    this.onTitleTap,
    this.onDelete,
    this.onCopy,
    this.onRename,
    this.items,
  });

  @override
  State<DocumentHoverActionItem> createState() =>
      _DocumentHoverActionItemState();
}

class _DocumentHoverActionItemState extends State<DocumentHoverActionItem> {
  bool isHovered = false;
  bool isPopupMenu = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() {
        isHovered = (isPopupMenu) ? true : false;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isHovered ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () => widget.onTitleTap?.call(),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file, color: Colors.grey),
              const SizedBox(width: 8),
              Text(widget.label),
              const Spacer(),
              if (isHovered) ...[
                if (widget.onCopy != null)
                  IconButton(
                    icon: CommonAssets.icon.contentCopy.svg(),
                    onPressed: () {
                      widget.onCopy?.call();
                    },
                  ),
                // TODO copy popupmenu 추후에 활성화
                VulcanXMoreMenu(items: widget.items ?? []),
                if (widget.onRename != null)
                  IconButton(
                    icon: const Icon(Icons.drive_file_rename_outline),
                    onPressed: () {
                      widget.onRename?.call();
                    },
                  ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => widget.onDelete?.call(),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
