import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../panel/panels.dart';
import '../vulcan_editor_eventbus.dart';
import '../web_socket/web_socket_user_list.dart';

class EditorNavigationNail extends StatefulWidget {
  final Function(Widget panel) onSelected;
  final bool quizWidgetStatus;

  const EditorNavigationNail({
    super.key,
    required this.onSelected,
    required this.quizWidgetStatus,
  });

  @override
  State<EditorNavigationNail> createState() => _EditorNavigationNailState();
}

class _EditorNavigationNailState extends State<EditorNavigationNail>
    with EditorEventbus {
  int _selectedIndex = -1;
  static const double _navigationBarWidth = 48.0;

  late final List<Map<String, dynamic>> _allItems;
  final _showOfficeDocPanel = true;

  @override
  void initState() {
    super.initState();
    _allItems = [
      {
        'icon': CommonAssets.icon.draft,
        // 페이지
        'label': 'page'.tr,
        'panel': const PagePanel()
      },
      {
        'icon': CommonAssets.icon.widgets,
        // 요소
        'label': 'element'.tr,
        'panel': const ElementPanel()
      },
      {
        'icon': CommonAssets.icon.inventory2,
        // 위젯
        'label': 'widget'.tr,
        'panel': WidgetPanel(
          quizWidgetStatus: widget.quizWidgetStatus,
        )
      },
      {
        'icon': CommonAssets.icon.search,
        // 찾기 & 바꾸기
        'label': 'find'.tr,
        'panel': const FindReplacePanel()
      },
      // @Deprecated('추후 제거 예정')
      if (_showOfficeDocPanel) ...[
        {
          'icon': CommonAssets.icon.drafts,
          // doc
          'label': 'office_doc'.tr,
          'panel': const OfficeDocPanel()
        },
      ]
      // TODO 추후 구현 예정
      // {'icon': CommonAssets.icon.designServices, 'label': '스타일'},
      // {'icon': CommonAssets.icon.contract, 'label': '스크립트'},
      // {'icon': CommonAssets.icon.animatedImages, 'label': '애니메이션'},
      // {'icon': CommonAssets.icon.help, 'label': '도움말'},
    ];
  }

  List<List<Map<String, dynamic>>> get _itemOwnerGroups =>
      controller.isEditingPermission.isTrue
          ? [
              [_allItems[0]],
              [_allItems[1]],
              [_allItems[2]],
              [_allItems[3]],
              // @Deprecated('추후 제거 예정')
              if (_showOfficeDocPanel) [_allItems[4]],
            ]
          : [
              [_allItems[0]],
            ];

  List<List<Map<String, dynamic>>> get _itemUserGroups =>
      controller.isEditingPermission.isTrue
          ? [
              [_allItems[0]],
              [_allItems[1]],
              [_allItems[2]],
              [_allItems[3]],
            ]
          : [
              [_allItems[0]],
            ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      widget.onSelected(_allItems[index]['panel']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: SizedBox(
        width: _navigationBarWidth,
        child: Column(
          children: [
            Expanded(
              child: Obx(() => GroupedVerticalItems<Map<String, dynamic>>(
                    width: _navigationBarWidth,
                    itemGroups: controller.rxIsOwner.isTrue
                        ? _itemOwnerGroups
                        : _itemUserGroups,
                    itemBuilder: (context, itemData, _, __) {
                      int index = _allItems.indexOf(itemData);
                      return VulcanXSvgLabelIconButton(
                        icon: itemData['icon'],
                        label: itemData['label'],
                        isSelected: _selectedIndex == index,
                        onPressed: () => _onItemSelected(index),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        unselectedColor: Colors.black,
                      );
                    },
                  )),
            ),

            // white board  비활성화
            // Obx(() {
            //   // connectedUserList가 비어있지 않을 때만 드로잉 관련 버튼들을 표시
            //   if (controller.connectedUserList.isNotEmpty) {
            //     return Column(
            //       children: [
            //         IconButton(
            //           onPressed: () {
            //             controller.rxPopupInteracting.value =
            //                 !controller.rxPopupInteracting.value;
            //             controller.rxIsDrawingMode.value =
            //                 !controller.rxIsDrawingMode.value;
            //             controller.editor?.toggleDrawingMode(
            //               controller.rxIsDrawingMode.value ? 'draw' : 'null',
            //             );
            //             controller.cursorAction.value =
            //                 controller.rxIsDrawingMode.value
            //                     ? 'drawing'
            //                     : 'none';
            //             if (controller.rxIsDrawingMode.value) {
            //               controller.editor?.enable(false);
            //             } else {
            //               controller.editor?.enable(true);
            //             }
            //           },
            //           icon: Icon(
            //             controller.rxIsDrawingMode.value
            //                 ? Icons.draw
            //                 : Icons.edit_off,
            //             color: controller.rxIsDrawingMode.value
            //                 ? Theme.of(context).colorScheme.primary
            //                 : Colors.grey,
            //           ),
            //         ),
            //         const SizedBox(height: 10),
            //         IconButton(
            //           onPressed: () {
            //             controller.rxIsEraseMode.value =
            //                 !controller.rxIsEraseMode.value;
            //             controller.cursorAction.value =
            //                 controller.rxIsEraseMode.value
            //                     ? 'erase'
            //                     : 'drawing';
            //           },
            //           icon: CommonAssets.icon.eraser.svg(
            //               width: 20,
            //               height: 20,
            //               colorFilter: ColorFilter.mode(
            //                   controller.rxIsEraseMode.value
            //                       ? context.primary
            //                       : Colors.grey,
            //                   BlendMode.srcIn)),
            //         ),
            // Obx(
            //   () => controller.rxEditingUserId.value ==
            //           controller.documentState.rxUserId.value
            //       ? IconButton(
            //           onPressed: () {
            //             controller.editor?.clearDrawing();
            //             controller.wsManager.sendCursorPosition(
            //                 controller.documentState.rxProjectId.value,
            //                 controller
            //                         .documentState.rxPageCurrent.value?.idref ??
            //                     'cover.xhtml',
            //                 0,
            //                 0,
            //                 controller.documentState.rxDocumentSizeWidth.value
            //                     .toDouble(),
            //                 controller.documentState.rxDocumentSizeHeight.value
            //                     .toDouble(),
            //                 'clear',
            //                 'false');
            //           },
            //           icon: const Icon(Icons.refresh),
            //         )
            //       : const SizedBox.shrink(),
            // ),
            //       ],
            //     );
            //   }
            //   // connectedUserList가 비어있으면 빈 컨테이너 반환
            //   return Container();
            // }),

            // PopupMenuButton(
            //   child: const Icon(
            //     Icons.circle,
            //     size: 20,
            //   ),
            //   itemBuilder: (context) => [
            //     PopupMenuItem(
            //       child: Icon(Icons.circle, size: 10),
            //       onTap: () => controller.editor?.setDrawingStyle(
            //         js_util.jsify({
            //           'strokeStyle': '#000000',
            //           'lineWidth': 1,
            //           'lineCap': 'round',
            //           'lineJoin': 'round',
            //         }),
            //       ),
            //     ),
            //     PopupMenuItem(
            //       child: Icon(Icons.circle, size: 20),
            //       onTap: () => controller.editor?.setDrawingStyle(
            //         js_util.jsify({
            //           // 'strokeStyle': '#000000',
            //           'strokeStyle': '#FF1493',
            //           'lineWidth': 3,
            //           'lineCap': 'round',
            //           'lineJoin': 'round',
            //         }),
            //       ),
            //     ),
            //     PopupMenuItem(
            //       child: Icon(Icons.circle, size: 30),
            //       onTap: () => controller.editor?.setDrawingStyle(
            //         js_util.jsify({
            //           'strokeStyle': '#000000',
            //           'lineWidth': 5,
            //           'lineCap': 'round',
            //           'lineJoin': 'round',
            //         }),
            //       ),
            //     ),
            //   ],
            // ),
            // PopupMenuButton(
            //   child: const Icon(Icons.palette, size: 20),
            //   itemBuilder: (context) => [
            //     PopupMenuItem(
            //       child: VulcanXColorPickerWidget(
            //         label: '색상',
            //         initialColor: Colors.black,
            //         onColorChanged: (color) {
            //           debugPrint(
            //               '######color: ${color.toHexStringWithAlpha()}}');
            //           controller.editor?.setDrawingStyle(
            //             js_util.jsify(
            //                 {'strokeStyle': color.toHexStringWithAlpha()}),
            //           );
            //         },
            //       ),
            //     ),
            //   ],
            // ),
            // Obx(() => IconButton(
            //       onPressed: () {
            //         controller.rxIsCoopMode.value =
            //             !controller.rxIsCoopMode.value;
            //       },
            //       icon: Icon(
            //         Icons.network_check,
            //         color: controller.rxIsCoopMode.value
            //             ? Theme.of(context).colorScheme.primary
            //             : Colors.grey,
            //       ),
            //     )),
            WebSocketUserList(),
            // TODO 추후 구현예정
            // 도움말 등 nail 하단에 있는 아이콘들
            // ..._allItems.sublist(6).asMap().entries.map((entry) {
            //   int index = entry.key + 6;
            //   Map<String, dynamic> item = entry.value;
            //   return IconButton(
            //     icon: item['icon'].svg(),
            //     tooltip: item['label'],
            //     isSelected: _selectedIndex == index,
            //     onPressed: () => _onItemSelected(index),
            //   );
            // }),
          ],
        ),
      ),
    );
  }
}
