import 'package:app_ui/app_ui.dart';
import 'package:author_editor/extension/string_extension.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';

class TextBoxStyleParagraphItem extends StatelessWidget with EditorEventbus {
  TextBoxStyleParagraphItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 글상자
                Text('text_box'.tr),
                SizedBox(
                  width: 148,
                  child: VulcanXDropdown<TextBoxType>(
                    disabled: controller.rxDisabledTextbox.value ? false : true,
                    height: 40.0,
                    enumItems: TextBoxType.values,
                    onChanged: (TextBoxType? newValue) =>
                        controller.convertTextbox(newValue!),
                    hintText: '',
                    value: controller.isTextbox(),
                    displayStringForOption: (type) => type.name,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (controller.rxDisabledTextbox.value == false) ...[
              Obx(() => VulcanXSvgButtonSelector(
                  disabled: controller.rxDisabledTextbox.value,
                  width: 148,
                  //정렬
                  label: 'align'.tr,
                  initialEnum: controller.rxTextAlign.value,
                  enumValues: TextAlignType.values,
                  svgAssets: [
                    CommonAssets.icon.formatAlignLeft,
                    CommonAssets.icon.formatAlignCenter,
                    CommonAssets.icon.formatAlignRight,
                    CommonAssets.icon.formatAlignJustify,
                  ],
                  onSelectedEnum: (align) =>
                      controller.setTextAlign(align!.translationKey))),
              const SizedBox(height: 8),
              VulcanXSvgButtonSelector(
                disabled: controller.rxDisabledTextbox.value,
                width: 148,
                isButtonMode: true, // 여러 번 누를 수 있도록 설정
                //들여쓰기
                label: 'indent'.tr,
                svgAssets: [
                  CommonAssets.icon.formatIndentDecrease,
                  CommonAssets.icon.formatIndentIncrease,
                ],
                onSelectedIndex: (index) {
                  // 들여쓰기 내여쓰기 4 ,-4 만큼 padding값을 넣어준다.
                  controller.setPaddingLeft((index == 0) ? -4 : 4);
                },
              ),
              const SizedBox(height: 8),
              VulcanXSvgButtonSelector(
                disabled: controller.rxDisabledTextbox.value,
                width: 148,
                isButtonMode: true, // 여러 번 누를 수 있도록 설정
                //첫줄 들여쓰기
                label: 'line_indent'.tr,
                svgAssets: [
                  CommonAssets.icon.formatIndentDecrease,
                  CommonAssets.icon.formatIndentIncrease,
                ],
                onSelectedIndex: (index) {
                  controller.applyTextIndent((index == 0) ? -4 : 4);
                },
              ),
              const SizedBox(height: 8),
              Obx(
                () => CounterWidget(
                  //줄 간격
                  text: 'line_spacing'.tr,
                  minValue: 0.0,
                  focusNode: controller.focusLineSpacingNode,
                  initialValue: controller.rxLineSpacing.value,
                  unitConfig: const UnitConfig(
                    unit: "",
                    stepValue: 0.01,
                    decimalPlaces: 2,
                  ),
                  inputFormatters: [
                    // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (value) => controller.setLineSpacing(value),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => CounterWidget(
                  //단락 앞
                  text: 'paragraph_spacing_before'.tr,
                  minValue: 0,
                  focusNode: controller.focusLinePaddingTopNode,
                  initialValue: controller.rxLinePaddingTop.value,
                  inputFormatters: [
                    // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  unit: 'px',
                  onChanged: (value) => controller.applyLinePadding(
                      PaddingType.top, value.replacePX()),
                ),
              ),
              const SizedBox(height: 8),
              VulcanXOutlinedButton(
                width: double.infinity,
                onPressed: () => controller.removeLineAndPadding(),
                // 줄 간격, 문단 앞 초기화
                child: Text('reset_line_spacing_and_padding'.tr),
              ),
            ],
            // const SizedBox(height: 8),
            // Obx(
            //   () => CounterWidget(
            //     //단락 뒤
            //     text: 'paragraph_spacing_after'.tr,
            //     minValue: 0,
            //     focusNode: controller.focusLinePaddingBottomNode,
            //     initialValue: controller.rxLinePaddingBottom.value,
            //     unit: 'px',
            //     onChanged: (value) => controller.applyPadding(
            //         PaddingType.bottom, value.replaceAll('px', '')),
            //   ),
            // ),
            const SizedBox(height: 8),

            Obx(
              () => CounterWidget(
                //글자 간격
                text: 'letter_spacing'.tr,
                focusNode: controller.focusLetterSpacingNode,
                initialValue: controller.rxLetterSpacing.value,
                minValue: -2,
                unit: 'px',
                inputFormatters: [
                  // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (value) => controller.setLetterSpacing(value),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => CounterWidget(
                // 장평
                text: 'font_width'.tr,
                focusNode: controller.focusFontWidthNode,
                minValue: 50,
                maxValue: 200,
                unit: '%',
                initialValue: controller.rxFontWidth.value,
                inputFormatters: [
                  // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (value) {
                  controller.applyFontWidth(value);
                },
              ),
            ),
            const SizedBox(height: 8),
            VulcanXSvgButtonSelector(
              disabled: controller.rxDisabledTextbox.value,
              width: 148,
              isButtonMode: true, // 여러 번 누를 수 있도록 설정
              //모양 복사
              label: 'copy_shape'.tr,
              svgAssets: [
                CommonAssets.icon.contentCopy,
                CommonAssets.icon.editSquare,
              ],
              onSelectedIndex: (index) {
                if (index == 0) {
                  controller.copySelectedStyle();
                } else {
                  controller.pasteStyleToSelection();
                }
              },
            ),
            // const SizedBox(height: 8),
            // VulcanXSvgButtonSelector(
            //   width: 148,
            //   //다단
            //   label: 'multiple_steps'.tr,
            //   svgAssets: [
            //     CommonAssets.icon.block,
            //     CommonAssets.icon.viewColumn2,
            //     CommonAssets.icon.viewColumn3,
            //   ],
            //   onSelectedIndex: (index) {},
            // ),
            // const SizedBox(height: 8),
            // VulcanXLabelTextField(
            //     unit: 'px',
            //     //단 간격
            //     label: 'short_interval'.tr),
            // const SizedBox(height: 8),
            // VulcanXSvgButtonSelector(
            //   width: 148,
            //   //문단 방향
            //   label: 'direction_paragraphs'.tr,
            //   svgAssets: [
            //     CommonAssets.icon.formatImageLeft,
            //     CommonAssets.icon.formatImageRight,
            //   ],
            //   onSelectedIndex: (index) {},
            // ),
          ],
        ));
  }
}
