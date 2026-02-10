import 'package:app_ui/app_ui.dart';
import 'package:author_editor/extension/assets_image_extension.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';
import '../vulcan_editor_eventbus.dart';
import 'items.dart';

class TableDesignTableItem extends StatelessWidget with EditorEventbus {
  TableDesignTableItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          BackgroundItem(type: 'table'),
          const SizedBox(height: 8.0),
          BackgroundImageItem(
              type: ObjectType.table, backgroundType: ObjectType.table),
          const SizedBox(height: 8.0),
          BorderItem(
              type: 'table', focusNode: controller.focusTableBorderWidthNode),
          const SizedBox(height: 8.0),
          VulcanXText(
              //표 스타일
              text: 'table_style'.tr,
              suffixIcon: const Icon(Icons.expand_more_rounded, size: 16.0)),
          const SizedBox(height: 8),
          VulcanXInkWellSelector(
            onTaps: List.generate(
              45,
              (index) => () => controller.setTableStyle(index + 1),
            ),
            spacing: 7,
            runSpacing: 7,
            alignment: WrapAlignment.start,
            children: List.generate(
              45,
              (index) => Assets.image
                  .fromNumberedImage('table_style', index + 1)
                  .image(),
            ),
          ),
          const SizedBox(height: 16),
          const VulcanXDivider(),
          const SizedBox(height: 16),
          PaddingItem(title: 'padding'.tr),
          const SizedBox(height: 16),
          PaddingItem(title: 'margin'.tr, type: SpacingType.margin),
          const SizedBox(height: 16),
          VulcanXOutlinedButton.icon(
              width: double.infinity,
              onPressed: () => controller.removeAllStyle(),
              icon: CommonAssets.icon.replay.svg(),
              // default_style
              child: Text('default_style'.tr)),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
