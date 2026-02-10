import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SizeItem extends StatelessWidget with EditorEventbus {
  final double? textFieldWidth;
  final String? type;
  final EdgeInsetsGeometry? padding;
  final FocusNode? focusWidthNode;
  final FocusNode? focusHeightNode;
  final Widget? prefixWidthIcon;
  final Widget? prefixHeightIcon;

  SizeItem(
      {super.key,
      this.padding,
      this.type,
      this.focusWidthNode,
      this.focusHeightNode,
      this.prefixWidthIcon,
      this.prefixHeightIcon,
      this.textFieldWidth});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding ?? const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => VulcanXLabelTextField(
                  textFieldWidth: textFieldWidth ?? 150,
                  initialValue: controller.rxWidth.value.toString(),
                  unit: 'px',
                  //너비
                  label: 'width'.tr,
                  inputFormatters: [
                    // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  focusNode: focusWidthNode ?? controller.focusWidthNode,
                  prefixCenterIcon: prefixWidthIcon,
                  onChanged: (value) =>
                      controller.setWidth(value: value, type: type),
                )),
            const SizedBox(height: 8),
            Obx(() => VulcanXLabelTextField(
                  textFieldWidth: textFieldWidth ?? 150,
                  initialValue: controller.rxHeight.value.toString(),
                  unit: 'px',
                  //높이
                  label: 'height'.tr,
                  inputFormatters: [
                    // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  focusNode: focusHeightNode ?? controller.focusHeightNode,
                  prefixCenterIcon: prefixHeightIcon,
                  onChanged: (value) =>
                      controller.setHeight(value: value, type: type),
                )),
            const SizedBox(height: 8),
            if (type == 'image') ...[
              VulcanXOutlinedButton.icon(
                  width: double.infinity,
                  onPressed: () => controller.applyNaturalImageSize(),
                  icon: CommonAssets.icon.replay.svg(),
                  //기본 스타일
                  child: Text('original_style'.tr)),
              const SizedBox(height: 8),
            ],
          ],
        ));
  }
}
