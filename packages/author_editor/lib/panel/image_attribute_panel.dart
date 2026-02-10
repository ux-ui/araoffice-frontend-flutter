import 'package:app_ui/widgets/vulcanx/external/wrap_expansion_panel_list.dart';
import 'package:author_editor/panel/base_attribute_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../item/items.dart';
import '../vulcan_editor_eventbus.dart';

class ImageAttributePanel extends BaseAttribute with EditorEventbus {
  ImageAttributePanel({super.key}) : super();

  final _designData = [
    WrapExpanstionPanelItem(
        headerValue: 'image'.tr, child: ImageDesignImageItem()),
  ];

  @override
  Widget buildStyle() {
    final styleData = [
      WrapExpanstionPanelItem(
          headerValue: 'align'.tr, child: StyleAlignItem(isOnlyZindex: true)),
      WrapExpanstionPanelItem(
          headerValue: 'size'.tr,
          child: SizeItem(
              type: 'image',
              focusWidthNode: controller.focusImageWidthNode,
              focusHeightNode: controller.focusImageHeightNode)),
      WrapExpanstionPanelItem(
        headerValue: 'location'.tr,
        child: PositionItem(
            type: 'location',
            unit: 'px',
            disabledTitle: true,
            padding: const EdgeInsets.symmetric(horizontal: 16.0) +
                const EdgeInsets.only(bottom: 16),
            xFocusNode: controller.focusImageXNode,
            yFocusNode: controller.focusImageYNode),
      ),
      WrapExpanstionPanelItem(headerValue: 'hyperlink'.tr, child: LinkItem()),
    ];

    return SingleChildScrollView(
        child: WrapExpansionPanelList(data: styleData));
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
