import 'package:app_ui/app_ui.dart';
import 'package:author_editor/mixins/cloud_connection_mixin.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../dialog/editor_export_dialog.dart';

class EditorDocumentDrive extends StatelessWidget
    with EditorEventbus, CloudConnectionMixin {
  EditorDocumentDrive({super.key});

  final popupController = PopupMenuBarController();
  final popupMenuBarKey = GlobalKey<PopupMenuBarState>();

  @override
  Widget build(BuildContext context) {
    final itemGroups = [
      [
        {
          'label': 'office_epub'.tr,
          'shortcut': CommonAssets.icon.officeEpub.svg(),
          'index': '0'
        },
        {
          'label': '${'office_xhtml'.tr}(xml)',
          'shortcut': CommonAssets.icon.stickyNote2.svg(),
          'index': '1'
        },
        {
          'label': 'office_txt'.tr,
          'shortcut': CommonAssets.icon.stickyNote2.svg(),
          'index': '2'
        },
      ],
    ];

    return Tooltip(
      message: 'cloud_title'.tr,
      child: PopupMenuBar(
        key: popupMenuBarKey,
        alignmentGeometry: Alignment.centerLeft,
        controller: popupController,
        content: _buildMoreMenuContent(context, itemGroups),
        onMenuStateChanged: (showMenu) async {
          if (showMenu) {
            final isConnected = await isCloudConnected();
            if (isConnected != true) {
              controller.triggerCloudConnection();
              return false;
            }
          }
          return true;
        },
        child: IconButton(
            onPressed: null,
            icon:
                // controller.tokenStatus.value
                // ?
                CommonAssets.icon.cloudDone.svg(color: Colors.green)
            // : Icon(
            // Icons.cloud_off_rounded,
            // color: Colors.red,
            // ),
            ),
      ),
    );
  }

  Widget _buildMoreMenuContent(
      BuildContext context, List<List<Map<String, Object>>> itemGroups) {
    return VulcanXRoundedContainer(
      isBoxShadow: true,
      child: PointerInterceptor(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...itemGroups[0].map((item) {
              final index = int.parse(item['index']?.toString() ?? '0');
              final shortcut = item['shortcut'];
              return VulcanXText(
                isHover: true,
                hoverColor: Colors.blue.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(15),
                text: item['label']?.toString() ?? '',
                prefixIcon: shortcut is Widget ? shortcut : null,
                onTap: () {
                  popupMenuBarKey.currentState?.removeOverlay();
                  if (index == 0) {
                    _buildEpubDialog(context);
                  } else if (index == 1) {
                    controller.triggerDriveXhtml();
                  } else if (index == 2) {
                    controller.triggerDriveTxt();
                  }
                  popupController.close();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _buildEpubDialog(BuildContext context) async {
    controller.rxIsDownloadTrigger.value = false;
    VulcanCloseDialogType? result = await VulcanCloseDialogWidget(
      width: 540,
      title: 'office_epub'.tr,
      content: EditorExportDialog(
        projectId: controller.documentState.rxProjectId.value,
        projectName: controller.documentState.rxProjectName.value,
        onExport: (epubData) {
          context.pop();
          return controller.triggerDriveEpub(epubData);
        },
        onExportPdf: () {
          context.pop();
          // return controller.triggerExportPdf();
        },
      ),
    ).show(context);

    if (result == VulcanCloseDialogType.close) {
      controller.rxIsDownloadTrigger.value = false;
      debugPrint('다이얼로그가 닫혔습니다.');
    }
  }
}
