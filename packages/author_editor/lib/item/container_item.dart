import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';
import '../vulcan_editor_eventbus.dart';

class ContainerItem extends StatelessWidget with EditorEventbus {
  ContainerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          runSpacing: 10.0,
          spacing: 10.0,
          children: [
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.container01,
                      // 임의 위치
                      label: 'container_free'.tr)),
              onTap: () => controller.insertContainer(ContainerType.free.name),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.container02,
                      // 가로(왼쪽)
                      label: 'container_left'.tr)),
              onTap: () => controller.insertContainer(ContainerType.left.name),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.container03,
                      // 가로(중앙)
                      label: 'container_horizontal_center'.tr)),
              onTap: () => controller
                  .insertContainer(ContainerType.horizontalCenter.name),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.container04,
                      // 가로(오른쪽)
                      label: 'container_right'.tr)),
              onTap: () => controller.insertContainer(ContainerType.right.name),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.container05,
                      // 가로(양쪽)
                      label: 'container_horizontal_between'.tr)),
              onTap: () => controller
                  .insertContainer(ContainerType.horizontalBetween.name),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.container06,
                      // 세로(위쪽)
                      label: 'container_top'.tr)),
              onTap: () => controller.insertContainer(ContainerType.top.name),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.container07,
                      // 세로(중앙)
                      label: 'container_vertical_center'.tr)),
              onTap: () =>
                  controller.insertContainer(ContainerType.verticalCenter.name),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.container08,
                      // 세로(아래쪽)
                      label: 'container_bottom'.tr)),
              onTap: () =>
                  controller.insertContainer(ContainerType.bottom.name),
            ),
            VulcanXRoundedContainer.grey(
              width: 84,
              height: 84,
              child: Center(
                  child: VulcanXSvgLabelIconWidget(
                      icon: CommonAssets.icon.container09,
                      // 세로(양쪽)
                      label: 'container_vertical_between'.tr)),
              onTap: () => controller
                  .insertContainer(ContainerType.verticalBetween.name),
            ),
          ],
        ),
      ),
    );
  }
}
