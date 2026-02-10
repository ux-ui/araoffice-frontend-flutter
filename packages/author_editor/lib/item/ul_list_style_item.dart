import 'package:app_ui/app_ui.dart';
import 'package:author_editor/extension/assets_image_extension.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UlListStyleItem extends StatelessWidget with EditorEventbus {
  UlListStyleItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildListStyle(context),
            const SizedBox(height: 8),
          ],
        ));
  }

  Widget _buildListStyle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        VulcanXText(
            //목차 스타일
            text: 'ul_list_style'.tr,
            suffixIcon: const Icon(Icons.expand_more_rounded, size: 16.0)),
        const SizedBox(height: 8),
        VulcanXInkWellSelector(
          onTaps: List.generate(
            5,
            (index) => () => controller.setUlListStyle(index),
          ),
          spacing: 7,
          runSpacing: 7,
          alignment: WrapAlignment.start,
          children: List.generate(
            5,
            (index) => Assets.image
                .fromNumberedImage('ul_list', index + 1)
                .image(width: 80, height: 80),
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
