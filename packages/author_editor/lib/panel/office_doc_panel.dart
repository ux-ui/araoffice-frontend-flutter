import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../item/items.dart';

@Deprecated('추후 제거 예정')
class OfficeDocPanel extends StatefulWidget {
  /// 위젯 패널
  const OfficeDocPanel({super.key});

  @override
  State<OfficeDocPanel> createState() => _OfficeDocPanelState();
}

class _OfficeDocPanelState extends State<OfficeDocPanel> with EditorEventbus {
  final List<WrapExpanstionPanelItem> _data = [
    WrapExpanstionPanelItem(
        //office doc
        headerValue: "office_doc".tr,
        child: OfficeDocItem()),

    // TODO deprecated
    // WrapExpanstionPanelItem(
    //     //office doc list
    //     headerValue: "office_doc_list".tr,
    //     child: OfficeDocListItem()),
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
            // TODO ____ 추후 적용 ___
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   color: context.surface,
            //   child: Column(
            //     children: [
            //       VulcanXButtonSelector(
            //         options: const ['요소', '위젯'],
            //         onSelected: (index) {},
            //       ),
            //       const SizedBox(height: 8),
            //       const VulcanXTextField(hintText: '요소 검색', isSearchIcon: true),
            //     ],
            //   ),
            // ),
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
