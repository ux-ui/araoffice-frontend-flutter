import 'package:app_ui/widgets/vulcanx/external/wrap_expansion_panel_list.dart';
import 'package:author_editor/panel/base_attribute_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../item/items.dart';

class TableAttributePanel extends BaseAttribute {
  TableAttributePanel({super.key}) : super();

  final _designData = [
    WrapExpanstionPanelItem(
        headerValue: 'table_design'.tr, child: TableDesignTableItem()),
    WrapExpanstionPanelItem(
        headerValue: 'size'.tr, child: TableDesignTableSizeItem()),
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
    WrapExpanstionPanelItem(
        headerValue: 'transform'.tr, child: TransformItem()),
  ];

  final _styleData = [
    WrapExpanstionPanelItem(
        headerValue: 'font'.tr, child: TextBoxStyleFontItem()),
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
