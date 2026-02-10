import 'package:app_ui/app_ui.dart';
import 'package:author_editor/enum/zindex_type.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enum/text_align_both_type.dart';
import '../enum/text_align_size_type.dart';

class StyleAlignItem extends StatelessWidget with EditorEventbus {
  final bool isOnlyZindex;
  StyleAlignItem({super.key, this.isOnlyZindex = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isOnlyZindex) ...[
              VulcanXSvgButtonSelector(
                enumValues: TextAlignBothType.values,
                svgAssets: [
                  CommonAssets.icon.alignHorizontalLeft,
                  CommonAssets.icon.alignHorizontalCenter,
                  CommonAssets.icon.alignHorizontalRight,
                  CommonAssets.icon.alignVerticalTop,
                  CommonAssets.icon.alignVerticalCenter,
                  CommonAssets.icon.alignVerticalBottom,
                ],
                onSelectedEnum: (type) => controller.alignSelectedNodes(type!),
              ),
              const SizedBox(height: 8),

              VulcanXSvgButtonSelector(
                width: 148,
                //크기
                label: 'size'.tr,
                enumValues: TextAlignSizeType.values,
                svgAssets: [
                  CommonAssets.icon.horizontalDistribute,
                  CommonAssets.icon.verticalDistribute,
                  CommonAssets.icon.browse,
                ],
                onSelectedEnum: (type) =>
                    controller.matchSizeOfSelectedNodes(type!),
              ),
              //const SizedBox(height: 8),
              // VulcanXSvgButtonSelector(
              //   width: 148,
              //   isButtonMode: true, // 여러 번 누를 수 있도록 설정
              //   //간격
              //   //객체 3개 이상 선택시 객체간 간격을 동일하게 위치 조정
              //   label: 'spacing'.tr,
              //   svgAssets: [
              //     CommonAssets.icon.formatLetterSpacing,
              //     CommonAssets.icon.formatLineSpacing,
              //   ],
              //   onSelectedIndex: (index) {
              //     controller.matchSizeOfSelectedNodes((index == 0) ? 4 : -4);
              //   },
              // ),
              const SizedBox(height: 8),
            ],
            VulcanXSvgButtonSelector(
              isButtonMode: true,
              width: 148,
              //순서
              label: 'zindex'.tr,
              enumValues: ZindexType.values,
              svgAssets: [
                CommonAssets.icon.moveForward,
                CommonAssets.icon.moveNext,
                CommonAssets.icon.moveFront,
                CommonAssets.icon.moveBack,
              ],
              onSelectedEnum: (option) => controller.setZindex(option!),
            ),
            // const SizedBox(height: 8),
            // VulcanXSvgButtonSelector(
            //   width: 148,
            //   //그룹
            //   label: 'group'.tr,
            //   svgAssets: [
            //     CommonAssets.icon.unitGroup,
            //     CommonAssets.icon.unitUngroup,
            //   ],
            //   onSelectedIndex: (index) {},
            // ),
          ],
        ));
  }
}
