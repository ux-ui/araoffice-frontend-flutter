import 'package:app_ui/widgets/vulcanx/external/wrap_expansion_panel_list.dart';
import 'package:author_editor/panel/base_attribute_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../item/items.dart';

class TextBoxTextAttributePanel extends BaseAttribute {
  final bool isUlList;
  TextBoxTextAttributePanel({super.key, this.isUlList = false})
      : super(enabledIndices: [0]);

  final _styleData = [
    WrapExpanstionPanelItem(
        headerValue: 'font'.tr, child: TextBoxStyleFontItem()),
    WrapExpanstionPanelItem(
        headerValue: 'paragraph'.tr, child: TextBoxStyleParagraphItem()),
    WrapExpanstionPanelItem(
        headerValue: 'list'.tr, child: TextBoxStyleListItem()),
    WrapExpanstionPanelItem(
        headerValue: 'list_class_style'.tr,
        child: TextBoxStyleCustomListItem()),
    // WrapExpanstionPanelItem(
    //     headerValue: 'ul_list'.tr, child: UlListStyleItem()),
    WrapExpanstionPanelItem(headerValue: 'hyperlink'.tr, child: LinkItem()),
  ];

  @override
  Widget buildStyle() {
    /// caret 상태에서 ul 태그가 아니면 ul_list는 안보이게 한다.
    // if (isUlList == false) {
    //   _styleData.remove(_styleData[2]);
    // }

    return SingleChildScrollView(
        child: WrapExpansionPanelList(data: _styleData));
  }

  @override
  Widget buildDesign() {
    return const SizedBox.shrink();
  }

  @override
  Widget buildAnimation() {
    return const SizedBox.shrink();
  }
}
