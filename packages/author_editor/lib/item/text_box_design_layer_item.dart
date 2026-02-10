import 'package:app_ui/app_ui.dart';
import 'package:author_editor/enum/object_type.dart';
import 'package:author_editor/extension/assets_image_extension.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'items.dart';

class TextBoxDesignLayerItem extends StatelessWidget with EditorEventbus {
  TextBoxDesignLayerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => VulcanXLabelTextField(
                  textFieldWidth: 113,
                  initialValue: controller.rxOpacity.value,
                  unit: '%',
                  //투명도
                  label: 'opacity'.tr,
                  inputFormatters: [
                    // 숫자만 입력
                    // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (value) => controller.setOpacity(value),
                )),
            const SizedBox(height: 8),
            BackgroundItem(),
            const SizedBox(height: 8),
            BackgroundImageItem(
              backgroundType: ObjectType.backgroundImage,
            ),
            const SizedBox(height: 8),
            Obx(() => VulcanXLabelTextField(
                  textFieldWidth: 113,
                  initialValue: controller.rxOpacity.value,
                  unit: 'px',
                  //둥근 모서리
                  label: 'border_radius'.tr,
                  inputFormatters: [
                    // 숫자만 입력
                    // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (value) => controller.setBorderRadius(value),
                )),
            const SizedBox(height: 16),
            BorderItem(),
            const SizedBox(height: 16),
            _buildTextBoxStyle(context),
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
                child: Text('default_style'.tr)),
          ],
        ));
  }

  Widget _buildTextBoxStyle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        VulcanXText(
            //글상자 스타일
            text: 'text_box_style'.tr,
            suffixIcon: const Icon(Icons.expand_more_rounded, size: 16.0)),
        const SizedBox(height: 8),
        VulcanXInkWellSelector(
          onTaps: List.generate(
            25,
            (index) => () => controller.setTextBoxBGStyle(index + 1),
          ),
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: List.generate(
            25,
            (index) => Assets.image
                .fromNumberedImage('text_box_style', index + 1)
                .image(),
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
