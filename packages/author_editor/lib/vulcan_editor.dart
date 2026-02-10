// import 'package:app/app/project/controller/project_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:author_editor/dialog/editor_new_document_dialog.dart';
import 'package:author_editor/dialog/editor_project_setting_dialog.dart';
import 'package:author_editor/drawer/animated_container_drawer.dart';
import 'package:author_editor/editor_event_manager.dart';
import 'package:author_editor/engine/editor_integration.dart';
import 'package:author_editor/panel/page_attribute_panel.dart';
import 'package:author_editor/panel/page_panel.dart';
import 'package:author_editor/vulcan_editor_controller.dart';
import 'package:author_editor/web_socket/user_cursor_widget.dart';
import 'package:common_util/common_util.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'data/datas.dart';
import 'dialog/editor_template_dialog.dart';
import 'enum/enums.dart';
import 'utill/naver_works_drive_picker.dart';
import 'view/editor_app_bar.dart';
import 'view/editor_navigation_nail.dart';

class VulcanEditor extends StatefulWidget {
  final VulcanEditorData data;
  final String baseUrl;
  final String fontUrl;
  final bool isDownload;
  final String? templateId;
  final String? initialFolderId;

  final ValueChanged<VulcanProjectSettingData>? onCreatedProject;
  // final ValueChanged<Map<String, String?>>? onCreatePage;
  // final ValueChanged<Map<String, String>>? onDeletePage;
  final Future<void> Function(Map<String, String?>)? onCreatePage;
  final Future<void> Function(Map<String, String>)? onDeletePage;
  // final ValueChanged<Map<String, String>>? onDeletePage;
  final Function(TreeListModel, dio.FormData)? onUploadFile;
  final ValueChanged<Map<String, String>>? onUpdatePageContent;
  final ValueChanged<Map<String, String>>? onCopyPage;
  final ValueChanged<Map<String, String>>? onMovePage;
  final ValueChanged<Map<String, String>>? onRenamePage;
  final Function(TreeListModel, Map<String, String>)? onPlacementPropertyPage;
  final ValueChanged<Map<String, String>>? onTempSavePage;
  final Function(TreeListModel, Map<String, String>)? onAddWidget;
  final Function(String, TreeListModel, String, String, String)? onClipArt;
  final ValueChanged<String>? onShortUrl;

  final ValueChanged<VulcanEpubData>? onExportEpub;
  // final ValueChanged<String>? onExportPdf;
  final ValueChanged<VulcanXhtmlData>? onExportXhtml;
  final ValueChanged<VulcanTxtData>? onExportTxt;

  final VoidCallback? onCloudConnection;
  final void Function(VulcanEpubData, {String? folderId})? onUploadEpub;
  final void Function(VulcanXhtmlData, {String? folderId})? onUploadXhtml;
  final void Function(VulcanTxtData, {String? folderId})? onUploadTxt;

  final ValueChanged<Map<String, String>>? onActivePage;
  final Function(TreeListModel, Map<String, String>)? onEditPermission;
  final Function(TreeListModel, Map<String, String>)? onSetStartPage;
  final Function(String, String, String)? onTempSaveCheck;
  final Future<bool?> Function(Map<String, String>)? onCreatePageWithContent;
  final Function(TreeListModel?, Map<String, String>)? onSetCoverPage;
  final Function(TreeListModel?, Map<String, String>)? onUnsetCoverPage;

  final ValueChanged<Map<String, String>>? onUpdateProjectAuth;
  final Function(TreeListModel, Map<String, String>)? onAddUser;
  final ValueChanged<Map<String, String>>? onDeleteUser;
  final ValueChanged<String>? onGetUserList;
  final Function(Map<String, String>)? onUpdateToc;

  final Map<String, dynamic>? tenantSetting;

  // TOC 관련 콜백 추가
  final Function(String, String)? onConvertTocToNormal;

  final Function(Map<String, String>)? onUpdateListNumbering;
  final Function(String)? onRemoveTempSaveData;
  final Function(TreeListModel?, Map<String, String>)? onCreateThumbnail;
  const VulcanEditor({
    super.key,
    required this.data,
    required this.baseUrl,
    required this.fontUrl,
    this.templateId,
    this.initialFolderId,
    this.isDownload = false,
    this.onCreatedProject,
    this.onCreatePage,
    this.onDeletePage,
    this.onRenamePage,
    this.onPlacementPropertyPage,
    this.onUploadFile,
    this.onUpdatePageContent,
    this.onTempSavePage,
    this.onAddWidget,
    this.onCopyPage,
    this.onMovePage,
    this.onClipArt,
    this.onShortUrl,
    this.onExportEpub,
    // this.onExportPdf,
    this.onExportTxt,
    this.onExportXhtml,
    this.onCloudConnection,
    this.onUploadEpub,
    this.onUploadXhtml,
    this.onUploadTxt,
    this.onActivePage,
    this.onUpdateProjectAuth,
    this.onAddUser,
    this.onDeleteUser,
    this.onGetUserList,
    this.onEditPermission,
    this.onSetStartPage,
    this.onTempSaveCheck,
    this.onCreatePageWithContent,
    this.onSetCoverPage,
    this.onUnsetCoverPage,
    this.onUpdateToc,
    this.onConvertTocToNormal,
    this.onUpdateListNumbering,
    this.onRemoveTempSaveData,
    this.onCreateThumbnail,
    this.tenantSetting,
  });

  @override
  State<VulcanEditor> createState() => _VulcanEditorState();
}

class _VulcanEditorState extends State<VulcanEditor> {
  late final VulcanEditorController controller;
  late final EditorEventManager eventManager;
  late String? templateId;

  @override
  void initState() {
    super.initState();

    templateId = widget.templateId;

    controller = Get.put(VulcanEditorController()
      ..display(vulcanEditorData: widget.data, baseUrl: widget.baseUrl));

    controller.onProjectAccessDenied = () {
      if (mounted && context.mounted) _showUnauthorizedDialog(context);
    };

    eventManager = Get.put(EditorEventManager());

    // controller.tenantSetting.value = widget.tenantSetting ?? {};
    // controller.govElementLogoStatus.value =
    //     widget.tenantSetting?['govElementLogoStatus'] ?? false;
    // controller.mathMenuStatus.value =
    //     widget.tenantSetting?['mathMenuStatus'] ?? false;
    // controller.tooggleWidgetStatus.value =
    //     widget.tenantSetting?['tooggleWidgetStatus'] ?? false;
    // controller.tabWidgetStatus.value =
    //     widget.tenantSetting?['tabWidgetStatus'] ?? false;
    // controller.accordionWidgetStatus.value =
    //     widget.tenantSetting?['accordionWidgetStatus'] ?? false;

    controller.initTenantSetting(widget.tenantSetting ?? {});

    ever(controller.createPageTrigger, (Map<String, String?> value) async {
      if (value.isNotEmpty) {
        // widget.onCreatePage?.call(value);
        // controller.createPageTrigger.value = {}; // 리셋
        // try {
        //   await Future(() {
        //     widget.onCreatePage?.call(value);
        //   });
        //   controller.createPageTrigger.value = {}; // 리셋
        //   controller.refreshTree(controller.documentState.rxPages);
        // } catch (e) {
        //   debugPrint('페이지 생성 중 오류 발생: $e');
        // }
        // eventManager.emit(EditorEventType.createPage, value);

        // 페이지 추가 동작 처리
        if (widget.onCreatePage != null) {
          controller.rxIsAvailableAddPage.value = false;
          await widget.onCreatePage!(value).then(
            (value) async {
              controller.rxIsAvailableAddPage.value = true;
              controller.refreshTree(controller.documentState.rxPages);
              await Future.delayed(const Duration(milliseconds: 100));
              final pages = controller.documentState.rxPages;
              if (pages.isNotEmpty) {
                // 가장 최근에 생성된 페이지로 이동
                controller.changePageTreeList(pages.last);
              }
            },
          );
        }
        controller.createPageTrigger.value = {}; // 리셋
      }
    });

    ever(controller.deletePageTrigger, (Map<String, String> value) async {
      if (value.isNotEmpty) {
        // eventManager.emit(EditorEventType.deletePage, value);
        // widget.onDeletePage?.call(value);
        await widget.onDeletePage?.call(value).then(
              (value) =>
                  controller.refreshTree(controller.documentState.rxPages),
            );

        controller.deletePageTrigger.value = {}; // 리셋
      }
    });

    ever(controller.uploadFileTrigger, (dio.FormData? formData) {
      if (formData != null) {
        eventManager.emit(EditorEventType.uploadFile, formData);
        widget.onUploadFile
            ?.call(controller.documentState.rxPageCurrent.value!, formData);
        controller.uploadFileTrigger.value = null; // 리셋
      }
    });

    ever(controller.updatePageContentTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        eventManager.emit(EditorEventType.updatePageContent, value);
        widget.onUpdatePageContent?.call(value);
        controller.updatePageContentTrigger.value = {};
        controller.refreshPage(controller.documentState.rxPageCurrent.value!);
        logger.d('[VulcanEditorController] updatePageContentTrigger callback');
      }
    });

    ever(controller.tempSaveTrigger, (Map<String, String> value) {
      if (value.isNotEmpty && controller.rxIsEditorStatus.value) {
        eventManager.emit(EditorEventType.tempSave, value);
        widget.onTempSavePage?.call(value);
        controller.tempSaveTrigger.value = {};
      }
    });

    ever(controller.copyPageTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        // eventManager.emit(EditorEventType.copyPage, value);
        widget.onCopyPage?.call(value);
        // controller.copyPageTrigger.value = {};

        Future.delayed(const Duration(milliseconds: 150), () {
          controller.copyPageTrigger.value = {};
          controller.refreshTree(controller.documentState.rxPages);
        });
      }
    });

    ever(controller.movePageTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        // eventManager.emit(EditorEventType.movePage, value);
        widget.onMovePage?.call(value);
        // controller.movePageTrigger.value = {};
        Future.delayed(const Duration(milliseconds: 150), () {
          controller.movePageTrigger.value = {};
          controller.refreshTree(controller.documentState.rxPages);
        });
      }
    });

    ever(controller.renamePageTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        // eventManager.emit(EditorEventType.renamePage, value);
        widget.onRenamePage?.call(value);
        controller.renamePageTrigger.value = {};
      }
    });

    ever(controller.placementPropertyTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        eventManager.emit(EditorEventType.placementProperty, value);
        widget.onPlacementPropertyPage
            ?.call(controller.documentState.rxPageCurrent.value!, value);
        controller.placementPropertyTrigger.value = {};
      }
    });

    ever(controller.updateTocTrigger, (Map<String, String> value) async {
      if (value.isNotEmpty) {
        // final result = await controller.compareUserId();
        // if (result) {
        eventManager.emit(EditorEventType.updateToc,
            controller.documentState.rxProjectId.value);
        widget.onUpdateToc?.call(value);
        // }
        controller.updateTocTrigger.value = {};
      }
    });

    ever(controller.rxClipArtTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        final path = value['path'] ?? '';
        final type = value['type'] ?? '';
        final clipartType = value['clipartType'] ?? '';

        widget.onClipArt?.call(
            controller.documentState.rxProjectId.value,
            controller.documentState.rxPageCurrent.value!,
            path,
            type,
            clipartType);
        controller.rxClipArtTrigger.value = {};
        eventManager.emit(EditorEventType.clipArt, value);
      }
    });

    ever(controller.rxShortUrlTrigger, (String url) {
      if (url.isNotEmpty) {
        // eventManager.emit(EditorEventType.shortUrl, url);
        widget.onShortUrl?.call(url);
        controller.rxShortUrlTrigger.value = '';
      }
    });

    ever(controller.activePageTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        // eventManager.emit(EditorEventType.activePage, value);
        widget.onActivePage?.call(value);
        controller.activePageTrigger.value = {};
      }
    });

    ever(controller.rxAddWidgetTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        eventManager.emit(EditorEventType.addWidget, value);
        widget.onAddWidget
            ?.call(controller.documentState.rxPageCurrent.value!, value);
        controller.rxAddWidgetTrigger.value = {};
      }
    });

    ever(controller.updateProjectAuthTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        // eventManager.emit(EditorEventType.updateProjectAuth, value);
        widget.onUpdateProjectAuth?.call(value);
        controller.updateProjectAuthTrigger.value = {};
      }
    });

    ever(controller.addUserTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        // eventManager.emit(EditorEventType.addUser, value);
        widget.onAddUser
            ?.call(controller.documentState.rxPageCurrent.value!, value);
        controller.addUserTrigger.value = {};
      }
    });

    ever(controller.deleteUserTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        // eventManager.emit(EditorEventType.deleteUser, value);
        widget.onDeleteUser?.call(value);
        controller.deleteUserTrigger.value = {};
      }
    });

    ever(controller.getUserListTrigger, (String value) {
      if (value.isNotEmpty) {
        // eventManager.emit(EditorEventType.getUserList, value);
        widget.onGetUserList?.call(value);
        controller.getUserListTrigger.value = '';
      }
    });

    ever(controller.editPermissionTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        // eventManager.emit(EditorEventType.editPermission, value);
        widget.onEditPermission
            ?.call(controller.documentState.rxPageCurrent.value!, value);
        controller.editPermissionTrigger.value = {};
      }
    });

    ever(controller.setStartPageTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        // eventManager.emit(EditorEventType.setStartPage, value);
        widget.onSetStartPage
            ?.call(controller.documentState.rxPageCurrent.value!, value);
        controller.setStartPageTrigger.value = {};
      }
    });

    ever(controller.exportEpubTrigger, (VulcanEpubData? epubData) {
      if (epubData != null) {
        // eventManager.emit(EditorEventType.exportEpub, epubData);
        widget.onExportEpub?.call(epubData);
        controller.exportEpubTrigger.value = null; // 리셋
        EasyLoading.show(
          status: 'epub_export_download_message'.tr,
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false,
        );
      }
    });

    ever(controller.exportTxtTrigger, (VulcanTxtData? txtData) {
      if (txtData != null) {
        widget.onExportTxt?.call(txtData);
        controller.exportTxtTrigger.value = null; // 리셋
        EasyLoading.show(
          status: 'TXT 파일 생성 및 다운로드 중...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false,
        );
      }
    });

    ever(controller.exportXhtmlTrigger, (VulcanXhtmlData? xhtmlData) {
      if (xhtmlData != null) {
        widget.onExportXhtml?.call(xhtmlData);
        controller.exportXhtmlTrigger.value = null; // 리셋
        EasyLoading.show(
          status: 'XHTML 파일 생성 및 다운로드 중...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false,
        );
      }
    });

    // ever(controller.exportPdfTrigger, (String? projectId) {
    //   if (projectId != null) {
    //     // eventManager.emit(EditorEventType.exportPdf, projectId);
    //     widget.onExportPdf?.call(projectId);
    //     controller.exportPdfTrigger.value = null; // 리셋
    //     EasyLoading.show(
    //       status: 'pdf_export_download_message'.tr,
    //       maskType: EasyLoadingMaskType.black,
    //       dismissOnTap: false,
    //     );
    //   }
    // });

    ever(controller.cloudConnectionTrigger, (bool value) {
      if (value == true) {
        widget.onCloudConnection?.call();
        controller.cloudConnectionTrigger.value = false; // 리셋
      }
    });

    ever(controller.uploadEpubTrigger, (VulcanEpubData? epubData) async {
      if (epubData != null) {
        controller.uploadEpubTrigger.value = null; // 리셋

        if (controller.cloudConnectionTrigger.value == true) {
          final result = await NaverWorksDrivePicker.openFolderPickerAsync();
          if (result != null) {
            final folderId = result.fileId;
            widget.onUploadEpub?.call(epubData, folderId: folderId);
          }
        } else {
          widget.onUploadEpub?.call(epubData);
        }
      }
    });

    ever(controller.uploadXhtmlTrigger, (VulcanXhtmlData? xhtmlData) async {
      if (xhtmlData != null) {
        controller.uploadXhtmlTrigger.value = null; // 리셋
        if (controller.cloudConnectionTrigger.value == true) {
          final result = await NaverWorksDrivePicker.openFolderPickerAsync();
          if (result != null) {
            final folderId = result.fileId;
            widget.onUploadXhtml?.call(xhtmlData, folderId: folderId);
          }
        } else {
          widget.onUploadXhtml?.call(xhtmlData);
        }
      }
    });

    ever(controller.uploadTxtTrigger, (VulcanTxtData? txtData) async {
      if (txtData != null) {
        controller.uploadTxtTrigger.value = null; // 리셋
        if (controller.cloudConnectionTrigger.value == true) {
          final result = await NaverWorksDrivePicker.openFolderPickerAsync();
          if (result != null) {
            final folderId = result.fileId;
            widget.onUploadTxt?.call(txtData, folderId: folderId);
          }
        } else {
          widget.onUploadTxt?.call(txtData);
        }
      }
    });

    controller.documentState.rxPageEditable.value = widget.data.isEdit ?? false;
    controller.rxPanel.value = const PagePanel();
    controller.rxAttribute.value = const PageSettingsPanel();
    // widget.onTempSaveCheck?.call(
    //     controller.documentState.rxProjectId.value, controller.rxPageUrl.value);
    controller.setOnTempSaveCheck(() {
      widget.onTempSaveCheck?.call(
          controller.documentState.rxProjectId.value,
          controller.documentState.rxPageCurrent.value!.id,
          controller.rxPageUrl.value);
    });

    ever(controller.removeTempSaveDataTrigger, (bool value) async {
      if (value == true) {
        widget.onRemoveTempSaveData
            ?.call(controller.documentState.rxProjectId.value);
        controller.removeTempSaveDataTrigger.value = false; // 리셋
      }
    });

    // Office 문서 변환을 위한 새 페이지 생성 트리거 처리
    ever(controller.createPageWithContentTrigger,
        (Map<String, String>? value) async {
      if (value != null && value.isNotEmpty) {
        logger.d(
            '[OfficeIframe][createPageWithContent] result: ${value['result']}, fileName: ${value['fileName']}, page: ${value['page']}');
        // eventManager.emit(EditorEventType.createPageWithContent, value);
        if (widget.onCreatePageWithContent != null) {
          await widget.onCreatePageWithContent!(value).then((result) {
            if (result == true) {
              controller.refreshTree(controller.documentState.rxPages);
            }
          });
        }
        controller.createPageWithContentTrigger.value = null; // 리셋
      }
    });

    // 커버 페이지 설정 트리거 처리
    ever(controller.setCoverPageTrigger, (Map<String, String>? value) async {
      if (value != null && value.isNotEmpty) {
        if (widget.onSetCoverPage != null) {
          await widget.onSetCoverPage!
                  (controller.documentState.rxPageCurrent.value, value)
              .then(
            (result) =>
                controller.refreshTree(controller.documentState.rxPages),
          );
        }
        controller.setCoverPageTrigger.value = null; // 리셋
      }
    });

    // 커버 페이지 해제 트리거 처리
    ever(controller.unsetCoverPageTrigger, (Map<String, String>? value) async {
      if (value != null && value.isNotEmpty) {
        if (widget.onUnsetCoverPage != null) {
          await widget.onUnsetCoverPage!
                  (controller.documentState.rxPageCurrent.value, value)
              .then(
            (result) =>
                controller.refreshTree(controller.documentState.rxPages),
          );
        }
        controller.unsetCoverPageTrigger.value = null; // 리셋
      }
    });

    // 썸네일 생성 트리거 처리
    ever(controller.createThumbnailTrigger, (Map<String, String> value) async {
      if (value.isNotEmpty) {
        if (widget.onCreateThumbnail != null) {
          await widget.onCreateThumbnail!(
              controller.documentState.rxPageCurrent.value, value);
        }
        controller.createThumbnailTrigger.value = {}; // 리셋
      }
    });

    // TOC → Normal 변환 트리거 처리
    ever(controller.convertTocToNormalTrigger, (bool value) async {
      if (value == true) {
        if (widget.onConvertTocToNormal != null) {
          widget.onConvertTocToNormal!(
              controller.documentState.rxProjectId.value,
              controller.documentState.rxPageCurrent.value!.id);
        }
        controller.convertTocToNormalTrigger.value = false; // 리셋
      }
    });

    ever(controller.updateListNumberingTrigger, (Map<String, String> value) {
      if (value.isNotEmpty) {
        widget.onUpdateListNumbering?.call(value);
        controller.updateListNumberingTrigger.value = {};
      }
    });

    // 편집 유저가 본인으로 설정되면 300초 카운트다운 시작
    ever<String>(controller.rxEditingUserId, (value) {
      if (value == controller.documentState.rxUserId.value) {
        controller.rxStartCoOpCount.value = true;
        controller.startCoOpCount(seconds: controller.rxSettingEditCount.value);
      } else {
        controller.rxStartCoOpCount.value = false;
        controller.coOpCountTimer?.cancel();
        controller.coOpCountTimer = null;
      }
    });

    eventManager.onEvent((event) async {
      logger.d('###@eventManager event action ${event.type}');
      // if (event.type == EditorEventType.onLoad ||
      //     event.type == EditorEventType.onPageLoad) {
      //   return;
      // }

      // 1. 프로젝트가 공유된 상태에서 2.권한이 있는 상태로 3.편집중인 사람이 없을 때 진행
      if (controller.documentState.rxProjectSharePermission.value ==
              ProjectAuthType.publicLink ||
          controller.documentState.rxProjectSharePermission.value ==
              ProjectAuthType.userLink) {
        if (controller.rxEditingUserId.value == "null") {
          if (controller.documentState.rxUserId.isNotEmpty) {
            final permission = await controller.isPermission();
            if (permission == true) {
              controller.setEditorUserPermission(true);
              logger.d(
                  '###@eventManager event permission true, userId: ${controller.rxEditingUserId.value}');
              // 본인 ID인 경우에만 30초 타이머 시작
              if (controller.documentState.rxUserId.value ==
                  controller.rxEditingUserId.value) {
                controller.rxStartCoOpCount.value = true;
                controller.startCoOpCount(
                    seconds: controller.rxSettingEditCount.value);
              }
            }
          }
        }
        // 본인이 편집중이라면 다시 클릭 했을 때 타이머 다시 30초로 설정
        if (controller.documentState.rxUserId.value ==
            controller.rxEditingUserId.value) {
          controller.rxStartCoOpCount.value = true;
          controller.startCoOpCount(
              seconds: controller.rxSettingEditCount.value);
        }
      }
    });
    controller.checkEnabledEditor();
  }

  @override
  void didUpdateWidget(covariant VulcanEditor oldWidget) {
    templateId = widget.templateId;

    //_checkProjectIdAndShowDialog 실행을 막기위해 rxProjectId 값을 미리 넣어준다.
    // 빌드 중 상태 변경 방지: 프레임 이후로 지연 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.documentState.rxProjectId.value = widget.data.projectId ?? '';
      controller.documentState.rxPageEditable.value =
          widget.data.isEdit ?? false;
      controller.documentState.rxProjectSharePermission.value =
          ProjectAuthType.fromString(widget.data.projectAuth);
      controller.display(
        vulcanEditorData: widget.data,
        baseUrl: widget.baseUrl,
      );
    });

    //epub 구성 및 다운로드가 완료되면 로딩창도 닫는다.
    if (widget.isDownload == true) {
      EasyLoading.dismiss();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.triggerDownloadEpub(widget.isDownload);
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    eventManager.emit(EditorEventType.dispose, null); // 에디터 종료 이벤트 발생
    controller.disposeWebSocket();
    Get.delete<VulcanEditorController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.onUpdate = () => _checkProjectIdAndShowDialog(context);

    return GetBuilder<VulcanEditorController>(
      builder: (_) => Scaffold(
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          // 빌드 중 상태 변경 방지: 프레임 종료 후 상태 갱신
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              controller.updateEditorPosition();
            }
          });
          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(children: [
                    EditorAppBar(),
                  ]),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditorNavigationNail(
                          quizWidgetStatus: controller.quizWidgetStatus.value,
                          onSelected: (Widget panel) {
                            controller.uiState.isLeftDrawerOpen.value = true;
                            controller.rxPanel.value = panel;
                            controller.rxViewColumn.value = true;
                          },
                        ),
                        Obx(() => AnimatedContainerDrawer(
                              drawerWidth: 326,
                              isOpen: controller.uiState.isLeftDrawerOpen.value,
                              onClose: controller.toggleLeftDrawer,
                              child: SizedBox(child: controller.rxPanel.value),
                            )),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, editorConstraints) {
                              return Stack(
                                children: [
                                  Obx(
                                    () => (controller
                                            .rxPageUrl.value.isNotEmpty)
                                        ? Container(
                                            color: Colors.black45,
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: EditorIntegration(
                                                    baseUrl: AutoConfig
                                                        .instance
                                                        .domainType
                                                        .originWithPath,
                                                    langUrl:
                                                        controller.getLangUrl(
                                                      widget.baseUrl,
                                                    ),
                                                    fontUrl: widget.fontUrl,
                                                    onLoad: (editor) =>
                                                        controller
                                                            .setEditorLoad(
                                                                editor),
                                                    onPageLoad: (page) =>
                                                        controller
                                                            .onPageLoad(page),
                                                    onSingleSelected: (node) =>
                                                        controller.loadAttributePanel(
                                                            EditorCallBackType
                                                                .singleSelected,
                                                            node),
                                                    onCaretSelected: (node,
                                                        html, capturePage) {
                                                      controller
                                                          .triggerTempSave(
                                                        html,
                                                        capturePage,
                                                      );
                                                      controller
                                                          .loadAttributePanel(
                                                              EditorCallBackType
                                                                  .caretSelected,
                                                              node);
                                                    },
                                                    onNoneSelected:
                                                        (html, capturePage) {
                                                      controller
                                                          .triggerUpdatePageContent(
                                                              html,
                                                              capturePage);
                                                      controller
                                                          .loadAttributePanel(
                                                              EditorCallBackType
                                                                  .noneSelected,
                                                              null);
                                                    },
                                                    onMultiSelected: (nodes) =>
                                                        controller
                                                            .loadMultiSelectedAttributePanel(
                                                                nodes),
                                                    onCellSelected: (table,
                                                            nodes) =>
                                                        controller
                                                            .loadCellSelectedAttributePanel(
                                                                table, nodes),
                                                    onNodeRectChanged:
                                                        (nodes) => controller
                                                            .onNodeRectChanged(
                                                                nodes),
                                                    onStyleChanged:
                                                        (node, name, value) {
                                                      debugPrint(
                                                          'onStyleChanged : $name / $value');
                                                    },
                                                    onAttributeChanged:
                                                        (node, name, value) {
                                                      debugPrint(
                                                          'onAttributeChanged : $name / $value');
                                                    },
                                                    onNodeInserted: (node) {
                                                      controller
                                                          .onNodeInserted(node);
                                                    },
                                                    onNodeRemoved: (node) {
                                                      controller
                                                          .onNodeRemoved(node);
                                                    },
                                                    onUndoStackChanged: (canUndo,
                                                            canRedo) =>
                                                        controller
                                                            .onUndoStackChanged(
                                                                canUndo,
                                                                canRedo),
                                                    onPointerMove: (editorX,
                                                            editorY,
                                                            windowX,
                                                            windowY,
                                                            isInEditor) =>
                                                        controller.onMouseMove(
                                                            editorX,
                                                            editorY,
                                                            windowX,
                                                            windowY,
                                                            isInEditor),
                                                    onWidgetSelectionChanged: (node,
                                                            id, properties) =>
                                                        controller
                                                            .loadWidgetSelectedAttributePanel(
                                                                node,
                                                                id,
                                                                properties),
                                                    onFrameClick: () => null,
                                                    onDocumentChanged: (node) =>
                                                        controller
                                                            .onDocumentChanged(
                                                                node),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  if (widget.data.projectAuth ==
                                          ProjectAuthType.publicLink.value ||
                                      widget.data.projectAuth ==
                                          ProjectAuthType.userLink.value)
                                    Obx(() => Stack(
                                          children: controller.cursors.entries
                                              .map((entry) {
                                            if (controller.documentState
                                                        .rxUserId.value ==
                                                    entry.key ||
                                                controller.anonymousUserId ==
                                                    entry.key) {
                                              return const Positioned(
                                                  left: 0,
                                                  top: 0,
                                                  right: 0,
                                                  bottom: 0,
                                                  child: SizedBox.shrink());
                                            }
                                            return entry.value['x'] == 0 &&
                                                    entry.value['y'] == 0
                                                ? const SizedBox.shrink()
                                                : UserCursorWidget(
                                                    userId: entry.key,
                                                    x: (entry.value['x']) ?? 0,
                                                    y: entry.value['y'] ?? 0,
                                                    diffX: (editorConstraints
                                                                .maxWidth -
                                                            controller
                                                                    .documentState
                                                                    .rxDocumentSizeWidth
                                                                    .value *
                                                                controller
                                                                    .rxZoomValue
                                                                    .value) /
                                                        2,
                                                    diffY: 24 *
                                                        controller
                                                            .rxZoomValue.value,
                                                    scale: controller
                                                        .rxZoomValue.value,
                                                    showRuler: controller
                                                        .rxShowRuler.value,
                                                  );
                                          }).toList(),
                                        )),
                                  Obx(() => !controller.rxViewColumn.value
                                      ? Positioned(
                                          left: 15,
                                          top: 15,
                                          child: SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: SizedBox(
                                                width: 43,
                                                child:
                                                    VulcanXOutlinedButton.icon(
                                                  padding:
                                                      const EdgeInsets.all(7),
                                                  icon: const Icon(
                                                      Icons
                                                          .view_column_outlined,
                                                      size: 20),
                                                  onPressed: () =>
                                                      controller.viewColumn(),
                                                  child:
                                                      const SizedBox.shrink(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink()),
                                  // 그리기 위젯
                                  // Obx(() => Stack(
                                  //       children: controller.cursors.entries
                                  //           .map((entry) {
                                  //         // if (controller.documentState
                                  //         //             .rxUserId.value ==
                                  //         //         entry.key ||
                                  //         //     controller.anonymousUserId ==
                                  //         //         entry.key) {
                                  //         //   return const SizedBox.shrink();
                                  //         // }

                                  //         final allPoints = controller
                                  //                 .cursorTrails[entry.key]
                                  //                 ?.toList() ??
                                  //             [];
                                  //         final newPoints = controller
                                  //                 .newCursorPoints[entry.key]
                                  //                 ?.toList() ??
                                  //             [];

                                  //         return CursorTrailWidget(
                                  //           userId: entry.key,
                                  //           x: (entry.value['x']) ?? 0,
                                  //           y: entry.value['y'] ?? 0,
                                  //           diffX: (editorConstraints.maxWidth -
                                  //                   controller
                                  //                           .documentState
                                  //                           .rxDocumentSizeWidth
                                  //                           .value *
                                  //                       controller.rxZoomValue
                                  //                           .value) /
                                  //               2,
                                  //           diffY: 24 *
                                  //               controller.rxZoomValue.value,
                                  //           scale: controller.rxZoomValue.value,
                                  //           showRuler:
                                  //               controller.rxShowRuler.value,
                                  //           points: allPoints,
                                  //           newPoints: newPoints,
                                  //           // cursorColor: Colors.red,
                                  //           cursorColor:
                                  //               getColorForUserId(entry.key),
                                  //         );
                                  //       }).toList(),
                                  //     )),
                                  // DraggablePopupMenuBar(
                                  //   menuItems: [
                                  //     IconButton(
                                  //       icon: const Icon(Icons.brush),
                                  //       onPressed: () async {
                                  //         print('브러시 클릭');
                                  //         // 브러시 동작 실행
                                  //       },
                                  //     ),
                                  //     IconButton(
                                  //       icon: const Icon(Icons.edit),
                                  //       onPressed: () async {
                                  //         print('연필 클릭');
                                  //         // 연필 동작 실행
                                  //       },
                                  //     ),
                                  //     IconButton(
                                  //       icon: const Icon(Icons.color_lens),
                                  //       onPressed: () async {
                                  //         print('색상 클릭');
                                  //         // 색상 선택 동작 실행
                                  //       },
                                  //     ),
                                  //     IconButton(
                                  //       icon: const Icon(Icons.delete),
                                  //       onPressed: () async {
                                  //         print('지우개 클릭');
                                  //         // 지우개 동작 실행
                                  //       },
                                  //     ),
                                  //     IconButton(
                                  //       icon: const Icon(Icons.more_vert),
                                  //       onPressed: () async {},
                                  //     ),
                                  //   ],
                                  //   initialPosition: const Offset(100, 200),
                                  //   isInteracting:
                                  //       controller.rxPopupInteracting,
                                  // ),
                                ],
                              );
                            },
                          ),
                        ),
                        Obx(() => AnimatedContainerDrawer(
                              drawerWidth: 300,
                              alignment: Alignment.topLeft,
                              isOpen:
                                  controller.uiState.isRightDrawerOpen.value,
                              onClose: controller.toggleRightDrawer,
                              child: SizedBox(
                                child: controller.rxAttribute.value,
                              ),
                            )),
                      ],
                    ),
                  )
                ],
              ),
              // 다른 사용자들의 커서 표시
              // Obx(() => Stack(
              //       children: controller.cursors.entries.map((entry) {
              //         if (controller.documentState.rxUserId.value ==
              //                 entry.key ||
              //             controller.anonymousUserId == entry.key) {
              //           return const Positioned(
              //               left: 0,
              //               top: 0,
              //               right: 0,
              //               bottom: 0,
              //               child: SizedBox.shrink());
              //         }
              //         return UserCursorWidget(
              //           userId: entry.key,
              //           x: (entry.value['x']) ?? 0,
              //           y: entry.value['y'] ?? 0,
              //           diffX: (constraints.maxWidth -
              //                   (controller.rxDocumentSizeWidth.value *
              //                       controller.rxZoomValue.value)) /
              //               2,
              //           diffY: (constraints.maxHeight -
              //                   (controller.rxDocumentSizeHeight.value *
              //                       controller.rxZoomValue.value)) /
              //               2,
              //           showRuler: controller.rxShowRuler.value,
              //           scale: controller.rxZoomValue.value,
              //         );
              //       }).toList(),
              //     )),

              // 협업 대구 임시 주석 처리 - 추후 소켓 작업 후 해제 예정
              // Obx(
              //   () => controller.rxIsCoopMode.value
              //       ? DraggablePopupMenuBar(
              //           menuItems: [
              //             Tooltip(
              //               message: controller.isEditingStatus.value
              //                   ? 'editing_user_status_true'.tr
              //                   : 'editing_user'.trArgs(
              //                       [controller.rxEditingDisplayName.value]),
              //               child: controller.isEditingStatus.value
              //                   ? Icon(
              //                       Icons.circle,
              //                       color: controller.isEditingStatus.value
              //                           ? Colors.green
              //                           : Colors.red,
              //                     )
              //                   : Row(
              //                       spacing: 10,
              //                       children: [
              //                         CircleAvatar(
              //                           radius: 16,
              //                           backgroundColor: getColorForUserId(
              //                               controller
              //                                   .rxEditingDisplayName.value),
              //                           child: Text(controller
              //                                   .rxEditingDisplayName
              //                                   .value
              //                                   .isNotEmpty
              //                               ? controller
              //                                   .rxEditingDisplayName.value
              //                                   .substring(0, 1)
              //                                   .toUpperCase()
              //                               : ''),
              //                         ),
              //                         Text('editing_user'.trArgs([
              //                           controller.rxEditingDisplayName.value
              //                         ])),
              //                       ],
              //                     ),
              //             ),
              //             const SizedBox(width: 15),
              //             // Tooltip(
              //             //   message: 'get_permission'.tr,
              //             //   child: IconButton(
              //             //     onPressed: () {
              //             //       if (controller.rxIsRequestPermission.value) {
              //             //         controller.setEditorUserPermission(true);
              //             //         EasyLoading.showInfo(
              //             //             'get_permission_success'.tr);
              //             //         return;
              //             //       }
              //             //       EasyLoading.showError(
              //             //           'get_permission_error'.tr);
              //             //       return;
              //             //     },
              //             //     icon: Icon(
              //             //       controller.rxIsRequestPermission.value
              //             //           ? Icons.pan_tool // 요청 가능
              //             //           : Icons.pan_tool_outlined, // 요청 불가능
              //             //     ),
              //             //   ),
              //             // ),
              //             controller.rxIsEditorStatus.value
              //                 ? Tooltip(
              //                     // message: 'get_permission'.tr,
              //                     message:
              //                         controller.rxIsRequestPermission.value
              //                             ? 'get_permission'.tr
              //                             : 'exit'.tr,
              //                     child: IconButton(
              //                       onPressed: () {
              //                         if (controller
              //                             .rxIsRequestPermission.value) {
              //                           controller
              //                               .setEditorUserPermission(true);
              //                           EasyLoading.showInfo(
              //                               'get_permission_success'.tr);
              //                           return;
              //                         } else {
              //                           controller
              //                               .setEditorUserPermission(false);
              //                           controller.rxIsDrawingMode.value =
              //                               false;
              //                           controller.editor
              //                               ?.toggleDrawingMode('null');
              //                           controller.editor?.enable(true);
              //                         }
              //                       },
              //                       icon: Icon(
              //                         controller.rxIsRequestPermission.value
              //                             ? Icons.pan_tool // 요청 가능
              //                             : Icons.cancel, // 요청 불가능
              //                       ),
              //                     ),
              //                   )
              //                 : const SizedBox.shrink(),
              //             // !controller.rxIsRequestPermission.value
              //             //     ? IconButton(
              //             //         icon: const Icon(Icons.cancel,
              //             //             color: Colors.red),
              //             //         onPressed: () {
              //             //           if (controller
              //             //               .rxIsRequestPermission.value) {
              //             //             // controller.setEditorUserPermission(false);
              //             //           } else {
              //             //             controller.setEditorUserPermission(false);
              //             //             controller.rxIsDrawingMode.value = false;
              //             //             controller.editor
              //             //                 ?.toggleDrawingMode('null');
              //             //             controller.editor?.enable(true);
              //             //           }
              //             //         },
              //             //       )
              //             //     : const SizedBox.shrink(),
              //             const SizedBox(width: 10),
              //             Obx(() => controller.rxStartCoOpCount.value &&
              //                     controller.rxCoOpCount.value != 0
              //                 ? _coopCountDown(controller.rxCoOpCount.value)
              //                 : const SizedBox.shrink()),
              //             //const Icon(Icons.more_vert),
              //           ],
              //           initialPosition: Offset(
              //             70,
              //             controller.documentState.rxDocumentSizeHeight.value
              //                     .toDouble() -
              //                 150,
              //           ),
              //         )
              //       : const SizedBox.shrink(),
              // ),
            ],
          );
        }),
      ),
    );
  }

  Widget _coopCountDown(int count) {
    // count를 분 초로 변환
    final minutes = count ~/ 60;
    final seconds = count % 60;
    return Text(
      'coop_mode_countdown_seconds'.trArgs([
        minutes.toString(),
        seconds.toString(),
      ]),
      style: const TextStyle(color: Colors.red),
    );
  }

  Widget _requestUserItem(String userId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: getColorForUserId(userId),
          child: Text(userId.substring(0, 1).toUpperCase()),
        ),
        Text(userId),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.check_circle),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.cancel),
        ),
      ],
    );
  }

  void _checkProjectIdAndShowDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // debugPrint(
      //     '####_checkProjectIdAndShowDialog: ${controller.rxDisplayType.value}');
      if (controller.rxDisplayType.value == VulcanEditorDisplayType.create) {
        // 템플릿 아이디가 존재할 . 떄분기 처리
        if (widget.templateId != null) {
          _showProjectSettingDialog(context);
          return;
        } else {
          _showNewDocumentDialog(context);
        }
      } else if (controller.rxDisplayType.value ==
          VulcanEditorDisplayType.unauthorized) {
        debugPrint(
            '####_checkProjectIdAndShowDialog unauthorized: ${controller.rxDisplayType.value}');
        _showUnauthorizedDialog(context);
      }
    });
  }

  Future<void> _showNewDocumentDialog(BuildContext context) async {
    VulcanCloseDialogType? result = await VulcanCloseDialogWidget(
      width: 540,
      height: 267,
      // 새 문서 만들기
      title: 'create_new_document_title'.tr,
      content: EditorNewDocumentDialog(
        onTap: (type) {
          context.pop();
          if (type == NewDocumentType.emptyDocument) {
            _showProjectSettingDialog(context);
          } else if (type == NewDocumentType.template) {
            _showTemplateDialog(context);
          }
        },
      ),
    ).show(context);

    if (result == VulcanCloseDialogType.ok) {
      debugPrint('사용자가 확인을 선택했습니다.');
    } else if (result == VulcanCloseDialogType.cancel) {
      debugPrint('사용자가 취소를 선택했습니다.');
    } else if (result == VulcanCloseDialogType.close) {
      debugPrint('다이얼로그가 닫혔습니다.');
      if (context.mounted) {
        context.go('/home');
      }
    }
  }

  Future<void> _showTemplateDialog(BuildContext context) async {
    VulcanCloseDialogType? result = await VulcanCloseDialogWidget(
      width: 960,
      //템플릿 선택
      title: 'template_select_title'.tr,
      content: EditorTemplateDialog(
        onTap: (value) {
          context.pop();
          templateId = value;
          _showProjectSettingDialog(context);
        },
      ),
    ).show(context);

    if (result == VulcanCloseDialogType.close) {
      debugPrint('다이얼로그가 닫혔습니다.');
      if (context.mounted) {
        context.go('/home');
      }
    }
  }

  Future<void> _showProjectSettingDialog(BuildContext context) async {
    VulcanCloseDialogType? result = await VulcanCloseDialogWidget(
      width: 320,
      height: 320,
      //새 프로젝트 만들기
      title: (AutoConfig.instance.domainType.isAraDomain)
          ? 'create_project_title'.tr
          : 'non_ara_create_project_title'.tr,
      content: EditorProjectSettingDialog(
        initialFolderId: widget.initialFolderId,
        onTap: (projectSettingData) {
          if (templateId != null) {
            projectSettingData =
                projectSettingData.copyWith(templateId: templateId!);
          }
          widget.onCreatedProject?.call(projectSettingData);
          controller.rxShowEditorUser.value = false;
          controller.isEditingPermission.value = true; // 나의 프로젝트 생성 시 편집 권한 부여
          context.pop();
        },
      ),
    ).show(context);

    if (result == VulcanCloseDialogType.close) {
      if (context.mounted) {
        context.go('/home');
      }
    }
  }

  Future<void> _showUnauthorizedDialog(BuildContext context) async {
    EasyLoading.showInfo('권한이 없는 프로젝트입니다.').then((value) {
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (context.mounted) {
          context.go('/home');
        }
      });
    });
  }

  Color getColorForUserId(String userId) {
    final hash = userId.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }
}
