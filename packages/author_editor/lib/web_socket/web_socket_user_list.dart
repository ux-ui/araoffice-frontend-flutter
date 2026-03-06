import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebSocketUserList extends StatelessWidget {
  final controller = Get.find<VulcanEditorController>();
  WebSocketUserList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        // children: [
        //   if (controller.connectedUserList.isNotEmpty) ...[
        //     Text(
        //       'shared_user_list_online'
        //           .trArgs([controller.connectedUserList.length.toString()]),
        //       style: context.bodySmall,
        //       textAlign: TextAlign.center,
        //     ),
        //     Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         ...controller.connectedUserList.take(3).map((user) {
        //           return Padding(
        //             padding: const EdgeInsets.symmetric(vertical: 5.0),
        //             child: Tooltip(
        //               message: user,
        //               child: CircleAvatar(
        //                 radius: 16,
        //                 backgroundColor: getColorForUserId(user),
        //                 child: Text(user.substring(0, 1).toUpperCase()),
        //               ),
        //             ),
        //           );
        //         }),
        //         IconButton(
        //           onPressed: () {
        //             final RenderBox button =
        //                 context.findRenderObject() as RenderBox;
        //             final Offset offset = button.localToGlobal(Offset.zero);

        //             showMenu(
        //               context: context,
        //               position: RelativeRect.fromLTRB(
        //                 offset.dx,
        //                 offset.dy + button.size.height,
        //                 offset.dx + button.size.width,
        //                 offset.dy + button.size.height,
        //               ),
        //               items: controller.connectedUserList
        //                   .map((user) => PopupMenuItem(
        //                         child: Row(
        //                           children: [
        //                             CircleAvatar(
        //                               radius: 16,
        //                               backgroundColor: getColorForUserId(user),
        //                               child: Text(
        //                                   user.substring(0, 1).toUpperCase()),
        //                             ),
        //                             const SizedBox(width: 8),
        //                             Text(user),
        //                           ],
        //                         ),
        //                       ))
        //                   .toList(),
        //             );
        //           },
        //           icon: const Icon(Icons.more_horiz),
        //         )
        //       ],
        //     ),
        //   ],
        // ],
        children: [
          if (controller.connectedUserList.isNotEmpty) ...[
            Text(
              'shared_user_list_online'
                  .trArgs([controller.connectedUserList.length.toString()]),
              style: context.bodySmall,
              textAlign: TextAlign.center,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...controller.connectedUserList.take(3).map((user) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Tooltip(
                      message: user.displayName,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: getColorForUserId(user.displayName),
                        child: Text(
                            user.displayName.substring(0, 1).toUpperCase()),
                      ),
                    ),
                  );
                }),
                IconButton(
                  onPressed: () {
                    final RenderBox button =
                        context.findRenderObject() as RenderBox;
                    final Offset offset = button.localToGlobal(Offset.zero);

                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        offset.dx,
                        offset.dy + button.size.height,
                        offset.dx + button.size.width,
                        offset.dy + button.size.height,
                      ),
                      //rxSocketConnectedByEvent
                      // items:
                      // controller.connectedUserList
                      //     .map((user) => PopupMenuItem(
                      //           child: Row(
                      //             children: [
                      //               CircleAvatar(
                      //                 radius: 16,
                      //                 backgroundColor:
                      //                     getColorForUserId(user.displayName),
                      //                 child: Text(user.displayName
                      //                     .substring(0, 1)
                      //                     .toUpperCase()),
                      //               ),
                      //               const SizedBox(width: 8),
                      //               Text(user.displayName),
                      //             ],
                      //           ),
                      //         ))
                      //     .toList(),

                      items: <PopupMenuEntry<dynamic>>[
                        // 맨 윗줄: 소켓 상태 표시
                        PopupMenuItem(
                          enabled: false, // 클릭 불가 헤더처럼 사용
                          child: Row(
                            children: [
                              Obx(
                                () => Text(
                                    'connected_user_list_online'.trArgs([
                                      controller.connectedUserList.length
                                          .toString()
                                    ]),
                                    style: context.bodySmall),
                              ),
                              const SizedBox(width: 8),
                              Obx(
                                () => Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: controller
                                            .rxSocketConnectedByEvent.value
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        // 기존 유저 목록
                        ...controller.connectedUserList.map(
                          (user) => PopupMenuItem(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      getColorForUserId(user.displayName),
                                  child: Text(user.displayName
                                      .substring(0, 1)
                                      .toUpperCase()),
                                ),
                                const SizedBox(width: 8),
                                Text(user.displayName),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  icon: const Icon(Icons.more_horiz),
                )
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color getColorForUserId(String userId) {
    final hash = userId.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }
}
