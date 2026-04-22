import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_controller.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';

class EditorDeviceIconMenu extends StatelessWidget {
  final VulcanEditorController controller;
  const EditorDeviceIconMenu({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return VulcanXSvgIconSelector(
      svgIcons: [
        CommonAssets.icon.deviceIcon01,
        CommonAssets.icon.deviceIcon02,
        CommonAssets.icon.deviceIcon03,
        CommonAssets.icon.deviceIcon04,
      ],
      tooltips: const ['A5 가로', 'A3 세로', 'A4 가로', 'A4 세로'],
      onSelected: (index) {
        debugPrint('선택된 SVG 아이콘 인덱스: $index');
        // 96 DPI Pixel Dimensions:
        // A3 (297 x 420mm): 1123 x 1587 pixels
        // A4 (210 x 297mm): 794 x 1123 pixels
        // A5 (148 x 210mm): 559 x 794 pixels
        switch (index) {
          case 0: // A5 가로
            controller.setContentSize(width: 794, height: 559);
            break;
          case 1: // A3 세로
            controller.setContentSize(width: 1123, height: 1587);
            break;
          case 2: // A4 가로
            controller.setContentSize(width: 1123, height: 794);
            break;
          case 3: // A4 세로
            controller.setContentSize(width: 794, height: 1123);
            break;
          default:
        }
      },
      initialSelectedIndex: 3,
      iconSize: 28.0,
    );
  }
}
