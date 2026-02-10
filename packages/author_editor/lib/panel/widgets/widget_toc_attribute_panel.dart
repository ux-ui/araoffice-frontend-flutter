import 'package:app_ui/widgets/vulcanx/external/wrap_expansion_panel_list.dart';
import 'package:author_editor/panel/base_attribute_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../item/items.dart';

class WidgetTocAttributePanel extends BaseAttribute {
  WidgetTocAttributePanel({super.key}) : super(initialIndex: 1);

  final _styleData = [
    WrapExpanstionPanelItem(
        headerValue: 'align'.tr, child: StyleAlignItem(isOnlyZindex: true)),
  ];

  @override
  Widget buildStyle() {
    return SingleChildScrollView(
        child: WrapExpansionPanelList(data: _styleData));
  }

  @override
  Widget buildDesign() {
    final designData = [
      WrapExpanstionPanelItem(
          //레이어
          headerValue: 'layer'.tr,
          child: WidgetTocDesignItem()),
    ];

    return SingleChildScrollView(
        child: WrapExpansionPanelList(data: designData));
  }

  @override
  Widget buildAnimation() {
    return SingleChildScrollView(child: AnimationItem());
  }
}
