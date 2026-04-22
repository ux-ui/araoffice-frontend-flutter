import 'package:app_ui/app_ui.dart';
import 'package:author_editor/dialog/editor_share_dialog.dart';
import 'package:author_editor/extension/extensions.dart';
import 'package:author_editor/menu/editor_device_icon_menu.dart';
import 'package:author_editor/menu/editor_document_drive.dart';
import 'package:common_assets/common_assets.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../engine/math/iframe_editor_widget.dart';
import '../menu/editor_document_export.dart';
import '../menu/editor_document_zoom.dart';
import '../menu/editor_history_stack_icon_menu.dart';
import '../vulcan_editor_eventbus.dart';

class EditorAppBar extends StatelessWidget with EditorEventbus {
  EditorAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.0,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Obx(
        () => Row(
          children: [
            // EditorFileMenu(),
            // 대시보드로 이동
            IconButton(
              onPressed: () => controller.gotoHome(context),
              icon: CommonAssets.icon.arrowBack.svg(),
              tooltip: 'go_dashboard'.tr,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoConfig.instance.domainType.isDferiDomain
                  ? CommonAssets.image.booknaviIcon
                      .image(width: 24.0, height: 24.0)
                  : CommonAssets.icon.dabondaSymbol
                      .svg(width: 24.0, height: 24.0),
            ),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      controller.documentState.rxProjectName.value.truncate(10),
                      style: context.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                        ' - ${controller.documentState.rxPageCurrent.value?.title.processTranslation().truncate(10) ?? ''}',
                        style: context.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                )),
            if (!controller.isEditingPermission.value) const Spacer(),
            if (controller.isEditingPermission.value) ...[
              EditorHistoryStackIconMenu(),
              const Spacer(),
              EditorDeviceIconMenu(controller: controller),
              const SizedBox(width: 10),
            ],
            EditorDocumentZoom(),
            const Spacer(),
            IconButton(
              onPressed: () => _showWebViewDialog(context),
              icon: CommonAssets.icon.visibility.svg(),
              tooltip: 'preview'.tr,
            ),
            Visibility(
              visible: controller.rxIsOwner.value,
              child: Row(
                children: [
                  Container(
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: VerticalDivider(
                      color: context.outline,
                      thickness: 1,
                      width: 1,
                    ),
                  ),
                  // 프로젝트 저장하기 버튼
                  // if (controller.cloudProjectSaveStatus.value) ...[
                  //   IconButton(
                  //     onPressed: () => _buildEpubDialog(context),
                  //     icon: const Icon(Icons.save_outlined),
                  //     tooltip: 'file_save'.tr,
                  //   ),
                  // ],

                  // 공유 하기

                  Obx(
                    () => Visibility(
                      visible: controller.shareStatus.value,
                      child: IconButton(
                        onPressed: () async {
                          await VulcanCloseDialogWidget(
                            width: 540,
                            title: 'share'.tr,
                            content: EditorShareDialog(
                              // 사용자 추가
                              // 액세스 권한
                              // 공유링크 생성 + 복사
                              // 공유된 사용자 리스트 가져오기
                              projectId:
                                  controller.documentState.rxProjectId.value,
                              userList: controller.rxShareUserList,
                              onGetUserList: (projectId) {
                                context.pop();
                                controller.triggerGetUserList(projectId);
                              },
                            ),
                          ).show(context);
                        },
                        icon: CommonAssets.icon.shareOff.svg(),
                        tooltip: 'share'.tr,
                      ),
                    ),
                  ),

                  // works 타입일 때만 노출
                  // if (controller.rxTenantType.value == TenantType.msit ||
                  //     AutoConfig.instance.domainType.isMsitDomain)
                  if (controller.cloudProjectSaveStatus.value)
                    EditorDocumentDrive(),
                  EditorDocumentExoprt(),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _buildEpubDialog(BuildContext context) async {
    controller.rxIsDownloadTrigger.value = false;
    // VulcanCloseDialogType? result = await VulcanCloseDialogWidget(
    //   width: 540,
    //   title: 'office_epub'.tr,
    //   content: EditorExportDialog(
    //     projectId: controller.documentState.rxProjectId.value,
    //     projectName: controller.documentState.rxProjectName.value,
    //     onExport: (epubData) {
    //       context.pop();
    //       return controller.triggerExportEpub(epubData);
    //     },
    //     onExportPdf: () {
    //       context.pop();
    //       return controller.triggerExportPdf();
    //     },
    //   ),
    // ).show(context);

    // if (result == VulcanCloseDialogType.close) {
    //   controller.rxIsDownloadTrigger.value = false;
    //   debugPrint('다이얼로그가 닫혔습니다.');
    // }

    // if (controller.rxUserLoginType.value == UserLoginType.naverWorks ||
    //     controller.rxUserLoginType.value == UserLoginType.naver_works) {
    if (controller.rxTenantType.value == TenantType.naverWorks ||
        controller.rxTenantType.value == TenantType.mois ||
        controller.rxTenantType.value == TenantType.msit ||
        controller.rxTenantType.value == TenantType.mfds ||
        controller.rxTenantType.value == TenantType.dferi ||
        controller.rxTenantType.value == TenantType.gov ||
        controller.rxTenantType.value == TenantType.standard) {
      // naverWorks 로그인 처리
      final result = await controller.saveAraProject();
      if (result) {
        if (context.mounted) {
          await VulcanCloseDialogWidget(
            isShowConfirm: false,
            isShowCancel: false,
            width: 300,
            title: 'file_save'.tr,
            content: Text(controller.rxTenantType.value == TenantType.dferi
                ? 'dferi_project_save_success'.tr
                : 'ara_project_save_success'.tr),
          ).show(context);
          if (context.mounted) {
            await controller.gotoHome(context);
          }
        }
        return;
      }
      // } else if (controller.rxUserLoginType.value == UserLoginType.araEbook) {
      //   // araService 로그인 처리
      // } else if (controller.rxUserLoginType.value == UserLoginType.brityWorks) {
      // brity 로그인 처리
    } else {
      // common 로그인 처리
      // VulcanCloseDialogType? result = await VulcanCloseDialogWidget(
      //   width: 540,
      //   title: 'office_epub'.tr,
      //   content: EditorExportDialog(
      //     projectId: controller.documentState.rxProjectId.value,
      //     projectName: controller.documentState.rxProjectName.value,
      //     onExport: (epubData) {
      //       context.pop();
      //       return controller.triggerExportEpub(epubData);
      //     },
      //     onExportPdf: () {
      //       context.pop();
      //       return controller.triggerExportPdf();
      //     },
      //   ),
      // ).show(context);

      // if (result == VulcanCloseDialogType.close) {
      //   controller.rxIsDownloadTrigger.value = false;
      // }
    }
  }

  Future<void> _showWebViewDialog(BuildContext context) async {
    await controller.savePreviewData();
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.9;
    final contentHeight = dialogHeight - 100;

    final pages = List<TreeListModel>.from(controller.documentState.rxPages);
    final initialCurrentPage = controller.documentState.rxPageCurrent.value;

    int currentPageIndex = 0;
    if (initialCurrentPage != null) {
      currentPageIndex =
          pages.indexWhere((page) => page.id == initialCurrentPage.id);
      if (currentPageIndex == -1) currentPageIndex = 0;
    }

    final rxCurrentPageIndex = currentPageIndex.obs;
    final rxCurrentPageUrl = controller.rxPageUrl.value.obs;

    bool canGoPrevious() => rxCurrentPageIndex.value > 0;
    bool canGoNext() => rxCurrentPageIndex.value < pages.length - 1;

    String extractFileName(String value) {
      if (value.isEmpty) {
        return '';
      }

      try {
        final uri = Uri.parse(value);
        if (uri.pathSegments.isNotEmpty) {
          return Uri.decodeComponent(uri.pathSegments.last);
        }
      } catch (_) {}

      final noHash = value.split('#').first;
      final noQuery = noHash.split('?').first;
      return Uri.decodeComponent(noQuery.split('/').last);
    }

    final validInternalHrefs = pages
        .map((page) => extractFileName(page.href).toLowerCase())
        .where((href) => href.isNotEmpty)
        .toSet();

    void syncCurrentPageByUrl(String currentUrl) {
      final currentFile = extractFileName(currentUrl);
      if (currentFile.isEmpty) {
        return;
      }

      final matchedIndex = pages.indexWhere(
        (page) => extractFileName(page.href) == currentFile,
      );

      if (matchedIndex >= 0) {
        if (matchedIndex != rxCurrentPageIndex.value) {
          rxCurrentPageIndex.value = matchedIndex;
        }

        final matchedPage = pages[matchedIndex];
        final matchedPageUrl = controller.documentState.getBuildTypeUrl(
          controller.documentState.rxProjectId.value,
          matchedPage.href,
        );
        if (rxCurrentPageUrl.value != matchedPageUrl) {
          rxCurrentPageUrl.value = matchedPageUrl;
        }
      }
    }

    void goToPrevious() {
      if (canGoPrevious()) {
        rxCurrentPageIndex.value--;
        final previousPage = pages[rxCurrentPageIndex.value];
        rxCurrentPageUrl.value = controller.documentState.getBuildTypeUrl(
          controller.documentState.rxProjectId.value,
          previousPage.href,
        );
      }
    }

    void goToNext() {
      if (canGoNext()) {
        rxCurrentPageIndex.value++;
        final nextPage = pages[rxCurrentPageIndex.value];
        rxCurrentPageUrl.value = controller.documentState.getBuildTypeUrl(
          controller.documentState.rxProjectId.value,
          nextPage.href,
        );
      }
    }

    await VulcanCloseDialogWidget(
      isShowConfirm: false,
      isShowCancel: false,
      width:
          (controller.documentState.rxDocumentSizeWidth.value + 100).toDouble(),
      height: dialogHeight + 50,
      title: 'preview'.tr,
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 네비게이션 버튼들
                Obx(() => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: canGoPrevious() ? goToPrevious : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: canGoNext() ? goToNext : null,
                        ),
                      ],
                    )),
              ],
            ),
            Container(
              width:
                  controller.documentState.rxDocumentSizeWidth.value.toDouble(),
              height: contentHeight,
              alignment: Alignment.center,
              child: Obx(() => IFrameEditorWidget(
                    key: ValueKey(rxCurrentPageUrl.value),
                    url: rxCurrentPageUrl.value,
                    fontUrl: AutoConfig.instance.domainType.fontUrl,
                    validInternalHrefs: validInternalHrefs,
                    invalidInternalLinkMessage:
                        'preview_invalid_internal_link'.tr,
                    onPageUrlChanged: syncCurrentPageByUrl,
                    width: controller.documentState.rxDocumentSizeWidth.value
                        .toDouble(),
                    height: contentHeight,
                    documentWidth: controller
                        .documentState.rxDocumentSizeWidth.value
                        .toDouble(),
                    documentHeight: controller
                        .documentState.rxDocumentSizeHeight.value
                        .toDouble(),
                  )),
            ),
          ],
        ),
      ),
    ).show(context);
  }
}
