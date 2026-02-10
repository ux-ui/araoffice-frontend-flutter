import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../vulcan_editor_eventbus.dart';

class LayerItem extends StatelessWidget with EditorEventbus {
  LayerItem({super.key});

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
                      icon: CommonAssets.icon.layerSlider1,
                      // slider
                      label: 'slider'.tr)),
              onTap: () => controller.triggerAddWidget('slider', 'slider'),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.layerSlider1,
                      // simple_slider
                      label: 'simple_slider'.tr)),
              onTap: () =>
                  controller.triggerAddWidget('slider', 'simple_slider'),
            ),
            Visibility(
              visible: controller.tooggleWidgetStatus.value,
              child: VulcanXRoundedContainer.grey(
                width: 84,
                height: 84,
                child: Stack(children: [
                  Center(
                      child: VulcanXSvgLabelIconWidget(
                          icon: CommonAssets.icon.layerToggle,
                          label: 'toggle'.tr)),
                  Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ]),
                // onTap: () => controller.triggerAddWidget('toggle', 'toggle'),
              ),
            ),
            Visibility(
              visible: controller.tabWidgetStatus.value,
              child: VulcanXRoundedContainer.grey(
                width: 84,
                height: 84,
                child: Stack(children: [
                  Center(
                      child: VulcanXSvgLabelIconWidget(
                          icon: CommonAssets.icon.layerTabTop,
                          label: 'tab_top'.tr)),
                  Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ]),
                // onTap: () => controller.triggerAddWidget('tab', 'tab'),
              ),
            ),
            Visibility(
              visible: controller.tabWidgetStatus.value,
              child: VulcanXRoundedContainer.grey(
                width: 84,
                height: 84,
                child: Stack(children: [
                  Center(
                      child: VulcanXSvgLabelIconWidget(
                          icon: CommonAssets.icon.layerTabBottom,
                          label: 'tab_below'.tr)),
                  Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ]),
                // onTap: () => controller.triggerAddWidget('tab', 'tab_below'),
              ),
            ),
            Visibility(
              visible: controller.accordionWidgetStatus.value,
              child: VulcanXRoundedContainer.grey(
                width: 84,
                height: 84,
                child: Stack(children: [
                  Center(
                      child: VulcanXSvgLabelIconWidget(
                          icon: CommonAssets.icon.layerArcodionVer,
                          label: 'arccodion_vert'.tr)),
                  Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ]),
                // onTap: () =>
                // controller.triggerAddWidget('arccodion', 'arccodion_vert'),
              ),
            ),
            Visibility(
              visible: controller.accordionWidgetStatus.value,
              child: VulcanXRoundedContainer.grey(
                width: 84,
                height: 84,
                child: Stack(children: [
                  Center(
                      child: VulcanXSvgLabelIconWidget(
                          icon: CommonAssets.icon.layerArcodionHor,
                          label: 'arccodion_horz'.tr)),
                  Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ]),
                // onTap: () =>
                // controller.triggerAddWidget('arccodion', 'arccodion_horz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
