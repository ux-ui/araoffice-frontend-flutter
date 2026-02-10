import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../dialog/editor_share_dialog.dart';
import '../vulcan_editor_eventbus.dart';

class PagePanel extends StatefulWidget {
  const PagePanel({super.key});

  @override
  State<PagePanel> createState() => _PagePanelState();
}

class _PagePanelState extends State<PagePanel> with EditorEventbus {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PagePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => TreeListWidget(
          ownerId: controller.documentState.rxProjectOwner.value,
          startPageId: controller.documentState.rxStartPageId.value,
          hasCover: controller.documentState.rxHasCover.value,
          hasToc: controller.documentState.rxHasToc.value,
          onlyPageSelection: !controller.rxIsOwner.value,
          showEditorUser: controller.rxShowEditorUser.value,
          selectedPageId: controller.documentState.rxPageCurrent.value?.id,
          initialPages: controller.documentState.rxPages.toList(),
          onPageClick: (page) => controller.changePageTreeList(page),
          onAddPage: (parentId) => controller.triggerCreatePage(parentId),
          onDeletePage: (page) => controller.triggerDeletePage(page),
          onUpdatePageTitle: (page, newTitle) =>
              controller.triggerRenamePage(page, newTitle),
          onPageMove: (movedPage, targetPage, position) =>
              controller.triggerMovePage(movedPage, targetPage, position),
          onCopyPage: (page) => controller.triggerCopyPage(page),
          //onPagesToHtml: (value) => controller.triggerUpdateToc(value),
          onPagesToJson: (value) => controller.updateTreeWidgetTocJson(value),
          onActivePage: (type, isActive) =>
              controller.triggerActivePage(type, isActive),
          onAddContentsIcon: (position) => controller.addContentsIcon(position),
          onEditPermission: (page) => _showEditPermissionDialog(page),
          onSetStartPage: (page) => controller.triggerSetStartPage(page),
          onSetCoverPage: (page) => controller.triggerSetCoverPage(page.id),
          onUnsetCoverPage: (page) => controller.triggerUnsetCoverPage(page.id),
          onOpenDocument: controller.rxIsOwner.isTrue
              ? () => controller.openDocument(context)
              : null,
          onMemo: (page) => controller.openMemoPopup(context, page),
          onCreateThumbnail: (page) => controller.triggerCreateThumbnail(page),
          currentUserId: controller.documentState.rxUserId.value,
          onViewColumn: () => controller.viewColumn(),
          viewColumn: controller.rxViewColumn.value,
          isEditingPermission: controller.isEditingPermission.isTrue,
        ));
  }

  Future<void> _showEditPermissionDialog(TreeListModel page) async {
    await VulcanCloseDialogWidget(
      width: 450,
      //title: '${'page_edit_permission'.tr} - ${page.title}',
      title: 'page_edit_permission'.tr,
      content: EditorShareDialog(
        projectId: controller.documentState.rxProjectId.value,
        page: page,
        isUserDeleted: false,
        userList: controller.rxShareUserList,
        onGetUserList: (projectId) {
          Get.back();
          controller.triggerGetUserList(projectId);
        },
        onEditPermission: (user) {
          user;
          context.pop();
          controller.triggerEditPermission(page.id, user.userId!);
        },
      ),
    ).show(context);
  }
}
