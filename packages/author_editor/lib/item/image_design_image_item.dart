import 'package:app_ui/app_ui.dart';
import 'package:author_editor/extension/assets_image_extension.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';
import '../vulcan_editor_eventbus.dart';
import 'items.dart';

class ImageDesignImageItem extends StatelessWidget with EditorEventbus {
  ImageDesignImageItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          VulcanXSwitch(
              label: '캡션 표시',
              value: controller.rxShowCaption.value,
              onChanged: (value) {
                if (value) {
                  controller.insertCaption('캡션을 입력해주세요');
                } else {
                  controller.removeCaption();
                }
              }),
          const SizedBox(height: 16),
          VulcanXSvgButtonSelector(
            label: '캡션 위치',
            width: 148,
            height: 40,
            svgAssets: [
              CommonAssets.icon.captionBelow,
              CommonAssets.icon.captionAbove,
            ],
            onSelectedIndex: (index) {
              if (index == 0) {
                controller.setCaptionPosition('bottom');
              } else {
                controller.setCaptionPosition('top');
              }
            },
          ),
          const SizedBox(height: 16),
          // VulcanXSvgButtonSelector(
          //   label: '캡션 정렬',
          //   width: 148,
          //   height: 40,
          //   svgAssets: [
          //     CommonAssets.icon.formatAlignLeft,
          //     CommonAssets.icon.formatAlignCenter,
          //     CommonAssets.icon.formatAlignRight,
          //     CommonAssets.icon.formatAlignJustify,
          //   ],
          //   onSelectedIndex: (index) {},
          // ),
          // const VulcanXDivider(space: 16),
          VulcanXInkWellSelector(
            onTaps: List.generate(
              12,
              (index) => () => controller.setImageStyle(index + 1),
            ),
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: List.generate(
              12,
              (index) => Assets.image
                  .fromNumberedImage('image_effect', index + 1)
                  .image(),
            ),
          ),
          const SizedBox(height: 16.0),
          VulcanXOutlinedButton.icon(
              width: double.infinity,
              onPressed: () => controller.removeAllStyle(),
              icon: CommonAssets.icon.replay.svg(),
              //기본 스타일
              child: Text('default_style'.tr)),
          const SizedBox(height: 16.0),
          ImagePopupMenuItem(
            backgroundColor: Colors.white,
            type: ObjectType.image,
            type2: ObjectType.changeImage,
            iconPath: 'change_image'.tr,
            onChanged: () {},
            onCanceled: () => controller.updatePageContent(),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
