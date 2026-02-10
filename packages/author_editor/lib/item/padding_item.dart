import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';

enum SpacingType {
  padding,
  margin,
}

class PaddingItem extends StatelessWidget with EditorEventbus {
  final String title;
  final SpacingType type;

  PaddingItem({
    super.key,
    required this.title,
    this.type = SpacingType.padding,
  });

  final Rx<SpacingType> selectedType = SpacingType.padding.obs;

  @override
  Widget build(BuildContext context) {
    // 초기값 설정
    selectedType.value = type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => SizedBox(
                  width: 268,
                  child: VulcanXLabelTextField(
                    textFieldWidth: 125,
                    initialValue: selectedType.value == SpacingType.padding
                        ? controller.rxPadding.value
                        : controller.rxMargin.value,
                    unit: 'px',
                    label: title,
                    inputFormatters: [
                      // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) {
                      if (selectedType.value == SpacingType.padding) {
                        controller.setPadding(value);
                      } else {
                        controller.setMargin(value);
                      }
                    },
                  ),
                )),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 왼쪽
            Obx(() => SizedBox(
                  width: 130,
                  child: VulcanXLabelTextField(
                    textFieldWidth: 100,
                    initialValue: selectedType.value == SpacingType.padding
                        ? controller.rxPaddingLeft.value
                        : controller.rxMarginLeft.value,
                    unit: 'px',
                    labelWidget:
                        CommonAssets.icon.borderLeft.svg(width: 25, height: 25),
                    inputFormatters: [
                      // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) {
                      if (selectedType.value == SpacingType.padding) {
                        controller.setPadding(value, type: PaddingType.left);
                      } else {
                        controller.setMargin(value, type: MarginType.left);
                      }
                    },
                  ),
                )),
            const Spacer(),
            // 오른쪽
            Obx(() => SizedBox(
                  width: 130,
                  child: VulcanXLabelTextField(
                    textFieldWidth: 100,
                    initialValue: selectedType.value == SpacingType.padding
                        ? controller.rxPaddingRight.value
                        : controller.rxMarginRight.value,
                    unit: 'px',
                    labelWidget: CommonAssets.icon.borderRight
                        .svg(width: 25, height: 25),
                    inputFormatters: [
                      // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) {
                      if (selectedType.value == SpacingType.padding) {
                        controller.setPadding(value, type: PaddingType.right);
                      } else {
                        controller.setMargin(value, type: MarginType.right);
                      }
                    },
                  ),
                )),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 위쪽
            Obx(() => SizedBox(
                  width: 130,
                  child: VulcanXLabelTextField(
                    textFieldWidth: 100,
                    initialValue: selectedType.value == SpacingType.padding
                        ? controller.rxPaddingTop.value
                        : controller.rxMarginTop.value,
                    unit: 'px',
                    labelWidget:
                        CommonAssets.icon.borderTop.svg(width: 25, height: 25),
                    inputFormatters: [
                      // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) {
                      if (selectedType.value == SpacingType.padding) {
                        controller.setPadding(value, type: PaddingType.top);
                      } else {
                        controller.setMargin(value, type: MarginType.top);
                      }
                    },
                  ),
                )),
            const Spacer(),
            // 아래쪽
            Obx(() => SizedBox(
                  width: 130,
                  child: VulcanXLabelTextField(
                    textFieldWidth: 100,
                    initialValue: selectedType.value == SpacingType.padding
                        ? controller.rxPaddingBottom.value
                        : controller.rxMarginBottom.value,
                    unit: 'px',
                    labelWidget: CommonAssets.icon.borderBottom
                        .svg(width: 25, height: 25),
                    inputFormatters: [
                      // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) {
                      if (selectedType.value == SpacingType.padding) {
                        controller.setPadding(value, type: PaddingType.bottom);
                      } else {
                        controller.setMargin(value, type: MarginType.bottom);
                      }
                    },
                  ),
                )),
          ],
        ),
        const SizedBox(height: 16),
        const VulcanXDivider(),
      ],
    );
  }
}
