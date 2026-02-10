import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';

class AnimationItem extends StatelessWidget with EditorEventbus {
  AnimationItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            VulcanXText(
                //애니메이션 설정
                text: 'animation_setting'.tr,
                suffixIcon: const Icon(Icons.expand_more_rounded, size: 16.0)),
            const SizedBox(height: 8),
            Obx(() => VulcanXDropdown<AnimationType>(
                  height: 40.0,
                  enumItems: AnimationType.values,
                  onChanged: (AnimationType? newValue) {
                    controller.rxAnimationNames.value = newValue!;
                    controller.setAnimation();
                  },
                  hintText: '',
                  value: controller.rxAnimationNames.value,
                  displayStringForOption: (type) => type.name,
                )),
            const SizedBox(height: 16),
            Obx(() => VulcanXDropdown<AnimationTriggerType>(
                  height: 40.0,
                  enumItems: AnimationTriggerType.values,
                  onChanged: (AnimationTriggerType? newValue) {
                    controller.rxAnimationTrigger.value = newValue!;
                    controller.setAnimation();
                  },
                  hintText: '',
                  value: controller.rxAnimationTrigger.value,
                  displayStringForOption: (type) => type.name,
                )),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 대기시간(초)
                Text('delay_time'.tr),
                Obx(
                  () => CounterWidget(
                    minValue: 1,
                    unitConfig: const UnitConfig(
                        unit: '', stepValue: 0.1, decimalPlaces: 1),
                    initialValue: controller.rxAnimationDelay.value.toString(),
                    inputFormatters: [
                      // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) {
                      double count = double.tryParse(value) ?? 1.0;
                      controller.rxAnimationDelay.value = count;
                      controller.setAnimation();
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 재생시간(초)
                Text('duration_time'.tr),
                Obx(
                  () => CounterWidget(
                    minValue: 1,
                    unitConfig: const UnitConfig(
                        unit: '', stepValue: 0.1, decimalPlaces: 1),
                    initialValue:
                        controller.rxAnimationDuration.value.toString(),
                    inputFormatters: [
                      // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) {
                      double count = double.tryParse(value) ?? 1.0;
                      controller.rxAnimationDuration.value = count;
                      controller.setAnimation();
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 반복횟수
                Text('repeat_count'.tr),
                Obx(
                  () => CounterWidget(
                    minValue: 1,
                    initialValue: controller.rxAnimationRepeat.value.toString(),
                    inputFormatters: [
                      // 숫자만 입력
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      int count = int.tryParse(value) ?? 1;
                      controller.rxAnimationRepeat.value = count;
                      controller.setAnimation();
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: VulcanXOutlinedButton(
                      onPressed: () => controller.runAnimation(),
                      //재생
                      child: Text('play'.tr)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: VulcanXOutlinedButton(
                      onPressed: () => controller.stopAnimation(),
                      //중지
                      child: Text('stop'.tr)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: VulcanXOutlinedButton(
                      onPressed: () => controller.removeAnimation(),
                      //삭제
                      child: Text('remove'.tr)),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ));
  }
}
