import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enum/media_attribute_type.dart';

class AudioDesignAudioItem extends StatelessWidget with EditorEventbus {
  AudioDesignAudioItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Obx(
            () => VulcanXSwitch(
                // 컨트롤 표시
                label: 'media_controls'.tr,
                value: controller.rxMediaControls.value,
                onChanged: (value) => controller.setMediaAttribute(
                    MediaAttributeType.controls, value)),
          ),
          const SizedBox(height: 8),
          Obx(
            () => VulcanXSwitch(
                // 자동 재생
                label: 'media_autoplay'.tr,
                value: controller.rxMediaAutoPlay.value,
                onChanged: (value) => controller.setMediaAttribute(
                    MediaAttributeType.autoplay, value)),
          ),
          const SizedBox(height: 8),
          Obx(
            () => VulcanXSwitch(
                // 반복 재생
                label: 'media_loop'.tr,
                value: controller.rxMediaLoop.value,
                onChanged: (value) => controller.setMediaAttribute(
                    MediaAttributeType.loop, value)),
          ),
          const SizedBox(height: 8),
          Obx(
            () => VulcanXSwitch(
                // 음소거
                label: 'media_muted'.tr,
                value: controller.rxMediaMuted.value,
                onChanged: (value) => controller.setMediaAttribute(
                    MediaAttributeType.muted, value)),
          ),
          //const SizedBox(height: 8),
          // VulcanXOutlinedButton.icon(
          //     onPressed: () {},
          //     icon: CommonAssets.icon.replay.svg(),
          //     //원래대로
          //     child: Text('style_reset'.tr)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
