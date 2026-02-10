import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enum/text_box_type.dart';
import '../vulcan_editor_eventbus.dart';

class TextBoxItem extends StatelessWidget with EditorEventbus {
  TextBoxItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Wrap(
        runSpacing: 10.0,
        spacing: 10.0,
        children: [
          VulcanXRoundedContainer.grey(
            width: 84,
            height: 84,
            child: Center(
                child: VulcanXSvgLabelIconWidget(
                    icon: CommonAssets.icon.textboxScrollIcon,
                    // 스크롤링
                    label: 'scrolling'.tr)),
            onTap: () =>
                controller.insertTextbox(TextBoxType.defaultType.value),
          ),
          VulcanXRoundedContainer.grey(
            width: 84,
            height: 84,
            child: Center(
                child: VulcanXSvgLabelIconWidget(
                    icon: CommonAssets.icon.textboxCenterIcon,
                    // 가운데 정렬
                    label: 'center_align'.tr)),
            onTap: () => controller.insertTextbox(TextBoxType.center.value),
          ),
          VulcanXRoundedContainer.grey(
            width: 84,
            height: 84,
            child: Center(
                child: VulcanXSvgLabelIconWidget(
                    icon: CommonAssets.icon.textboxAutofitIcon,
                    // 자동 맞춤
                    label: 'auto_align'.tr)),
            onTap: () => controller.insertTextbox(TextBoxType.autofit.value),
          ),
          VulcanXRoundedContainer.grey(
            width: 84,
            height: 84,
            child: Center(
                child: VulcanXSvgLabelIconWidget(
                    icon: CommonAssets.icon.textboxVertical,
                    // 스크롤링(세로)
                    label: 'vertical_scroll'.tr)),
            onTap: () => controller.insertTextbox(TextBoxType.vertical.value),
          ),
          VulcanXRoundedContainer.grey(
            width: 84,
            height: 84,
            child: Center(
                child: VulcanXSvgLabelIconWidget(
                    icon: CommonAssets.icon.textboxVerticalCenter,
                    // 가운데 정렬(세로)
                    label: 'vertical_center_align'.tr)),
            onTap: () =>
                controller.insertTextbox(TextBoxType.verticalCenter.value),
          ),
          VulcanXRoundedContainer.grey(
            width: 84,
            height: 84,
            child: Center(
                child: VulcanXSvgLabelIconWidget(
                    icon: CommonAssets.icon.textboxVerticalAutofit,
                    // 자동맞춤(세로)
                    label: 'vertical_auto_align'.tr)),
            onTap: () =>
                controller.insertTextbox(TextBoxType.verticalAutofit.value),
          ),
        ],
      ),
    );
  }
}
