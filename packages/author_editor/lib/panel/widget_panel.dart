import 'package:app_ui/app_ui.dart';
import 'package:author_editor/item/quiz_widget_item.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../item/items.dart';

class WidgetPanel extends StatefulWidget {
  /// 위젯 패널
  final bool quizWidgetStatus;

  const WidgetPanel({
    super.key,
    required this.quizWidgetStatus,
  });

  @override
  State<WidgetPanel> createState() => _WidgetPanelState();
}

class _WidgetPanelState extends State<WidgetPanel> with EditorEventbus {
  late final List<WrapExpanstionPanelItem> _data;

  @override
  void initState() {
    super.initState();
    _data = [
      WrapExpanstionPanelItem(
          //레이어
          headerValue: "layer".tr,
          child: LayerItem()),
      WrapExpanstionPanelItem(
          //컨테이너
          headerValue: "container".tr,
          child: ContainerItem()),
      WrapExpanstionPanelItem(
          //페이지
          headerValue: "page".tr,
          child: PageItem()),
      // 퀴즈 비활성화
      if (widget.quizWidgetStatus) ...[
        WrapExpanstionPanelItem(
            //퀴즈
            headerValue: "quiz".tr,
            child: QuizWidgetItem()),
      ]
    ];
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
                key: const PageStorageKey<String>('widget_panel'),
                child: WrapExpansionPanelList(data: _data),
              ),
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
