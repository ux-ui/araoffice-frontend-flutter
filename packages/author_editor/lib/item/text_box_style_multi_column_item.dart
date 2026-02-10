import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';

/// 다단 스타일 아이템
class TextBoxStyleMultiColumnItem extends StatelessWidget with EditorEventbus {
  TextBoxStyleMultiColumnItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => CounterWidget(
                //다단 갯수
                text: 'multi_column_count'.tr,
                minValue: 1,
                initialValue: controller.rxMultiColumnCount.value.toString(),
                inputFormatters: [
                  // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (value) {
                  int count = int.tryParse(value) ?? 1;
                  controller.rxMultiColumnCount.value = count;
                  controller.setMultiColumn();
                },
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => CounterWidget(
                //다단 간격
                text: 'multi_column_gap'.tr,
                minValue: 1,
                initialValue: controller.rxMultiColumnGap.value.toString(),
                inputFormatters: [
                  // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (value) {
                  int count = int.tryParse(value) ?? 10;
                  controller.rxMultiColumnGap.value = count;
                  controller.setMultiColumn();
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('multi_column_fill'.tr),
                Obx(() => SizedBox(
                      width: 120,
                      child: VulcanXDropdown<MultiColumnFillType>(
                        height: 40.0,
                        enumItems: MultiColumnFillType.values,
                        onChanged: (MultiColumnFillType? newValue) {
                          controller.rxMultiColumnFillOption.value = newValue!;
                          controller.setMultiColumn();
                        },
                        hintText: '',
                        value: controller.rxMultiColumnFillOption.value,
                        displayStringForOption: (type) => type.name,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('multi_column_rule_style'.tr),
                Obx(() => SizedBox(
                      width: 120,
                      child: VulcanXDropdown<BorderStyleType>(
                        height: 40.0,
                        enumItems: BorderStyleType.values,
                        onChanged: (BorderStyleType? newValue) {
                          controller.rxMultiColumnRuleStyleOption.value =
                              newValue!;
                          controller.setMultiColumn();
                        },
                        hintText: '',
                        value: controller.rxMultiColumnRuleStyleOption.value,
                        displayStringForOption: (type) => type.name,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Obx(
              () => CounterWidget(
                //선 크기
                text: 'multi_column_rule_width'.tr,
                minValue: 0,
                initialValue:
                    controller.rxMultiColumnRuleWidth.value.toString(),
                inputFormatters: [
                  // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (value) {
                  int count = int.tryParse(value) ?? 1;
                  controller.rxMultiColumnRuleWidth.value = count;
                  controller.setMultiColumn();
                },
              ),
            ),
            const SizedBox(height: 8),
            VulcanXColorPickerWidget(
                label: 'multi_column_rule_color'.tr,
                initialColor: controller.rxMultiColumnRuleColor.value,
                onColorChanged: (color) {
                  controller.rxMultiColumnRuleColor.value = color;
                  controller.setMultiColumn();
                }),
            const SizedBox(height: 8),
            VulcanXOutlinedButton(
                width: double.infinity,
                onPressed: controller.removeMultiColumn,
                child: Text('multi_column_remove'.tr)),
            const SizedBox(height: 16),
          ],
        ));
  }
}
