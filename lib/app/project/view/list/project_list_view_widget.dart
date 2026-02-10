import 'package:api/api.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../editor/editor_page.dart';
import '../common/project_view_types.dart';

class ProjectListViewWidget extends StatelessWidget {
  final RxList<FolderContentModel> items;
  final ProjectMenuBuilder buildMenuItems;
  final HistoryMenuBuilder buildHistoryMenuItems;
  final NavigateToFolderCallback navigateToFolder;
  final ProjectDragCallback onDragAccepted;
  final ProjectHistoryCallback onHistoryTap;
  final Rxn<List<HistoryModel>?> projectHistory;
  final Rxn<List<ProjectModel>> projectList;
  final String currentFolderId;

  // 정렬 상태 관리
  final RxBool isSharedUsersAscending = true.obs;
  final RxBool isNameAscending = true.obs;
  final RxBool isDateAscending = false.obs;

  ProjectListViewWidget({
    super.key,
    required List<FolderContentModel> items,
    required this.buildMenuItems,
    required this.buildHistoryMenuItems,
    required this.navigateToFolder,
    required this.onDragAccepted,
    required this.onHistoryTap,
    required this.projectHistory,
    required this.projectList,
    required this.currentFolderId,
  }) : items = items.obs;

  // 정렬 메서드들
  void _sortByName() {
    isNameAscending.value = !isNameAscending.value;
    _sortItems((a, b) => isNameAscending.value
        ? a.name.compareTo(b.name)
        : b.name.compareTo(a.name));
  }

  void _sortBySharedUsers() {
    isSharedUsersAscending.value = !isSharedUsersAscending.value;
    _sortItems((a, b) {
      final aUsers = _getSharedUsersCount(a);
      final bUsers = _getSharedUsersCount(b);
      return isSharedUsersAscending.value
          ? aUsers.compareTo(bUsers)
          : bUsers.compareTo(aUsers);
    });
  }

  void _sortByDate() {
    isDateAscending.value = !isDateAscending.value;
    _sortItems((a, b) => isDateAscending.value
        ? a.modifiedAt.compareTo(b.modifiedAt)
        : b.modifiedAt.compareTo(a.modifiedAt));
  }

  // 헬퍼 메서드들
  void _sortItems(
      int Function(FolderContentModel a, FolderContentModel b) compare) {
    final sortedItems = List<FolderContentModel>.from(items);
    sortedItems.sort(compare);
    items.value = sortedItems;
  }

  int _getSharedUsersCount(FolderContentModel item) {
    return projectList.value
            ?.firstWhereOrNull((p) => p.id == item.id)
            ?.sharedUsers
            ?.length ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => ListHeader(
              onSortByName: _sortByName,
              onSortBySharedUsers: _sortBySharedUsers,
              onSortByDate: _sortByDate,
              isNameAscending: isNameAscending.value,
              isSharedUsersAscending: isSharedUsersAscending.value,
              isDateAscending: isDateAscending.value,
            )),
        Obx(() => _buildListView()),
      ],
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: items.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) =>
          _buildDraggableItem(context, items[index]),
    );
  }

  Widget _buildDraggableItem(BuildContext context, FolderContentModel item) {
    return DragTarget<FolderContentModel>(
      builder: (context, candidateData, rejectedData) {
        return Draggable<FolderContentModel>(
          data: item,
          feedback: _buildDragFeedback(context, item),
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: _buildListItem(context, item, false),
          ),
          child: _buildListItem(context, item, candidateData.isNotEmpty),
        );
      },
      onWillAcceptWithDetails: (details) =>
          details.data != item && item.isFolder,
      onAcceptWithDetails: (details) => onDragAccepted(details.data, item),
    );
  }

  Widget _buildListItem(
      BuildContext context, FolderContentModel item, bool isTargeted) {
    return GestureDetector(
      onTap: () => item.isProject
          ? context.go('${EditorPage.route}?p=${item.id}')
          : navigateToFolder(item),
      child: Container(
        decoration: BoxDecoration(
          color: isTargeted ? Colors.green.withAlpha(26) : null,
          border: isTargeted ? Border.all(color: Colors.green, width: 1) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              item.isFolder ? Icons.folder : Icons.article,
              color: isTargeted
                  ? Colors.green
                  : (item.isFolder ? Colors.blue : Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Text(item.name, overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 2,
              child: item.isOwner
                  ? Text('fixed_layout'.tr)
                  : Text('shared_project'.tr),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  if (item.isProject) ...[
                    Obx(() {
                      final project = projectList.value?.firstWhereOrNull(
                        (p) => p.id == item.id,
                      );
                      final sharedUsers = project?.sharedUsers ?? [];
                      if (sharedUsers.isEmpty) {
                        // return CircleAvatar(
                        //   radius: 12,
                        //   backgroundColor: Colors.blue[100],
                        //   child: Text(
                        //     (project?.displayName.characters.firstOrNull ??
                        //             project?.userId.characters.firstOrNull ??
                        //             '나'.characters.first)
                        //         .toUpperCase(),
                        //     style: const TextStyle(color: Colors.blue),
                        //   ),
                        // );
                      }
                      return Stack(
                        children: [
                          Row(
                            children: [
                              Text(
                                sharedUsers.length.toString(),
                              ),
                              SizedBox(
                                width: sharedUsers.length > 4
                                    ? 120
                                    : (sharedUsers.length * 20 + 12),
                                height: 24,
                                child: Stack(
                                  children: [
                                    for (var i = 0;
                                        i < sharedUsers.length.clamp(0, 4);
                                        i++)
                                      Positioned(
                                        left: i * 20.0,
                                        child: Tooltip(
                                          message:
                                              sharedUsers[i].displayName ?? '',
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.blue[100],
                                            child: Text(
                                              (sharedUsers[i].displayName ??
                                                      'A')
                                                  .characters
                                                  .first
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.blue),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (sharedUsers.length > 4)
                                      Positioned(
                                        left: 80,
                                        child: PopupMenuButton<void>(
                                          color: Colors.white,
                                          tooltip: 'more_items'.tr,
                                          padding: EdgeInsets.zero,
                                          position: PopupMenuPosition.under,
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '+${sharedUsers.length - 4}',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          itemBuilder: (context) =>
                                              <PopupMenuEntry<void>>[
                                            PopupMenuItem<void>(
                                              enabled: false,
                                              height: 40,
                                              child: Text(
                                                'shared_users'.tr,
                                                style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const PopupMenuDivider(),
                                            PopupMenuItem<void>(
                                              enabled: false,
                                              height: sharedUsers.length > 4
                                                  ? 200.0
                                                  : 40.0,
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                  maxHeight: 200,
                                                ),
                                                child: SingleChildScrollView(
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children:
                                                        sharedUsers.map((user) {
                                                      return Container(
                                                        height: 45,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4),
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 12,
                                                              backgroundColor:
                                                                  Colors.blue[
                                                                      100],
                                                              child: Text(
                                                                (user.displayName ??
                                                                        'A')
                                                                    .characters
                                                                    .first
                                                                    .toUpperCase(),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    user.displayName ??
                                                                        'Unknown',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                  Text(
                                                                    user.email ??
                                                                        '',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                              .grey[
                                                                          600],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child:
                  Text(DateFormat('yyyy-MM-dd HH:mm').format(item.modifiedAt)),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.isProject)
                    IconButton(
                      icon: const Icon(Icons.history, color: Colors.grey),
                      tooltip: 'project_history'.tr,
                      onPressed: () {
                        onHistoryTap(item.id);
                        final RenderBox button =
                            context.findRenderObject() as RenderBox;
                        final Offset offset = button.localToGlobal(Offset.zero);
                        showMenu(
                          color: Colors.white,
                          context: context,
                          constraints: const BoxConstraints(
                            minWidth: 500,
                            maxWidth: 500,
                          ),
                          position: RelativeRect.fromLTRB(
                            offset.dx,
                            offset.dy + button.size.height,
                            offset.dx + button.size.width,
                            offset.dy + button.size.height,
                          ),
                          items: buildHistoryMenuItems(
                            context: context,
                            history: projectHistory,
                            projectId: item.id,
                          ),
                        );
                      },
                    ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    tooltip: '',
                    itemBuilder: (context) => buildMenuItems(
                      context: context,
                      item: item,
                      isProject: item.isProject,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragFeedback(BuildContext context, FolderContentModel item) {
    return Opacity(
      opacity: 0.7,
      child: Material(
        child: SizedBox(
          width: 400,
          height: 50,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  item.isFolder ? Icons.folder : Icons.article,
                  color: (item.isFolder ? Colors.blue : Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Text(item.name, overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  flex: 2,
                  child: Text('fixed_layout'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ListHeader extends StatelessWidget {
  final VoidCallback onSortByName;
  final VoidCallback onSortBySharedUsers;
  final VoidCallback onSortByDate;
  final bool isNameAscending;
  final bool isSharedUsersAscending;
  final bool isDateAscending;

  const ListHeader({
    super.key,
    required this.onSortByName,
    required this.onSortBySharedUsers,
    required this.onSortByDate,
    required this.isNameAscending,
    required this.isSharedUsersAscending,
    required this.isDateAscending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),
          // const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: _textIconRow(
              context,
              'epub_title'.tr,
              onSortByName,
              isNameAscending,
            ),
          ),
          Expanded(
            flex: 2,
            child: _textIconRow(
              context,
              'attribute'.tr,
              null,
              null,
            ),
          ),
          Expanded(
            flex: 2,
            child: _textIconRow(
              context,
              'shared_title'.tr,
              onSortBySharedUsers,
              isSharedUsersAscending,
            ),
          ),
          Expanded(
            flex: 2,
            child: _textIconRow(
              context,
              'project_sort_by_date'.tr,
              onSortByDate,
              isDateAscending,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'sort_by_view'.tr,
              style: context.bodyMedium?.copyWith(color: context.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textIconRow(
    BuildContext context,
    String text,
    Function()? onTap,
    bool? isAscending,
  ) {
    return Row(
      children: [
        Text(
          text,
          style: context.bodyMedium?.copyWith(color: context.onSurface),
        ),
        const SizedBox(width: 4),
        if (onTap != null)
          IconButton(
            onPressed: onTap,
            icon: Icon(
              isAscending == null
                  ? Icons.swap_vert
                  : (isAscending ? Icons.arrow_upward : Icons.arrow_downward),
              size: 16,
              color: Colors.grey,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 20, height: 20),
            splashRadius: 15,
          )
        else
          const SizedBox(width: 20),
      ],
    );
  }
}

// 공유 사용자 아바타 위젯
class SharedUserAvatar extends StatelessWidget {
  final UserModel user;
  final double radius;

  const SharedUserAvatar({
    super.key,
    required this.user,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue[100],
      child: Text(
        (user.displayName ?? 'A').characters.first.toUpperCase(),
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }
}

// 공유 사용자 정보 위젯
class SharedUserInfo extends StatelessWidget {
  final UserModel user;

  const SharedUserInfo({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          user.displayName ?? 'Unknown',
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          user.email ?? '',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
