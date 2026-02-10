import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../enum/shape_line_type.dart';

class ShapeDesignItem extends StatelessWidget with EditorEventbus {
  ShapeDesignItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            VulcanXColorPickerWidget(
                // 배경색
                label: 'background_color'.tr,
                initialColor: controller.rxShapeBackgroundColor.value,
                onColorChanged: (color) => controller.setShapeBackColor(color)),
            const SizedBox(height: 8),
            VulcanXColorPickerWidget(
                // 선 색
                label: 'line_color'.tr,
                initialColor: controller.rxShapeLineColor.value,
                onColorChanged: (color) => controller.setShapeLineColor(color)),
            const SizedBox(height: 8),

            // Obx(() => VulcanXSvgButtonSelector(
            //     width: 148,
            //     //선 모양
            //     label: 'line_shape'.tr,
            //     initialEnum: controller.rxTextAlign.value,
            //     enumValues: TextAlignType.values,
            //     svgAssets: [
            //       CommonAssets.icon.lineBolder,
            //       CommonAssets.icon.lineStyleDash,
            //       CommonAssets.icon.lineStyleDot,
            //       CommonAssets.icon.block,
            //     ],
            //     onSelectedEnum: (align) =>
            //         controller.setTextAlign(align!.name))),
            // const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 선 두께
                Text('line_width'.tr),
                Obx(
                  () => CounterWidget(
                    minValue: 1,
                    initialValue: controller.rxShapeLineWidth.value.toString(),
                    inputFormatters: [
                      // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) {
                      int? width = int.tryParse(value);
                      controller.setShapeLineWidth(width ?? 1);
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => VulcanXSvgButtonSelector(
                width: 148,
                //선 머리
                label: 'line_head'.tr,
                initialEnum: controller.rxShapeLineHeadType.value,
                enumValues: ShapeLineType.values,
                svgAssets: [
                  CommonAssets.icon.lineBolder,
                  CommonAssets.icon.lineEndCircle,
                  CommonAssets.icon.lineEndArrow,
                  CommonAssets.icon.lineEndDiamond,
                ],
                onSelectedEnum: (type) =>
                    controller.setShapeLineHeadType(type!))),

            const SizedBox(height: 8),
            Obx(() => VulcanXSvgButtonSelector(
                width: 148,
                //선 꼬리
                label: 'line_tail'.tr,
                initialEnum: controller.rxShapeLineTailType.value,
                enumValues: ShapeLineType.values,
                svgAssets: [
                  CommonAssets.icon.lineBolder,
                  CommonAssets.icon.lineStartCircle,
                  CommonAssets.icon.lineStartArrow,
                  CommonAssets.icon.lineStartDiamond,
                ],
                onSelectedEnum: (type) =>
                    controller.setShapeLineTailType(type!))),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 선 모양 크기
                Text('line_shape_size'.tr),
                Obx(
                  () => CounterWidget(
                    initialValue:
                        controller.rxShapeLineHeadTailSize.value.toString(),
                    inputFormatters: [
                      // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) {
                      int? size = int.tryParse(value);
                      controller.setShapeLineHeadTailSize(size ?? 1);
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            VulcanXOutlinedButton.icon(
                width: double.infinity,
                onPressed: () => controller.removeAllStyle(),
                icon: CommonAssets.icon.replay.svg(),
                child: Text('default_style'.tr)),
          ],
        ));
  }
}
