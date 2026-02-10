import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BaseAttribute extends StatelessWidget {
  final List<int>? enabledIndices;
  final int initialIndex;
  const BaseAttribute({super.key, this.enabledIndices, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(11.0),
          child: Text('attribute'.tr, style: context.titleMedium),
        ),
        Expanded(
          child: DefineTabBar(
            tabs: [
              'style'.tr,
              'design'.tr,
              'animation'.tr,
            ],
            initialIndex: initialIndex,
            enabledIndices: enabledIndices,
            indicatorSize: TabBarIndicatorSize.tab,
            tabChanged: (index) {
              debugPrint('Tab changed to index $index');
            },
            backgroundColor: Colors.white,
            children: [buildStyle(), buildDesign(), buildAnimation()],
          ),
        ),
      ],
    );
  }

  Widget buildStyle() => const SizedBox.shrink();
  Widget buildDesign() => const SizedBox.shrink();
  Widget buildAnimation() => const SizedBox.shrink();
}
