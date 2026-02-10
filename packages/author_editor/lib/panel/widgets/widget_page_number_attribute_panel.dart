import 'package:app_ui/widgets/vulcanx/external/wrap_expansion_panel_list.dart';
import 'package:author_editor/panel/base_attribute_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../item/items.dart';

class WidgetPageNumberAttributePanel extends BaseAttribute {
  WidgetPageNumberAttributePanel({super.key}) : super(enabledIndices: [1, 2]);

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
          child: WidgetPageNumberDesignItem()),
    ];

    return SingleChildScrollView(
        child: WrapExpansionPanelList(data: designData));
  }

  @override
  Widget buildAnimation() {
    return SingleChildScrollView(child: AnimationItem());
  }
}
