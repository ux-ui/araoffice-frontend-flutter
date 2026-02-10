import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_ui.dart';
import 'vulcan_x_stateful_widget.dart';

class VulcanXImageChip extends VulcanXStatefulWidget {
  final double? width;
  final double? height;
  final bool? isBookmark;
  final bool? isSelectedBookmark;
  final ValueChanged<bool>? onSelectedBookmark;
  final bool? isCrownBadge;
  final Widget? chipLabel;
  final bool? isOwner;
  final String? imageUrl;

  const VulcanXImageChip({
    super.key,
    this.chipLabel,
    this.isBookmark = false,
    this.isCrownBadge = false,
    this.width,
    this.height,
    this.imageUrl,
    this.isSelectedBookmark,
    this.onSelectedBookmark,
    this.isOwner = false,
  });

  @override
  VulcanXImageChipState createState() => VulcanXImageChipState();
}

class VulcanXImageChipState extends VulcanXState<VulcanXImageChip> {
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelectedBookmark ?? false;
  }

  @override
  Widget buildWithTheme(BuildContext context, ThemeData themeData) {
    return VulcanXRoundedContainer.grey(
      width: widget.width ?? 242,
      height: widget.height ?? 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Image.network(
              widget.imageUrl ?? '',
              width: 200,
              height: 300,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.grey),
                );
              },
            ),
            //CommonAssets.image.testBookCover.image(),
          ),
          if (widget.isBookmark == true)
            Positioned(
              top: 8,
              right: 8,
              child: VulcanXRectangleIconButton.outlined(
                width: 28,
                height: 28,
                //즐겨찾기
                tooltip: 'bookmark'.tr,
                icon: _isSelected
                    ? CommonAssets.icon.gradeOff.svg(
                        colorFilter:
                            ColorFilter.mode(context.tertiary, BlendMode.srcIn))
                    : CommonAssets.icon.gradeOn.svg(),
                onPressed: () {
                  setState(() {
                    _isSelected = !_isSelected;
                  });
                  widget.onSelectedBookmark?.call(_isSelected);
                },
              ),
            ),
          if (widget.isCrownBadge == true)
            Positioned(
              bottom: 8,
              right: 8,
              child: CommonAssets.icon.crownBadge.svg(),
            ),
          if (widget.chipLabel != null)
            Positioned(
              left: 8,
              bottom: 8,
              child: Chip(label: widget.chipLabel!),
            ),
          if (widget.isOwner != true)
            Positioned(
              top: 8,
              left: 8,
              child: Chip(
                label: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.share_outlined,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text('Shared'.tr),
                  ],
                ),
                backgroundColor: context.primary.withAlpha(128),
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
