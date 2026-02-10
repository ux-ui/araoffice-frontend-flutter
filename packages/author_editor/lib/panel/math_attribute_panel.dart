import 'package:app_ui/widgets/vulcanx/external/wrap_expansion_panel_list.dart';
import 'package:author_editor/panel/base_attribute_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../item/items.dart';

class MathAttributePanel extends BaseAttribute {
  final String mathMarkup;
  MathAttributePanel({super.key, required this.mathMarkup})
      : super(enabledIndices: [0]);

  @override
  Widget buildStyle() {
    final styleData = [
      // WrapExpanstionPanelItem(
      //     headerValue: 'font'.tr,
      //     child: TextBoxStyleFontItem(
      //       enabledHeading: false,
      //       enabledFontEffect: false,
      //     )),
      WrapExpanstionPanelItem(
          headerValue: 'edit'.tr,
          child: MathEditItem(mathMarkup: mathMarkup)), // Now this works
      WrapExpanstionPanelItem(
          headerValue: 'align'.tr, child: StyleAlignItem(isOnlyZindex: true)),
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
    ];

    return SingleChildScrollView(
        child: WrapExpansionPanelList(data: styleData));
  }

  @override
  Widget buildDesign() {
    return Text('design'.tr);
  }

  @override
  Widget buildAnimation() {
    return Text('animation'.tr);
  }
}
