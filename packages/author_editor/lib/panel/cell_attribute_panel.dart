import 'package:app_ui/widgets/vulcanx/external/wrap_expansion_panel_list.dart';
import 'package:author_editor/panel/base_attribute_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../item/items.dart';

class CellAttributePanel extends BaseAttribute {
  CellAttributePanel({super.key}) : super(enabledIndices: [0, 1]);

  final _designData = [
    // WrapExpanstionPanelItem(
    //     headerValue: 'table_design'.tr, child: TableDesignTableItem()),
    WrapExpanstionPanelItem(
        headerValue: 'cell_design'.tr, child: TableDesignCellItem()),
  ];

  final _styleData = [
    WrapExpanstionPanelItem(
        headerValue: 'font'.tr, child: TextBoxStyleFontItem()),
    WrapExpanstionPanelItem(
        headerValue: 'paragraph'.tr, child: TextBoxStyleParagraphItem()),
    WrapExpanstionPanelItem(
        headerValue: 'cell_function'.tr, child: TableCellFunctionItem()),
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
    return Text('animation'.tr);
  }
}
