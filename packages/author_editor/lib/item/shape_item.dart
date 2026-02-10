import 'package:app_ui/app_ui.dart';
import 'package:author_editor/extension/assets_image_extension.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 새로운 깨끗한 브랜치 테스트용 주석입니다.
class ShapeItem extends StatelessWidget with EditorEventbus {
  ShapeItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // line _________________________________
            _buildShape(title: 'shape_line'.tr, type: 'line', count: 14),
            const SizedBox(height: 8),
            // basic _________________________________
            _buildShape(title: 'shape_basic'.tr, type: 'basic', count: 18),
            const SizedBox(height: 8),
            // polygon _________________________________
            _buildShape(title: 'shape_polygon'.tr, type: 'polygon', count: 21),
            const SizedBox(height: 8),
            // arrow _________________________________
            _buildShape(title: 'shape_arrow'.tr, type: 'arrow', count: 8),
            const SizedBox(height: 8),
            // bubble _________________________________
            _buildShape(title: 'shape_bubble'.tr, type: 'bubble', count: 5),
            const SizedBox(height: 16),
            // three-dimensional figure ______________
            _buildShape(title: 'shape_3d'.tr, type: '3d', count: 8),
            const SizedBox(height: 16),
            // icon _________________________________
            _buildShape(title: 'shape_icon'.tr, type: 'icon', count: 21),
            const SizedBox(height: 16),
            // symbol _________________________________
            _buildShape(title: 'shape_symbol'.tr, type: 'symbol', count: 17),
            const SizedBox(height: 16),
            // banner ______________
            _buildShape(title: 'shape_banner'.tr, type: 'banner', count: 6),
            const SizedBox(height: 16),

            // flow _________________________________
            _buildShape(title: 'shape_flow'.tr, type: 'flow', count: 28),
            const SizedBox(height: 16),
          ],
        ));
  }

  Widget _buildShape(
      {required String title, required String type, required int count}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VulcanXText(
            text: title,
            suffixIcon: const Icon(Icons.expand_more_rounded, size: 16.0)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(
            count,
            (index) => VulcanXInkWell(
              onTap: () => controller.insertShape(type, index),
              child: Assets.image
                  .fromNumberedImage('shape_$type', index + 1)
                  .image(width: 40, height: 40),
            ),
          ),
        ),
      ],
    );
  }
}
