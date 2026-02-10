import 'package:app_ui/app_ui.dart';
import 'package:author_editor/panel/base_attribute_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../item/items.dart';

class MultiSelectedAttributePanel extends BaseAttribute {
  MultiSelectedAttributePanel({super.key}) : super(enabledIndices: [0, 2]);

  final _styleData = [
    WrapExpanstionPanelItem(headerValue: 'align'.tr, child: StyleAlignItem()),
  ];

  @override
  Widget buildStyle() {
    return SingleChildScrollView(
        child: WrapExpansionPanelList(data: _styleData));
  }

  @override
  Widget buildDesign() {
    return const SizedBox.shrink();
  }

  @override
  Widget buildAnimation() {
    return SingleChildScrollView(child: MultiSelectedAnimationItem());
  }
}
