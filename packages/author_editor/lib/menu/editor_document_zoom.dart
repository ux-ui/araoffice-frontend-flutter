import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class EditorDocumentZoom extends StatelessWidget with EditorEventbus {
  final popupController = PopupMenuBarController();
  final rxZoomValue = 100.0.obs;
  EditorDocumentZoom({super.key});

  @override
  Widget build(BuildContext context) {
    // scale 값들을 리스트로 정의
    final List<double> scaleValues = [0.5, 0.7, 0.9, 1, 1.2, 1.5, 2, 3];

    final itemGroups = [
      [
        {
          'label': 'percent'.trArgs(['50']),
          'shortcut': '',
          'index': '0'
        },
        {
          'label': 'percent'.trArgs(['70']),
          'shortcut': '',
          'index': '1'
        },
        {
          'label': 'percent'.trArgs(['90']),
          'shortcut': '',
          'index': '2'
        },
        {
          'label': 'percent'.trArgs(['100']),
          'shortcut': '',
          'index': '3'
        },
        {
          'label': 'percent'.trArgs(['120']),
          'shortcut': '',
          'index': '4'
        },
        {
          'label': 'percent'.trArgs(['150']),
          'shortcut': '',
          'index': '5'
        },
        {
          'label': 'percent'.trArgs(['200']),
          'shortcut': '',
          'index': '6'
        },
        {
          'label': 'percent'.trArgs(['300']),
          'shortcut': '',
          'index': '7'
        },
      ],
    ];

    return Tooltip(
      message: 'document_setting'.tr,
      child: PopupMenuBar(
        controller: popupController,
        content: _buildMoreMenuContent(context, itemGroups, scaleValues),
        child: Obx(() => VulcanXText.outline(text: '$rxZoomValue%')),
      ),
    );
  }

  Widget _buildMoreMenuContent(BuildContext context,
      List<List<Map<String, String>>> itemGroups, List<double> scaleValues) {
    return VulcanXRoundedContainer(
      width: 60,
      isBoxShadow: true,
      child: PointerInterceptor(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...itemGroups[0].map((item) {
              final index = int.parse(item['index'] ?? '0');
              return VulcanXText(
                padding: const EdgeInsets.all(5),
                text: item['label'] ?? '',
                onTap: () {
                  if (index >= 0 && index < scaleValues.length) {
                    final scaleValue = scaleValues[index];
                    rxZoomValue.value = scaleValue * 100;
                    controller.scale(scaleValue);
                  }
                  popupController.close();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
