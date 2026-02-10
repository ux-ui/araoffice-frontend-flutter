import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';

class BorderItem extends StatelessWidget with EditorEventbus {
  final String? type; // table | cell
  final FocusNode? focusNode;
  BorderItem({super.key, this.type, this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //테두리
                Text('border'.tr),
                Obx(() => SizedBox(
                      width: 113,
                      child: VulcanXDropdown<BorderStyleType>(
                        height: 40.0,
                        enumItems: BorderStyleType.values,
                        onChanged: (BorderStyleType? newValue) {
                          if (type == 'table') {
                            controller.rxTableBorderStyle.value = newValue!;
                          } else {
                            controller.rxBorderStyle.value = newValue!;
                          }
                          controller.setBorder(type: type);
                        },
                        hintText: '',
                        value: controller.rxBorderStyle.value,
                        displayStringForOption: (type) => type.name,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Obx(
              () => CounterWidget(
                minValue: 0,
                width: 113,
                //테두리 두께
                text: 'border_width'.tr,
                inputFormatters: [
                  // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                focusNode: focusNode,
                initialValue: (type == 'table')
                    ? controller.rxTableBorderWidth.value.toString()
                    : controller.rxBorderWidth.value.toString(),

                onChanged: (value) {
                  if (type == 'table') {
                    controller.rxTableBorderWidth.value =
                        int.tryParse(value) ?? 0;
                  } else {
                    controller.rxBorderWidth.value = int.tryParse(value) ?? 0;
                  }
                  controller.setBorder(type: type);
                },
              ),
            ),
            const SizedBox(height: 8),
            VulcanXColorPickerWidget(
                //테두리 색상
                label: 'border_color'.tr,
                initialColor: (type == 'table')
                    ? controller.rxTableBorderColor.value
                    : controller.rxBorderColor.value,
                onColorChanged: (color) {
                  if (type == 'table') {
                    controller.rxTableBorderColor.value = color;
                  } else {
                    controller.rxBorderColor.value = color;
                  }
                  controller.setBorder(type: type);
                }),
            const SizedBox(height: 5),
          ],
        ),
      ],
    );
  }
}
