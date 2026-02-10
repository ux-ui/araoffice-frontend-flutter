import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../vulcan_editor_eventbus.dart';

class QuizWidgetItem extends StatelessWidget with EditorEventbus {
  QuizWidgetItem({super.key});

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
                      icon: CommonAssets.icon.layerToggle,
                      // slider
                      label: 'quiz_truefalse'.tr)),
              onTap: () => controller.triggerAddWidget('question', 'truefalse'),
            ),
            // VulcanXRoundedContainer.grey(
            //   width: 84,
            //   height: 84,
            //   child: Center(
            //       child: VulcanXSvgLabelIconWidget(
            //           icon: CommonAssets.icon.layerToggle,
            //           // slider
            //           label: 'quiz_left'.tr)),
            //   onTap: () =>
            //       controller.triggerAddWidget('question', 'truefalse_left'),
            // ),
            // VulcanXRoundedContainer.grey(
            //   width: 84,
            //   height: 84,
            //   child: Center(
            //       child: VulcanXSvgLabelIconWidget(
            //           icon: CommonAssets.icon.layerToggle,
            //           // slider
            //           label: 'quiz_right'.tr)),
            //   onTap: () =>
            //       controller.triggerAddWidget('question', 'truefalse_right'),
            // ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.layerToggle,
                      // slider
                      label: 'quiz_single_choice'.tr)),
              onTap: () =>
                  controller.triggerAddWidget('question', 'single_choice'),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.layerToggle,
                      // slider
                      label: 'quiz_multi_choice'.tr)),
              onTap: () =>
                  controller.triggerAddWidget('question', 'multi_choice'),
            ),
            // VulcanXRoundedContainer.grey(
            //   width: 84,
            //   height: 84,
            //   child: Center(
            //       child: VulcanXSvgLabelIconWidget(
            //           icon: CommonAssets.icon.layerToggle,
            //           // slider
            //           label: 'quiz_result'.tr)),
            //   onTap: () =>
            //       controller.triggerAddWidget('question', 'result_button'),
            // ),
          ],
        ),
      ),
    );
  }
}
