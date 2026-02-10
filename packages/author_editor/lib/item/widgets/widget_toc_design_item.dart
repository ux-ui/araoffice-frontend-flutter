import 'package:app_ui/app_ui.dart';
import 'package:author_editor/enum/project_auth_type.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../vulcan_editor_eventbus.dart';
import '../items.dart';

class WidgetTocDesignItem extends StatelessWidget with EditorEventbus {
  WidgetTocDesignItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.documentState.rxPageCurrent.value?.type !=
              'toc_sub') ...[
            VulcanXElevatedButton(
              width: double.infinity,
              onPressed: () => controller.updateTreeWidgetTocFromJson(
                (ProjectAuthType.publicLink ==
                            controller
                                .documentState.rxProjectSharePermission.value ||
                        ProjectAuthType.userLink ==
                            controller
                                .documentState.rxProjectSharePermission.value)
                    ? () => controller.wsManager.sendPauseState(
                          controller.documentState.rxProjectId.value,
                          true,
                        )
                    : null,
                (ProjectAuthType.publicLink ==
                            controller
                                .documentState.rxProjectSharePermission.value ||
                        ProjectAuthType.userLink ==
                            controller
                                .documentState.rxProjectSharePermission.value)
                    ? () => controller.wsManager.sendPauseState(
                          controller.documentState.rxProjectId.value,
                          false,
                        )
                    : null,
              ),
              // TreeWidget에서 페이지 이름으로 목차 자동 업데이트
              child: Text('toc_page_title_update'.tr),
            ),
            const SizedBox(height: 16),
            VulcanXElevatedButton(
              width: double.infinity,
              onPressed: () {
                (ProjectAuthType.publicLink ==
                            controller
                                .documentState.rxProjectSharePermission.value ||
                        ProjectAuthType.userLink ==
                            controller
                                .documentState.rxProjectSharePermission.value)
                    ? controller.wsManager.sendPauseState(
                        controller.documentState.rxProjectId.value,
                        true,
                      )
                    : null;
                controller.triggerUpdateToc('htag');
                Future.delayed(const Duration(milliseconds: 1500), () {
                  (ProjectAuthType.publicLink ==
                              controller.documentState.rxProjectSharePermission
                                  .value ||
                          ProjectAuthType.userLink ==
                              controller
                                  .documentState.rxProjectSharePermission.value)
                      ? controller.wsManager.sendPauseState(
                          controller.documentState.rxProjectId.value,
                          false,
                        )
                      : null;
                });
              },

              // 페이지 안에 (H1, H2, H3) 태그 스타일에 따라 목차 이름 자동 업데이트
              child: Text('toc_h_style_update'.tr),
            ),
            const SizedBox(height: 16),
            VulcanXElevatedButton(
              width: double.infinity,
              onPressed: () {
                (ProjectAuthType.publicLink ==
                            controller
                                .documentState.rxProjectSharePermission.value ||
                        ProjectAuthType.userLink ==
                            controller
                                .documentState.rxProjectSharePermission.value)
                    ? controller.wsManager.sendPauseState(
                        controller.documentState.rxProjectId.value,
                        true,
                      )
                    : null;
                controller.triggerUpdateToc('vlistDepth');
                Future.delayed(const Duration(milliseconds: 1500), () {
                  (ProjectAuthType.publicLink ==
                              controller.documentState.rxProjectSharePermission
                                  .value ||
                          ProjectAuthType.userLink ==
                              controller
                                  .documentState.rxProjectSharePermission.value)
                      ? controller.wsManager.sendPauseState(
                          controller.documentState.rxProjectId.value,
                          false,
                        )
                      : null;
                });
              },

              // 페이지 안에 스타일에 따라 목차 이름 자동 업데이트
              child: Text('toc_vlist_style_update'.tr),
            ),
            const SizedBox(height: 16),
          ],
          Obx(
            () => VulcanXSwitch(
              label: 'has_toc_title'.tr,
              value: controller.rxHasTocTitle.value,
              onChanged: (value) => controller.setHasTocTitle(value),
            ),
          ),
          // // 목차 항목 새로운 설정
          // VulcanXText(
          //   text: 'toc_items'.tr,
          //   style: const TextStyle(fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 16),

          // // 목차 항목 수 설정
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     // 선 모양 크기
          //     Text('item_count'.tr),
          //     Obx(
          //       () => CounterWidget(
          //         initialValue: controller.rxTocItemCount.value.toString(),
          //         inputFormatters: [
          //           // 숫자만 입력
          //           FilteringTextInputFormatter.allow(
          //               RegExp(r'^\d*\.?\d*$')),
          //         ],
          //         onChanged: (value) {
          //           int? size = int.tryParse(value);
          //           controller.setTocItemCount(size ?? 1);
          //         },
          //       ),
          //     )
          //   ],
          // ),
          // const SizedBox(height: 16),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     // 목차 유형
          //     Text('list_type'.tr),
          //     SizedBox(
          //       width: 148,
          //       child: Obx(() {
          //         return VulcanXDropdown<UlOlType>(
          //           disabled: controller.rxDisabledTextbox.value ? false : true,
          //           height: 40.0,
          //           enumItems: UlOlType.values,
          //           onChanged: (UlOlType? newValue) {
          //             if (newValue == null) return;
          //             controller.setTocListType(newValue.translationKey);
          //           },
          //           hintText: '',
          //           value: UlOlType.fromTranslationKey(
          //               controller.rxTocListType.value),
          //           displayStringForOption: (type) => type.name,
          //         );
          //       }),
          //     ),
          //   ],
          // ),
          // // 목록 스타일 설정 (목록 유형이 'none'이 아닐 때만 표시)
          // Obx(() {
          //   final listType = controller.rxTocListType.value;

          //   // 목록 유형이 없거나 'none'인 경우 표시하지 않음
          //   if (listType.isEmpty || listType == 'none') {
          //     return const SizedBox.shrink();
          //   }

          //   return Padding(
          //     padding: const EdgeInsets.only(top: 16),
          //     child: Row(
          //       children: [
          //         Expanded(
          //           child: VulcanXText(
          //             text: 'list_style'.tr,
          //           ),
          //         ),
          //         SizedBox(
          //           width: 148,
          //           child: listType == 'ul'
          //               ? VulcanXDropdown<UlStyleType>(
          //                   disabled: controller.rxDisabledTextbox.value
          //                       ? false
          //                       : true,
          //                   height: 40.0,
          //                   enumItems: UlStyleType.values,
          //                   onChanged: (UlStyleType? newValue) {
          //                     if (newValue == null) return;
          //                     controller
          //                         .setTocListStyleType(newValue.translationKey);
          //                   },
          //                   hintText: '',
          //                   value: UlStyleType.fromTranslationKey(
          //                       controller.rxTocListStyleType.value),
          //                   displayStringForOption: (type) => type.name,
          //                 )
          //               : VulcanXDropdown<OlStyleType>(
          //                   disabled: controller.rxDisabledTextbox.value
          //                       ? false
          //                       : true,
          //                   height: 40.0,
          //                   enumItems: OlStyleType.values,
          //                   onChanged: (OlStyleType? newValue) {
          //                     if (newValue == null) return;
          //                     controller
          //                         .setTocListStyleType(newValue.translationKey);
          //                   },
          //                   hintText: '',
          //                   value: OlStyleType.fromString(
          //                       controller.rxTocListType.value),
          //                   displayStringForOption: (type) => type.name,
          //                 ),
          //         ),
          //       ],
          //     ),
          //   );
          // }),

          // // 항목 간격 설정
          // const SizedBox(height: 16),
          // Obx(() => VulcanXLabelTextField(
          //       focusNode: controller.focusWidgetTocItemSpacingNode,
          //       textFieldWidth: 80,
          //       initialValue: controller.rxTocItemSpacing.value.toString(),
          //       unit: 'px',
          //       label: 'item_spacing'.tr,
          //       onChanged: (value) =>
          //           controller.setTocItemSpacing(int.tryParse(value) ?? 0),
          //     )),

          // // 들여쓰기 크기 설정
          // const SizedBox(height: 16),
          // Obx(() => VulcanXLabelTextField(
          //     focusNode: controller.focusWidgetTocIndentSizeNode,
          //     textFieldWidth: 80,
          //     initialValue: controller.rxTocIndentSize.value.toString(),
          //     unit: 'px',
          //     label: 'indent_size'.tr,
          //     onChanged: (value) =>
          //         controller.setTocIndentSize(int.tryParse(value) ?? 20))),

          // // 선택된 목차 항목 제어
          // const SizedBox(height: 16),
          // VulcanXText(
          //   text: 'selected_item'.tr,
          //   style: const TextStyle(fontWeight: FontWeight.bold),
          // ),

          // const SizedBox(height: 16),
          // Obx(() {
          //   // 선택된 항목이 없을 수 있으므로 기본값 처리
          //   final itemIndex = controller.rxSelectedTocItemIndex.value;
          //   final itemLevel = controller.rxSelectedTocItemLevel.value;

          //   return VulcanXText(
          //     text: '${'index'.tr}: $itemIndex, ${'level'.tr}: $itemLevel',
          //   );
          // }),
          // // 항목 선택 드롭다운
          // Obx(() {
          //   // 목차 항목 수에 따라 드롭다운 아이템 생성
          //   final items = List<int>.generate(
          //       controller.rxTocItemCount.value, (index) => index + 1);

          //   return Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text('select_item'.tr),
          //       SizedBox(
          //         width: 148,
          //         child: VulcanXDropdown<int>(
          //           disabled: controller.rxDisabledTextbox.value ? false : true,
          //           height: 40.0,
          //           onChanged: (int? newValue) {
          //             if (newValue == null) return;
          //             // 0부터 시작하는 인덱스로 변환
          //             controller.rxSelectedTocItemIndex.value = newValue - 1;
          //             controller.selectTocItem(
          //                 controller.rxSelectedTocItemIndex.value);
          //           },
          //           hintText: '',
          //           value: controller.rxSelectedTocItemIndex.value + 1,
          //           items: items
          //               .map((i) => VulcanXIconDropdownMenuItem<int>(
          //                     value: i,
          //                     child: Text(i.toString()),
          //                   ))
          //               .toList(),
          //         ),
          //       ),
          //     ],
          //   );
          // }),
          // const SizedBox(height: 16),
          // Row(
          //   children: [
          //     Expanded(
          //       child: VulcanXOutlinedButton(
          //         onPressed: () => controller.decreaseSelectedItemLevel(),
          //         child: Text('outdent'.tr),
          //       ),
          //     ),
          //     const SizedBox(width: 16),
          //     Expanded(
          //       child: VulcanXElevatedButton(
          //         onPressed: () => controller.increaseSelectedItemLevel(),
          //         child: Text('indent'.tr),
          //       ),
          //     ),
          //   ],
          // ),

          // const SizedBox(height: 16),
          // // 목차 텍스트 스타일링
          // VulcanXText(
          //   //목차 텍스트
          //   text: 'toc_text'.tr,
          //   style: const TextStyle(fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 16),
          // VulcanXColorPickerWidget(
          //     //텍스트 색상
          //     label: 'text_color'.tr,
          //     initialColor: controller.rxTextColor.value,
          //     onColorChanged: (color) => controller.setTocTextColor(color)),

          // const SizedBox(height: 16),
          // VulcanXLabelTextField(
          //   textFieldWidth: 80,
          //   initialValue: controller.rxTextSize.value,
          //   unit: 'px',
          //   //텍스트 크기
          //   label: 'text_size'.tr,
          //   onChanged: (value) => controller.setTocTextSize(value),
          // ),
          // const VulcanXDivider(space: 16),

          // // 페이지 번호 스타일링
          // VulcanXText(
          //   //페이지 번호
          //   text: 'page_number'.tr,
          //   style: const TextStyle(fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 16),
          // VulcanXColorPickerWidget(
          //     //페이지 번호 색상
          //     label: 'page_number_color'.tr,
          //     initialColor: controller.rxPageNumberColor.value,
          //     onColorChanged: (color) => controller.setPageNumberColor(color)),

          // const SizedBox(height: 16),
          // VulcanXLabelTextField(
          //   textFieldWidth: 80,
          //   initialValue: controller.rxPageNumberSize.value,
          //   unit: 'px',
          //   //페이지 번호 크기
          //   label: 'page_number_size'.tr,
          //   onChanged: (value) => controller.setPageNumberSize(value),
          // ),
          // const SizedBox(height: 16),

          // // 점(Dots) 스타일링
          // VulcanXText(
          //   //점(Dots)
          //   text: 'toc_dots'.tr,
          //   style: const TextStyle(fontWeight: FontWeight.bold),
          // ),
          // const VulcanXDivider(space: 16),
          // Obx(
          //   () => VulcanXSwitch(
          //     //점 표시
          //     label: 'dots_display'.tr,
          //     value: controller.rxIsDotsVisible.value,
          //     onChanged: (value) => controller.toggleDotsVisible(),
          //   ),
          // ),
          // const SizedBox(height: 16),
          // VulcanXColorPickerWidget(
          //     //점 색상
          //     label: 'dots_color'.tr,
          //     initialColor: controller.rxDotsColor.value,
          //     onColorChanged: (color) => controller.setDotsColor(color)),

          // const SizedBox(height: 16),

          // // 패딩 설정
          // VulcanXText(
          //   //패딩
          //   text: 'padding'.tr,
          //   style: const TextStyle(fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 16),
          // Row(
          //   children: [
          //     Expanded(
          //       child: VulcanXLabelTextField(
          //         textFieldWidth: 60,
          //         initialValue: controller.rxTocPaddingTop.value.toString(),
          //         unit: 'px',
          //         //상단
          //         label: 'padding_top'.tr,
          //         onChanged: (value) =>
          //             controller.setTocPaddingTop(int.tryParse(value) ?? 0),
          //       ),
          //     ),
          //     const SizedBox(width: 8),
          //     Expanded(
          //       child: VulcanXLabelTextField(
          //         textFieldWidth: 60,
          //         initialValue: controller.rxTocPaddingRight.value.toString(),
          //         unit: 'px',
          //         //오른쪽
          //         label: 'padding_right'.tr,
          //         onChanged: (value) =>
          //             controller.setTocPaddingRight(int.tryParse(value) ?? 0),
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 16),
          // Row(
          //   children: [
          //     Expanded(
          //       child: VulcanXLabelTextField(
          //         textFieldWidth: 60,
          //         initialValue: controller.rxTocPaddingBottom.value.toString(),
          //         unit: 'px',
          //         //하단
          //         label: 'padding_bottom'.tr,
          //         onChanged: (value) =>
          //             controller.setTocPaddingBottom(int.tryParse(value) ?? 0),
          //       ),
          //     ),
          //     const SizedBox(width: 8),
          //     Expanded(
          //       child: VulcanXLabelTextField(
          //         textFieldWidth: 60,
          //         initialValue: controller.rxTocPaddingLeft.value.toString(),
          //         unit: 'px',
          //         //왼쪽
          //         label: 'padding_left'.tr,
          //         onChanged: (value) =>
          //             controller.setTocPaddingLeft(int.tryParse(value) ?? 0),
          //       ),
          //     ),
          //   ],
          // ),
          // const VulcanXDivider(space: 16),
          BorderItem(),
          const SizedBox(width: 16),
          VulcanXColorPickerWidget(
              //배경색
              label: 'background_color'.tr,
              initialColor: controller.rxBackgroundColor.value,
              onColorChanged: (color) => controller.setBackgroundColor(color)),

          const SizedBox(height: 24),

          // 원래대로 버튼
          VulcanXOutlinedButton.icon(
            width: double.infinity,
            onPressed: () => controller.resetToOriginalSettings(),
            icon: CommonAssets.icon.replay.svg(),
            //원래대로
            child: Text('original_style'.tr),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
