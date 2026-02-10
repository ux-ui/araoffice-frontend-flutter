import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BackgroundImageSizeItem extends StatelessWidget with EditorEventbus {
  final double? textFieldWidth;
  final String? type;
  final EdgeInsetsGeometry? padding;
  final FocusNode? focusWidthNode;
  final FocusNode? focusHeightNode;
  final Widget? prefixWidthIcon;
  final Widget? prefixHeightIcon;

  BackgroundImageSizeItem(
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
    final isTypeBody = (type == 'body');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => VulcanXLabelTextField(
              textFieldWidth: textFieldWidth ?? 150,
              initialValue: isTypeBody
                  ? controller.rxBodyBackImageWidth.value.toString()
                  : controller.rxBackgroundWidth.value.toString(),
              unit: 'px',
              //너비
              label: 'width'.tr,
              focusNode: focusWidthNode ?? controller.focusBackgroundWidthNode,
              prefixCenterIcon: prefixWidthIcon,
              inputFormatters: [
                // 숫자와 소숫점만 입력
                // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: (value) {
                if (value.isEmpty) return;

                if (isTypeBody) {
                  controller.rxBodyBackImageWidth.value = value;
                  controller.setBodyBackImageSize(
                      value, controller.rxBodyBackImageHeight.value.toString());
                } else {
                  controller.rxBackgroundWidth.value = value;
                  controller.setBackgroundSize(
                      value, controller.rxBackgroundHeight.value.toString());
                }
                controller.updatePageContent();
              },
            )),
        const SizedBox(height: 8),
        Obx(() => VulcanXLabelTextField(
            textFieldWidth: textFieldWidth ?? 150,
            initialValue: isTypeBody
                ? controller.rxBodyBackImageHeight.value.toString()
                : controller.rxBackgroundHeight.value.toString(),
            unit: 'px',
            //높이
            label: 'height'.tr,
            focusNode: focusHeightNode ?? controller.focusBackgroundHeightNode,
            prefixCenterIcon: prefixHeightIcon,
            inputFormatters: [
              // 숫자만 입력
              // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            onChanged: (value) {
              if (value.isEmpty) return;

              if (isTypeBody) {
                controller.rxBodyBackImageHeight.value = value;
                controller.setBodyBackImageSize(
                    controller.rxBodyBackImageWidth.value.toString(), value);
              } else {
                controller.rxBackgroundHeight.value = value;
                controller.setBackgroundSize(
                    controller.rxBackgroundWidth.value.toString(), value);
              }
              controller.updatePageContent();
            })),
        const SizedBox(height: 8),
      ],
    );
  }
}
