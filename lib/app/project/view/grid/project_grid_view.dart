import 'package:api/api.dart';
import 'package:app/app/project/controller/project_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../editor/editor_page.dart';
import '../common/project_view_types.dart';

class ProjectGridView extends StatelessWidget {
  final List<FolderContentModel> items;
  final ProjectMenuBuilder buildMenuItems;
  final HistoryMenuBuilder buildHistoryMenuItems;
  final NavigateToFolderCallback navigateToFolder;
  final ProjectDragCallback onDragAccepted;
  final ProjectHistoryCallback onHistoryTap;
  final String baseUrl;
  final Rxn<List<HistoryModel>?> projectHistory;
  // final Rxn<List<ExportHistoryModel>?> projectHistoryExport;
  final Rxn<List<HistoryModel>?> projectHistoryExport;
  final bool visibleHistory;
  final String currentFolderId;

  const ProjectGridView({
    super.key,
    required this.items,
    required this.buildMenuItems,
    required this.buildHistoryMenuItems,
    required this.navigateToFolder,
    required this.onDragAccepted,
    required this.onHistoryTap,
    required this.baseUrl,
    required this.projectHistory,
    required this.projectHistoryExport,
    required this.visibleHistory,
    required this.currentFolderId,
  });

  String _getProjectImageUrl(String projectId) {
    return '${baseUrl}user/project/$projectId/cover.png';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 16,
        runSpacing: 16,
        children: items
            .map((item) => SizedBox(
                  width: 220,
                  height: 281,
                  child: _buildDraggableItem(context, item),
                ))
            .toList(),
      ),
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
            child: _buildGridItem(context, item, false),
          ),
          child: _buildGridItem(context, item, candidateData.isNotEmpty),
        );
      },
      onWillAcceptWithDetails: (details) =>
          details.data != item && item.isFolder,
      onAcceptWithDetails: (details) => onDragAccepted(details.data, item),
    );
  }

  Widget _buildGridItem(
      BuildContext context, FolderContentModel item, bool isTargeted) {
    if (item.isProject) {
      final projectId = item.id;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: HoverableAnimatedTap(
              onTap: () => context.go('${EditorPage.route}?p=${item.id}'),
              child: VulcanXImageChip(
                imageUrl: _getProjectImageUrl(projectId),
                width: 175,
                height: 210,
                chipLabel: null, //Text('fixed_layout'.tr),
                isOwner: item.isOwner,
              ),
            ),
          ),
          VulcanXLabelMoreMenu(
            label: item.name,
            trailing: Visibility(
              visible: visibleHistory,
              child: VulcanXMoreMenu(
                backgroundColor: Colors.white,
                tooltip: 'project_history'.tr,
                icon: IconButton(
                  onPressed: () {
                    onHistoryTap(item.id);
                    final RenderBox button =
                        context.findRenderObject() as RenderBox;
                    final Offset offset = button.localToGlobal(Offset.zero);
                    showMenu(
                      color: Colors.white,
                      context: context,
                      constraints: const BoxConstraints(
                        minWidth: 200,
                        maxWidth: 500,
                        minHeight: 50,
                        maxHeight: 200,
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
                  icon: const Icon(
                    Icons.history,
                    color: Colors.grey,
                  ),
                ),
                items: buildHistoryMenuItems(
                  context: context,
                  history: projectHistory,
                  projectId: item.id,
                ),
              ),
            ),
            items: buildMenuItems(
              context: context,
              item: item,
              isProject: true,
            ),
          ),
          Visibility(
            visible: !visibleHistory,
            child: const SizedBox.shrink(),
          ),
          Text(item.modifiedAt.toReadableString()),
        ],
      );
    }

    return GestureDetector(
      onTap: () => navigateToFolder(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: VulcanXRoundedContainer.grey(
              width: 175,
              height: 210,
              child: Stack(
                children: [
                  Center(
                    child: CommonAssets.image.folder.image(),
                  ),
                  if (isTargeted)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
            ),
          ),
          VulcanXLabelMoreMenu(
            label: item.name,
            items: buildMenuItems(
              context: context,
              item: item,
              isProject: false,
            ),
          ),
          Text('${item.contentLength} items'),
        ],
      ),
    );
  }

  Widget _buildDragFeedback(BuildContext context, FolderContentModel item) {
    return Opacity(
      opacity: 0.7,
      child: Material(
        child: SizedBox(
          width: 210,
          height: 271,
          child: _buildGridItem(context, item, false),
        ),
      ),
    );
  }
}
