import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../item/items.dart';

class FindReplacePanel extends StatefulWidget {
  /// 위젯 패널
  const FindReplacePanel({super.key});

  @override
  State<FindReplacePanel> createState() => _FindReplacePanelState();
}

class _FindReplacePanelState extends State<FindReplacePanel>
    with EditorEventbus {
  final List<WrapExpanstionPanelItem> _data = [
    WrapExpanstionPanelItem(
        //문자 찾기
        headerValue: "find".tr,
        child: const FindItem()),
    WrapExpanstionPanelItem(
        //문자 바꾸기
        headerValue: "replace".tr,
        child: const ReplaceItem(enableSync: true)),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SingleChildScrollView(
                  child: WrapExpansionPanelList(data: _data)),
            ),
          ],
        ),
        // if (!controller.rxIsEditorStatus.value)
        //   Container(
        //     height: double.infinity,
        //     color: Colors.grey.withAlpha(128),
        //   ),
      ],
    );
  }
}
