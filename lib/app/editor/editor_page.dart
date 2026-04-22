import 'package:api/api.dart';
import 'package:app/app/login/view/login_controller.dart';
import 'package:app/app/login/view/tenant_setting_controller.dart';
import 'package:author_editor/vulcan_editor.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cotroller/editor_controller.dart';

class EditorPage extends GetView<EditorController> {
  static const String route = '/editor';
  final LoginController loginController = Get.find<LoginController>();
  final TenantSettingController tenantSettingController =
      Get.find<TenantSettingController>();

  final String? folderId;
  final String? projectId;
  final String? pageId;
  final String? templateId;
  final String? displayType;

  EditorPage({
    super.key,
    this.folderId,
    this.projectId,
    this.pageId,
    this.templateId,
    this.displayType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<EditorController>(
          init: controller,
          dispose: (state) {
            Get.delete<EditorController>();
          },
          initState: (state) {
            // 비동기 작업을 위젯 빌드 후에 실행
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.init(
                  displayType: displayType,
                  projectId: projectId,
                  pageId: pageId,
                  context: context);
            });
          },
          builder: (controller) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Obx(() => VulcanEditor(
                  baseUrl: ApiDio.apiHostAppServer,
                  // baseUrl: AutoConfig.instance.domainType.originWithPath,
                  fontUrl: AutoConfig.instance.domainType.fontUrl,
                  data: controller.rxVulcanEditorData.value,
                  templateId: templateId,
                  initialFolderId: folderId,
                  isDownload: controller.rxIsDownload.value,
                  onCreatedProject: (projectData) =>
                      controller.createProject(context, projectData),
                  onCreatePage: (value) => controller.createPage(value),
                  onDeletePage: (value) =>
                      controller.deletePage(value, context),
                  onCopyPage: (value) => controller.copyPage(value),
                  onMovePage: (value) => controller.movePage(value),
                  onRenamePage: (value) => controller.renamePage(value),
                  onTempSavePage: (value) => controller.tempSave(value),
                  onTempSaveCheck: (projectId, pageId, pageUrl) =>
                      controller.checkTempSaveData(projectId, pageId, context),
                  onRemoveTempSaveData: (projectId) =>
                      controller.removeTempSaveData(projectId),
                  onPlacementPropertyPage: (currentPage, value) =>
                      controller.placementPropertyPage(currentPage, value),
                  onUploadFile: (currentPage, formData) =>
                      controller.uploadFile(currentPage, formData),
                  onUpdatePageContent: (value) =>
                      controller.updatePageContent(value),
                  onUpdateToc: (value) => controller.updateToc(value),
                  onConvertTocToNormal: (projectId, pageId) =>
                      controller.convertTocToNormal(projectId, pageId),
                  onShortUrl: (value) => controller.shortUrl(context, value),
                  onUpdateProjectAuth: (value) =>
                      controller.updateProjectAuth(value),
                  onAddUser: (currentPage, value) =>
                      controller.addUser(currentPage, value, context),
                  onDeleteUser: (value) => controller.deleteUser(value),
                  onGetUserList: (value) => controller.getUserList(value),
                  onClipArt:
                      (projectId, currentPage, path, type, clipartType) =>
                          controller.clipArt(
                              projectId, currentPage, path, type, clipartType),
                  onActivePage: (value) => controller.activePage(value),
                  onAddWidget: (currentPage, value) =>
                      controller.addWidget(currentPage, value),
                  onEditPermission: (currentPage, value) =>
                      controller.editPermission(currentPage, value),
                  onSetStartPage: (currentPage, value) =>
                      controller.setStartPage(currentPage, value),
                  onExportEpub: (value) => controller.exportEpub(value),
                  // onExportPdf: (projectId) => controller.exportPdf(projectId),
                  onExportTxt: (value) => controller.exportTxt(value),
                  onExportXhtml: (value) => controller.exportXhtml(value),
                  onCloudConnection: () =>
                      controller.onCloudConnection(context),
                  onUploadEpub: (value, {folderId}) =>
                      controller.uploadEpubToDrive(value, folderId: folderId),
                  onUploadXhtml: (value, {folderId}) =>
                      controller.uploadXhtmlToDrive(value, folderId: folderId),
                  onUploadTxt: (value, {folderId}) =>
                      controller.uploadTxtToDrive(value, folderId: folderId),
                  onCreatePageWithContent: (value) =>
                      controller.createPageWithContent(value),
                  onSetCoverPage: (currentPage, value) =>
                      controller.setCoverPage(currentPage, value),
                  onUnsetCoverPage: (currentPage, value) =>
                      controller.unsetCoverPage(currentPage, value),
                  onUpdateListNumbering: (value) =>
                      controller.updateListNumbering(value),
                  onCreateThumbnail: (currentPage, value) =>
                      controller.createThumbnail(currentPage, value),
                  tenantSetting: tenantSettingController.getTenantSettingMap(),
                ));
          }),
    );
  }
}
