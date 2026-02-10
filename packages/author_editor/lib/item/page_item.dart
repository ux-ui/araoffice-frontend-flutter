import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../vulcan_editor_eventbus.dart';

class PageItem extends StatelessWidget with EditorEventbus {
  PageItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          runSpacing: 10.0,
          spacing: 10.0,
          children: [
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.tocWidget,
                      // 목차
                      label: 'toc'.tr)),
              onTap: () => controller.triggerAddWidget('toc', 'toc'),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.pageNumberWidget,
                      // 페이지 번호
                      label: 'page_number'.tr)),
              onTap: () => controller.triggerAddWidget('page', 'page_number'),
            ),
          ],
        ),
      ),
    );
  }
}
