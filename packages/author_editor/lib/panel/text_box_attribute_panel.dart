import 'package:app_ui/widgets/vulcanx/external/wrap_expansion_panel_list.dart';
import 'package:author_editor/panel/base_attribute_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../item/items.dart';

class TextBoxAttributePanel extends BaseAttribute {
  TextBoxAttributePanel({super.key});

  final _styleData = [
    // WrapExpanstionPanelItem(
    //     headerValue: 'font'.tr, child: TextBoxStyleFontItem()),
    WrapExpanstionPanelItem(
        headerValue: 'paragraph'.tr, child: TextBoxStyleParagraphItem()),
    WrapExpanstionPanelItem(
        headerValue: 'multi_column'.tr, child: TextBoxStyleMultiColumnItem()),
    WrapExpanstionPanelItem(headerValue: 'size'.tr, child: SizeItem()),
    WrapExpanstionPanelItem(
      headerValue: 'location'.tr,
      child: PositionItem(
          type: 'location',
          unit: 'px',
          disabledTitle: true,
          padding: const EdgeInsets.symmetric(horizontal: 16.0) +
              const EdgeInsets.only(bottom: 16)),
    ),
    WrapExpanstionPanelItem(headerValue: 'hyperlink'.tr, child: LinkItem()),
    WrapExpanstionPanelItem(
        headerValue: 'align'.tr, child: StyleAlignItem(isOnlyZindex: true)),
    // WrapExpanstionPanelItem(
    //     headerValue: 'shape'.tr, child: const SizedBox.shrink()),
    // WrapExpanstionPanelItem(
    //     headerValue: 'style'.tr, child: const SizedBox.shrink()),
    //WrapExpanstionPanelItem(headerValue: 'align'.tr, child: StyleAlignItem()),
  ];

  final _designData = [
    WrapExpanstionPanelItem(
        //레이어
        headerValue: 'layer'.tr,
        child: TextBoxDesignLayerItem()),
  ];

  @override
  Widget buildStyle() {
    return SingleChildScrollView(
        child: WrapExpansionPanelList(data: _styleData));
  }

  @override
  Widget buildDesign() {
    return SingleChildScrollView(
        child: WrapExpansionPanelList(data: _designData));
  }

  @override
  Widget buildAnimation() {
    return SingleChildScrollView(child: AnimationItem());
  }
}
