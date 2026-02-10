import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';

class TextBoxStyleListItem extends StatelessWidget with EditorEventbus {
  TextBoxStyleListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => VulcanXSvgButtonSelector(
                  disabled: controller.rxVirtualListDepth.value != 0,
                  width: 148,
                  //목록 모양
                  label: 'list_shape'.tr,
                  initialIndex: controller.rxListStyleIndex.value,
                  svgAssets: [
                    CommonAssets.icon.formatListBulletedSvg,
                    CommonAssets.icon.formatListNumbered,
                    CommonAssets.icon.cancel,
                  ],
                  onSelectedIndex: (index) => controller.disableList(index!),
                )),
            const SizedBox(height: 8),
            Obx(() => !controller.rxDisabledUlList.value
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 점 목록
                          Text('list_dot_style'.tr),
                          SizedBox(
                            width: 148,
                            child: VulcanXDropdown<UlStyleType>(
                              disabled: !controller.rxDisabledTextbox.value
                                  ? false
                                  : true,
                              height: 40.0,
                              enumItems: UlStyleType.values,
                              onChanged: (UlStyleType? newValue) => controller
                                  .applyList(newValue!.translationKey),
                              hintText: '',
                              value: controller.rxUlStyleType.value,
                              displayStringForOption: (type) => type.name,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  )),
            Obx(() => !controller.rxDisabledOlList.value
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 점 목록
                          Text('list_number_style'.tr),
                          SizedBox(
                            width: 148,
                            child: VulcanXDropdown<OlStyleType>(
                              disabled: !controller.rxDisabledTextbox.value
                                  ? false
                                  : true,
                              height: 40.0,
                              enumItems: OlStyleType.values,
                              onChanged: (OlStyleType? newValue) => controller
                                  .applyList(newValue!.translationKey),
                              hintText: '',
                              value: controller.rxOlStyleType.value,
                              displayStringForOption: (type) => type.name,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  )),
            Obx(
              () => VulcanXSvgButtonSelector(
                disabled: !controller.rxCanIndentList.value,
                width: 148,
                isButtonMode: true, // 여러 번 누를 수 있도록 설정
                //목록 들여쓰기
                label: 'indent'.tr,
                svgAssets: [
                  CommonAssets.icon.formatIndentDecrease,
                  CommonAssets.icon.formatIndentIncrease,
                ],
                onSelectedIndex: (index) {
                  // 들여쓰기 내여쓰기 4 ,-4 만큼 padding값을 넣어준다.
                  controller.setIndentList(index!);
                },
              ),
            ),
            // TODO 가상 리스트 스타일과 중복되는 기능으로 추후 삭제 예정
            //const SizedBox(height: 8),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     // 목록 클래스 스타일
            //     Text('list_class_style'.tr),
            //     SizedBox(
            //       width: 148,
            //       child: VulcanXDropdown<ListStyleClassType>(
            //         height: 40.0,
            //         enumItems: ListStyleClassType.values,
            //         onChanged: (ListStyleClassType? newValue) =>
            //             controller.setListClass(newValue!.index),
            //         hintText: '',
            //         value: ListStyleClassType.styleNone,
            //         displayStringForOption: (type) => type.name,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ));
  }
}
