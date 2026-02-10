import 'package:app_ui/app_ui.dart';
import 'package:author_editor/item/items.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../enum/enums.dart';
import '../../vulcan_editor_eventbus.dart';

class WidgetSliderDesignItem extends StatelessWidget with EditorEventbus {
  final WidgetSliderType type;
  WidgetSliderDesignItem({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          if (WidgetSliderType.simpleSlider != type) ...[
            //레이어 정보 표시
            Obx(
              () => VulcanXSwitch(
                  label: 'layer_info_display'.tr,
                  value: controller.rxIsSliderIndicatorVisible.value,
                  onChanged: (value) => controller.toggleSliderIndicator()),
            ),
            const SizedBox(height: 16),
            Obx(
              () => VulcanXSvgButtonSelector(
                //레이어 정보 위치
                label: 'layer_info_position'.tr,
                initialIndex:
                    controller.rxSliderIndicatorPosition.value == 'top' ? 0 : 1,
                width: 148,
                height: 40,
                svgAssets: [
                  CommonAssets.icon.captionBelow,
                  CommonAssets.icon.captionAbove,
                ],
                onSelectedIndex: (index) =>
                    controller.toggleSliderIndicatorPosition(index ?? 0),
              ),
            ),
            const VulcanXDivider(space: 16),
          ],
          //번호 표시
          Obx(
            () => VulcanXSwitch(
              label: 'number_display'.tr,
              value: controller.rxIsSliderNumberVisible.value,
              onChanged: (value) => controller.toggleSliderNumber(),
            ),
          ),
          const SizedBox(height: 16.0),
          Obx(
            () => VulcanXColorPickerWidget(
                //번호 색상
                label: 'number_color'.tr,
                initialColor: controller.rxSliderNumberColor.value,
                onColorChanged: (color) =>
                    controller.setSliderNumberColor(color)),
          ),

          const SizedBox(height: 16),
          Obx(
            () => VulcanXLabelTextField(
              textFieldWidth: 80,
              initialValue: controller.rxSliderNumberSize.value,
              unit: 'px',
              //번호 크기
              label: 'number_size'.tr,
              // focusNode: focusWidthNode,
              inputFormatters: [
                // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: (value) => controller.setSliderNumberSize(value),
            ),
          ),
          const VulcanXDivider(space: 16),
          //기호 표시 위치
          Obx(
            () => VulcanXSwitch(
              label: 'symbol_display_position'.tr,
              value: controller.rxIsSliderSymbolVisible.value,
              onChanged: (value) => controller.toggleSliderSymbol(),
            ),
          ),
          const SizedBox(height: 16.0),
          Obx(
            () => VulcanXColorPickerWidget(
              //기호 색상
              label: 'symbol_color'.tr,
              initialColor: controller.rxSliderSymbolColor.value,
              onColorChanged: (color) => controller.setSliderSymbolColor(color),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => VulcanXLabelTextField(
              textFieldWidth: 80,
              initialValue: controller.rxSliderSymbolSize.value,
              unit: 'px',
              //기호 크기
              label: 'symbol_size'.tr,
              inputFormatters: [
                // 숫자만 입력
                // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              // focusNode: focusWidthNode,
              onChanged: (value) => controller.setSliderSymbolSize(value),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => VulcanXSvgButtonSelector(
              //기호 모양
              label: 'symbol_shape'.tr,
              width: 148,
              height: 40,
              initialIndex: controller.rxIsSliderSymbolSape.value ? 0 : 1,
              svgAssets: [
                CommonAssets.icon.circleOn,
                CommonAssets.icon.squareOn,
              ],
              onSelectedIndex: (index) =>
                  controller.toggleSliderSymbolShape(index ?? 0),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => VulcanXLabelTextField(
              textFieldWidth: 80,
              initialValue: controller.rxSliderIconSize.value,
              unit: 'px',
              //방향 아이콘 크기
              label: 'direction_icon_size'.tr,
              inputFormatters: [
                // 숫자만 입력
                // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              // focusNode: focusWidthNode,
              onChanged: (value) => controller.setSliderIconSize(value),
            ),
          ),

          const SizedBox(height: 16.0),
          VulcanXText(
              //방향 아이콘 변경
              text: 'direction_icon_change'.tr,
              suffixIcon: const Icon(Icons.expand_more_rounded, size: 16.0)),
          const SizedBox(height: 8),
          //팝업메뉴
          Obx(
            () => ImagePopupMenuItem(
              label: '이전',
              backgroundColor: Colors.white,
              type: ObjectType.widget,
              iconPath: controller.rxSliderPrevIconPath.value,
              onChanged: () =>
                  controller.changeSliderIconLocation('prevIconPath'),
            ),
          ),
          const SizedBox(height: 16.0),
          Obx(
            () => ImagePopupMenuItem(
              label: '이전(마우스 오버)',
              backgroundColor: Colors.white,
              type: ObjectType.widget,
              iconPath: controller.rxSliderPrevHoverIconPath.value,
              onChanged: () =>
                  controller.changeSliderIconLocation('prevHoverIconPath'),
            ),
          ),
          const SizedBox(height: 16.0),
          Obx(
            () => ImagePopupMenuItem(
              label: '다음',
              backgroundColor: Colors.white,
              type: ObjectType.widget,
              iconPath: controller.rxSliderNextIconPath.value,
              onChanged: () =>
                  controller.changeSliderIconLocation('nextIconPath'),
            ),
          ),
          const SizedBox(height: 16.0),
          Obx(
            () => ImagePopupMenuItem(
              label: '다음(마우스 오버)',
              backgroundColor: Colors.white,
              type: ObjectType.widget,
              iconPath: controller.rxSliderNextHoverIconPath.value,
              onChanged: () =>
                  controller.changeSliderIconLocation('nextHoverIconPath'),
            ),
          ),
          const SizedBox(height: 16.0),
          const VulcanXDivider(space: 16),
          const SizedBox(height: 8.0),
          VulcanXOutlinedButton.icon(
            // 방향 아이콘 초기화
            width: double.infinity,
            // onPressed: () => controller.resetToOriginalSettings(),
            // 방향 아이콘에 관련된 모든 설정을 초기화
            // onPressed: () => controller.resetSliderIconSettings(),
            onPressed: () => controller.resetToSliderOriginalSettings(),
            icon: CommonAssets.icon.replay.svg(),
            //원래대로
            child: Text('original_style'.tr),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
