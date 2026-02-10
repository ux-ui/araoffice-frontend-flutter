import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';
import '../item/items.dart';
import '../vulcan_editor_eventbus.dart';

class PageSettingsPanel extends StatefulWidget {
  /// 요소 패널
  const PageSettingsPanel({super.key});

  @override
  State<PageSettingsPanel> createState() => _PageSettingsPanelState();
}

class _PageSettingsPanelState extends State<PageSettingsPanel>
    with EditorEventbus {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            //문서 설정
            child: Text('document_setting'.tr, style: context.titleSmall),
          ),
          const HorDivider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => AbsorbPointer(
                // absorbing: !controller.documentState.rxPageEditable.value,
                absorbing: !controller.rxIsEditorStatus.value,
                child: Opacity(
                  opacity: controller.rxIsEditorStatus.value ? 1.0 : 0.5,
                  child: Column(
                    children: [
                      // 눈금자 보이기
                      LabelRectangleCheckbox(
                        label: 'show_ruler'.tr,
                        isChecked: controller.rxShowRuler.value,
                        onChanged: (bool value) => controller.showRuler(value),
                      ),
                      const SizedBox(height: 8),
                      // 눈금선 보이기
                      LabelRectangleCheckbox(
                        label: 'show_grid'.tr,
                        isChecked: controller.rxShowGrid.value,
                        onChanged: (bool value) => controller.showGrid(value),
                      ),
                      const SizedBox(height: 8),
                      // 눈금선에 끌어당김
                      LabelRectangleCheckbox(
                        label: 'grid_snap'.tr,
                        isChecked: controller.rxGridSnap.value,
                        onChanged: (bool value) =>
                            controller.enableSnapToGrid(value),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          const HorDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => AbsorbPointer(
                    absorbing: !controller.rxIsEditorStatus.value,
                    child: Opacity(
                      opacity: controller.rxIsEditorStatus.value ? 1.0 : 0.5,
                      child: VulcanXLabelTextField(
                        label: 'width'.tr,
                        textFieldWidth: 150,
                        focusNode: controller.focusDocumentWidthNode,
                        unit: 'px',
                        initialValue: controller
                            .documentState.rxDocumentSizeWidth.value
                            .toString(),
                        textAlign: TextAlign.right,
                        inputFormatters: [
                          // 숫자만 입력
                          FilteringTextInputFormatter.allow(
                              // RegExp(r'^\d*\.?\d*$')),
                              RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: (String value) {
                          final intValue = int.tryParse(value) ?? 0;
                          controller.setContentSize(
                              width: intValue,
                              height: controller
                                  .documentState.rxDocumentSizeHeight.value);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => AbsorbPointer(
                    absorbing: !controller.rxIsEditorStatus.value,
                    child: Opacity(
                      opacity: controller.rxIsEditorStatus.value ? 1.0 : 0.5,
                      child: VulcanXLabelTextField(
                        label: 'height'.tr,
                        textFieldWidth: 150,
                        unit: 'px',
                        focusNode: controller.focusDocumentHeightNode,
                        initialValue: controller
                            .documentState.rxDocumentSizeHeight.value
                            .toString(),
                        textAlign: TextAlign.right,
                        inputFormatters: [
                          // 숫자만 입력
                          FilteringTextInputFormatter.allow(
                              // RegExp(r'^\d*\.?\d*$')),
                              RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: (String value) {
                          final intValue = int.tryParse(value) ?? 0;
                          controller.setContentSize(
                              width: controller
                                  .documentState.rxDocumentSizeWidth.value,
                              height: intValue);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const HorDivider(),
          Obx(() => Padding(
                padding: const EdgeInsets.all(16.0),
                child: VulcanXSvgButtonSelector(
                    //배치
                    label: 'placement'.tr,
                    width: 150,
                    initialEnum:
                        controller.documentState.rxPlacementState.value,
                    enumValues: PlacementType.values,
                    svgAssets: [
                      CommonAssets.icon.formatAlignLeft,
                      CommonAssets.icon.formatAlignCenter,
                      CommonAssets.icon.formatAlignRight,
                      CommonAssets.icon.formatAlignJustify,
                    ],
                    onSelectedEnum: (placement) => controller
                        .triggerPlacementPropertyPage(placement!.name)),
              )),
          const HorDivider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => AbsorbPointer(
                absorbing: !controller.rxIsEditorStatus.value,
                child: Opacity(
                  opacity: controller.rxIsEditorStatus.value ? 1.0 : 0.5,
                  child: Column(
                    children: [
                      BackgroundItem(type: 'body'),
                      const SizedBox(height: 8),
                      BackgroundImageItem(
                          type: ObjectType.body,
                          backgroundType: ObjectType.bodyBackgroundImage),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
