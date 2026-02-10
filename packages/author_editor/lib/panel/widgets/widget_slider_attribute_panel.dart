import 'package:app_ui/widgets/vulcanx/external/wrap_expansion_panel_list.dart';
import 'package:author_editor/panel/base_attribute_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../enum/enums.dart';
import '../../item/items.dart';

class WidgetSliderAttributePanel extends BaseAttribute {
  final WidgetSliderType type;
  WidgetSliderAttributePanel({super.key, required this.type})
      : super(enabledIndices: [1, 2]);

  @override
  Widget buildStyle() {
    return const SizedBox.shrink();
  }

  @override
  Widget buildDesign() {
    final designData = [
      WrapExpanstionPanelItem(
          //레이어
          headerValue: 'layer'.tr,
          child: WidgetSliderDesignItem(type: type)),
    ];

    return SingleChildScrollView(
        child: WrapExpansionPanelList(data: designData));
  }

  @override
  Widget buildAnimation() {
    return SingleChildScrollView(child: AnimationItem());
  }
}
