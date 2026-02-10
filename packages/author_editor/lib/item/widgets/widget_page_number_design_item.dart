import 'package:app_ui/app_ui.dart';
import 'package:author_editor/item/items.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../vulcan_editor_eventbus.dart';

class WidgetPageNumberDesignItem extends StatelessWidget with EditorEventbus {
  WidgetPageNumberDesignItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          VulcanXColorPickerWidget(
              //글자 색상
              label: 'font_color'.tr,
              initialColor: controller.rxPageNumberColor.value,
              onColorChanged: (color) => controller.setPageNumberColor(color)),
          const SizedBox(height: 16),
          VulcanXLabelTextField(
            textFieldWidth: 80,
            initialValue: controller.rxPageNumberSize.value,
            unit: 'px',
            //글자  크기
            label: 'font_size'.tr,
            onChanged: (value) => controller.setPageNumberSize(value),
          ),
          const SizedBox(height: 16.0),
          VulcanXOutlinedButton.icon(
            width: double.infinity,
            onPressed: () => controller.resetToOriginalSettings(),
            icon: CommonAssets.icon.replay.svg(),
            //원래대로
            child: Text('original_style'.tr),
          ),
          const SizedBox(height: 16.0),
          PositionItem(type: 'location', unit: 'px', saveId: 'page_number'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
