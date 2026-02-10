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
      onSelected: (index) {
        debugPrint('선택된 SVG 아이콘 인덱스: $index');
        switch (index) {
          case 0:
            controller.setContentSize(width: 1200, height: 900);
            break;
          case 1:
            controller.setContentSize(width: 900, height: 800);
            break;
          case 2:
            controller.setContentSize(width: 800, height: 600);
            break;
          case 3:
            controller.setContentSize(width: 600, height: 800);
            break;
          default:
        }
      },
      initialSelectedIndex: 3,
      iconSize: 28.0,
    );
  }
}
