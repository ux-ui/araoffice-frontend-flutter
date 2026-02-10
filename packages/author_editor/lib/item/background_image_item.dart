import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';
import 'items.dart';

class BackgroundImageItem extends StatelessWidget with EditorEventbus {
  final ObjectType? type;
  final ObjectType? backgroundType;
  BackgroundImageItem({super.key, this.type, this.backgroundType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => ImagePopupMenuItem(
              //배경 이미지
              label: 'background_image'.tr,
              backgroundColor: Colors.white,
              type: backgroundType ?? ObjectType.backgroundImage,
              iconPath: (type == ObjectType.table)
                  ? controller.rxTableBackImage.value
                  : (type == ObjectType.body)
                      ? controller.rxBodyBackImageUrl.value
                      : controller.rxObjectBackImage.value,
              type2: type,
              // backgroundType: backgroundType,
              onChanged: () {},
              onCanceled: () => controller.updatePageContent(),
              prefixIcon: IconButton(
                onPressed: () {
                  // backgroundType == ObjectType.bodyBackgroundImage
                  //     ? controller.setBodyBackImageUrl('')
                  //     : controller.setObjectBackImageUrl('', type);
                  debugPrint('backgroundType: $backgroundType');
                  (backgroundType == ObjectType.backgroundImage)
                      ? controller.setObjectBackImage(
                          path: '', type: backgroundType?.value)
                      : (backgroundType == ObjectType.bodyBackgroundImage)
                          ? controller.setBodyBackImageUrl('')
                          : (backgroundType == ObjectType.changeImage)
                              ? controller.changeImageSource('')
                              : controller.insertImage(
                                  '',
                                  backgroundType?.value ??
                                      ObjectType.image.value);
                },
                icon: const Icon(Icons.refresh, size: 16, color: Colors.grey),
              ),
            )),
        const SizedBox(height: 8),
        Obx(() => VulcanXSvgButtonSelector<BackgroundRepeatType>(
            width: 148,
            //반복
            label: 'repeat'.tr,
            initialEnum: (type == ObjectType.table)
                ? controller.rxTableBackRepeat.value
                : (type == ObjectType.body)
                    ? BackgroundRepeatType.fromString(
                        controller.rxBodyBackImageRepeat.value)
                    : controller.rxObjectBackRepeat.value,
            enumValues: BackgroundRepeatType.values,
            svgAssets: [
              CommonAssets.icon.block,
              CommonAssets.icon.flexWrap,
              CommonAssets.icon.flexDirectionHor,
              CommonAssets.icon.flexDirection,
            ],
            onSelectedEnum: (repeat) {
              controller.updatePageContent();
              if (type == ObjectType.body) {
                controller.setBodyBackImageRepeat(repeat!.name);
              } else {
                controller.setObjectBackRepeat(repeat: repeat!);
              }
            })),
        const SizedBox(height: 8),
        BackgroundImageSizeItem(type: type?.value),
        PositionItem(type: type?.value),
      ],
    );
  }
}
