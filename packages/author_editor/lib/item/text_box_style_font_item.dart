import 'package:app_ui/app_ui.dart';
import 'package:author_editor/enum/text_position_type.dart';
import 'package:author_editor/extension/assets_image_extension.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../data/vulcan_font_data.dart';
import '../enum/heading_type.dart';
import '../enum/text_decoration_type.dart';

class TextBoxStyleFontItem extends StatelessWidget with EditorEventbus {
  final bool? enabledHeading;
  final bool? enabledFontEffect;
  TextBoxStyleFontItem({
    super.key,
    this.enabledHeading = true,
    this.enabledFontEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (enabledHeading == true) ...[
              Obx(
                () => VulcanXSvgButtonSelector<HeadingType>(
                  disabled: controller.rxDisabledTextbox.value,
                  enumValues: HeadingType.values,
                  svgAssets: [
                    CommonAssets.icon.iconH1,
                    CommonAssets.icon.iconH2,
                    CommonAssets.icon.iconH3,
                    CommonAssets.icon.iconH4,
                    CommonAssets.icon.iconH5,
                    CommonAssets.icon.iconH6,
                  ],
                  initialEnum: controller.rxHeading.value,
                  onSelectedEnum: (type) => controller
                      .setParagraphTag((type != null) ? type.name : 'p'),
                ),
              ),
              const SizedBox(height: 8)
            ],
            VulcanXDropdown<VulcanFontData>(
              value: controller.rxFontData.value,
              enumItems: controller.installedFonts.fonts,
              onChanged: (value) => controller.setFontFamily(value!),
              hintText: '',
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('font_size'.tr),

                //font size
                Obx(
                  () => CounterWidget(
                    unit: 'pt',
                    initialValue: controller.rxFontSize.value,
                    focusNode: controller.focusFontSizeNode,
                    inputFormatters: [
                      // 숫자만 입력
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      controller.setFontSize(value);
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            // bold, itealic, underline, overline, strikethrough
            Obx(
              () => VulcanXSvgButtonSelector<TextDecorationType>(
                  multiSelect: true,
                  enumValues: TextDecorationType.values,
                  svgAssets: [
                    CommonAssets.icon.formatBold,
                    CommonAssets.icon.formatItalic,
                    CommonAssets.icon.formatUnderlined,
                    CommonAssets.icon.formatOverlined,
                    CommonAssets.icon.formatStrikethrough,
                  ],
                  initialEnums: controller.rxTextDecorations.toList(),
                  onMultiSelectedEnum: (types) =>
                      controller.textDecorationToggle(types)),
            ),
            const SizedBox(height: 8),
            Obx(() => VulcanXSvgButtonSelector<TextPositionType>(
                  disabled: controller.rxDisabledTextbox.value,
                  initialEnum: controller.rxTextPosition.value,
                  enumValues: TextPositionType.values,
                  svgAssets: [
                    CommonAssets.icon.subscript,
                    CommonAssets.icon.superscript,
                    // CommonAssets.icon.subscriptAlpha,
                    // CommonAssets.icon.superscriptAlpha,
                  ],
                  onSelectedEnum: (type) {
                    controller.setTextPosition(type);
                  },
                )),
            const SizedBox(height: 8),
            VulcanXColorPickerWidget(
              label: 'font_color'.tr,
              initialColor: controller.rxTextColor.value,
              onColorChanged: (color) => controller.setTextColor(color),
              // onConfirm: () => controller.focus(),
              onConfirm: () => controller.updatePageContent(),
            ),
            const SizedBox(height: 8),
            VulcanXColorPickerWidget(
              label: 'font_background_color'.tr,
              initialColor: controller.rxFontBackColor.value,
              onColorChanged: (color) => controller.setFontBackColor(color),
              // onConfirm: () => controller.focus(),
              onConfirm: () => controller.updatePageContent(),
            ),
            const SizedBox(height: 8),
            if (enabledFontEffect == true) ...[
              _buildFontEffect(context),
              const SizedBox(height: 8),
            ],
            const VulcanXDivider(),
            // const SizedBox(height: 16),
            // PaddingItem(title: 'padding'.tr),
            // const SizedBox(height: 16),
            // PaddingItem(title: 'margin'.tr, type: SpacingType.margin),
            const SizedBox(height: 16),
            VulcanXOutlinedButton.icon(
                width: double.infinity,
                onPressed: () => controller.removeAllStyle(),
                icon: CommonAssets.icon.replay.svg(),
                child: Text('default_style'.tr)),
          ],
        ));
  }

  Widget _buildFontEffect(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        VulcanXText(
            //글꼴 효과
            text: 'font_effect'.tr,
            suffixIcon: const Icon(Icons.expand_more_rounded, size: 16.0)),
        const SizedBox(height: 8),
        VulcanXInkWellSelector(
          onTaps: List.generate(
            17,
            (index) => () => controller.setTextStyle(index + 1),
          ),
          spacing: 7,
          runSpacing: 7,
          alignment: WrapAlignment.start,
          children: List.generate(
            17,
            (index) => Assets.image
                .fromNumberedImage('font_effect', index + 1)
                .image(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
