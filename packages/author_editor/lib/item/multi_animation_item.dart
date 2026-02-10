import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiSelectedAnimationItem extends StatelessWidget with EditorEventbus {
  MultiSelectedAnimationItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: VulcanXOutlinedButton(
                      onPressed: () => controller.multiSelectedAnimationRun(),
                      //모두 재생
                      child: Text('all_play'.tr)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: VulcanXOutlinedButton(
                      onPressed: () => controller.multiSelectedAnimationStop(),
                      //모두 중지
                      child: Text('all_stop'.tr)),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ));
  }
}
