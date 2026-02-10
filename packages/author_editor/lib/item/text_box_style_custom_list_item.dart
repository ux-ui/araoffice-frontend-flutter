import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';

class TextBoxStyleCustomListItem extends StatelessWidget with EditorEventbus {
  TextBoxStyleCustomListItem({super.key});

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
                // 목록 클래스 스타일
                Text('style'.tr),
                Obx(() => SizedBox(
                      width: 148,
                      child: VulcanXDropdown<ListStyleClassType>(
                        height: 40.0,
                        enumItems: ListStyleClassType.values,
                        onChanged: (ListStyleClassType? newValue) => controller
                            .setVirtualListDepth(newValue!.vlistValue),
                        hintText: '',
                        value: controller.rxVirtualListDepth.value == 0
                            ? ListStyleClassType.styleNone
                            : ListStyleClassType.fromVlistValue(
                                controller.rxVirtualListDepthType.value),
                        displayStringForOption: (type) => type.name,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Obx(
              () => VulcanXSvgButtonSelector(
                disabled: controller.rxVirtualListDepth.value == 0,
                width: 148,
                isButtonMode: true, // 여러 번 누를 수 있도록 설정
                //목록 깊이
                label: 'list_depth'.tr,
                svgAssets: [
                  CommonAssets.icon.formatIndentDecrease,
                  CommonAssets.icon.formatIndentIncrease,
                ],
                onSelectedIndex: (index) {
                  // 들여쓰기 내여쓰기 4 ,-4 만큼 padding값을 넣어준다.
                  controller.setVirtualListDepthToggle(index!);
                },
              ),
            ),
            const SizedBox(height: 8),
            // 목록 번호 업데이트 버튼 추가
            Obx(() => VulcanXElevatedButton.primary(
                  width: double.infinity,
                  onPressed: (!controller.rxHasVirtualList.value)
                      ? null
                      : () => controller.triggerUpdateListNumbering(
                          controller.rxVirtualListDepthType.value),
                  child: Text('list_numbering_update'.tr),
                )),
          ],
        ));
  }
}
