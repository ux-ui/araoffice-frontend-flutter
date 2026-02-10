import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BackgroundItem extends StatelessWidget with EditorEventbus {
  final String? type;
  BackgroundItem({super.key, this.type});

  @override
  Widget build(BuildContext context) {
    final colorPickerKey = GlobalKey<PopupMenuButtonState>();
    // final colorPicker = VulcanXColorPickerWidget(
    //   popupKey: colorPickerKey,
    //   label: 'background_color'.tr,
    //   initialColor: (type == 'table')
    //       ? controller.rxTableBackColor.value
    //       : (type == 'body')
    //           ? controller.rxBodyBackColor.value
    //           : controller.rxObjectBackColor.value,
    //   onColorChanged: (Color color) {
    //     if (type == 'body') {
    //       controller.setBodyBackColor(color);
    //     } else {
    //       controller.setObjectBackColor(color: color, type: type);
    //     }
    //   },
    //   onConfirm: () => controller.updatePageContent(),
    //   // onCanceled: () => controller.updatePageContent(),
    // );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        VulcanXColorPickerWidget(
          // popupKey: colorPickerKey,
          label: 'background_color'.tr,
          initialColor: (type == 'table')
              ? controller.rxTableBackColor.value
              : (type == 'body')
                  ? controller.rxBodyBackColor.value
                  : controller.rxObjectBackColor.value,
          onColorChanged: (Color color) {
            if (type == 'body') {
              controller.setBodyBackColor(color);
            } else {
              controller.setObjectBackColor(color: color, type: type);
            }
          },
          onConfirm: () => controller.updatePageContent(),
          onCanceled: () => controller.updatePageContent(),
        ),
      ],
    );
  }
}
