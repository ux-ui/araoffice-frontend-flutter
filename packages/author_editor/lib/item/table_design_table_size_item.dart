import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';

import '../vulcan_editor_eventbus.dart';
import 'items.dart';

class TableDesignTableSizeItem extends StatelessWidget with EditorEventbus {
  TableDesignTableSizeItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizeItem(
        textFieldWidth: 113,
        padding: EdgeInsets.zero,
        focusWidthNode: controller.focusTableWidthNode,
        focusHeightNode: controller.focusTableHeightNode,
        prefixWidthIcon: IconButton(
          onPressed: () => controller.equalizeTableColumnWidth(),
          icon: CommonAssets.icon.horizontalDistribute.svg(),
        ),
        prefixHeightIcon: IconButton(
          onPressed: () => controller.equalizeTableRowHeight(),
          icon: CommonAssets.icon.verticalDistribute.svg(),
        ),
      ),
    );
  }
}
