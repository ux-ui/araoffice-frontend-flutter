import 'dart:js_interop';

import 'package:api/api.dart';
import 'package:app_ui/widgets/vulcanx/vulcan_x_close_dialog_widget.dart';
import 'package:common_util/common_util.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:web/web.dart' as web;

import '../data/datas.dart';
import '../engine/engines.dart';
import '../enum/enums.dart';
import '../states/states.dart';

mixin TriggerControlMixin {
  // 트리거 변수들을 직접 mixin 내에서 선언

  final rxIsDownloadTrigger = false.obs;
  final rxClipArtTrigger = <String, String>{}.obs;
  final rxShortUrlTrigger = ''.obs;
  final updateProjectAuthTrigger = RxMap<String, String>({});
  final getUserListTrigger = ''.obs;
  final addUserTrigger = RxMap<String, String>({});
  final deleteUserTrigger = RxMap<String, String>({});
  final editPermissionTrigger = RxMap<String, String>({});
  final rxAddWidgetTrigger = <String, String>{}.obs;
  final rxShareUserList = <VulcanUserData>[].obs;
  final rxDownloadDialogTrigger = Rx<VulcanCloseDialogType?>(null);

  final exportEpubTrigger = Rx<VulcanEpubData?>(null);
  final exportXhtmlTrigger = Rx<VulcanXhtmlData?>(null);
  final exportTxtTrigger = Rx<VulcanTxtData?>(null);
  // final exportPdfTrigger = Rx<String?>(null);

  final cloudConnectionTrigger = Rx<bool>(false);
  final uploadEpubTrigger = Rx<VulcanEpubData?>(null);
  final uploadXhtmlTrigger = Rx<VulcanXhtmlData?>(null);
  final uploadTxtTrigger = Rx<VulcanTxtData?>(null);

  final uploadFileTrigger = Rx<dio.FormData?>(null);
  final updateTocTrigger = RxMap<String, String>();

  // 목록 번호 자동 업데이트 트리거 추가
  final updateListNumberingTrigger = RxMap<String, String>();

  // TOC 관련 트리거들 추가
  final convertTocToNormalTrigger = Rx<bool>(false);

  // Office 문서 변환을 위한 새 페이지 생성 트리거 추가
  final createPageWithContentTrigger = Rx<Map<String, String>?>(null);

  // 임시 저장 데이터 삭제 트리거 추가
  final removeTempSaveDataTrigger = false.obs;

  // 커버 페이지 설정 트리거 추가
  final setCoverPageTrigger = Rx<Map<String, String>?>(null);

  // 커버 페이지 해제 트리거 추가
  final unsetCoverPageTrigger = Rx<Map<String, String>?>(null);

  // 프로젝트 저장 트리거 추가
  final projectSaveTrigger = Rx<ProjectModel?>(null);

  // DocumentState를 컨트롤러에서 가져와야 함
  DocumentState get documentState;

  Editor? get editor;

  void triggerClipArt(String path, String type, String clipartType) {
    // 허용되지 않는 문자 '/'를 '-'로 변환한 다음 서버에서 검증을 거치고 서버에서 '/'로 다시 변환한다.
    final finalPath = path.replaceAll('/', '-');

    rxClipArtTrigger.value = {
      'path': finalPath,
      'type': type,
      'clipartType': clipartType,
    };
  }

  void triggerShortUrl() {
    final location = web.window.location.toString();

    if (location.endsWith('editor')) {
      final projectId = documentState.rxProjectId.value;
      rxShortUrlTrigger.value = '$location?p=$projectId';
    } else {
      rxShortUrlTrigger.value = location;
    }
  }

  // 프로젝트 공유 설정 변경
  void triggerUpdateProjectAuth(ProjectAuthType type) {
    documentState.rxProjectSharePermission.value = type;
    final projectId = documentState.rxProjectId.value;
    updateProjectAuthTrigger.value = {
      'projectId': projectId,
      'projectAuth': type.value,
    };
  }

  // 사용자 목록 조회
  void triggerGetUserList(String projectId) {
    getUserListTrigger.value = projectId;
  }

  // 사용자 추가
  void triggerAddUser(String userId, bool isEmail, {String? shareId}) {
    final projectId = documentState.rxProjectId.value;
    addUserTrigger.value = {
      'projectId': projectId,
      'userId': userId,
      'isEmail': '$isEmail',
      if (shareId != null && shareId.isNotEmpty) 'shareId': shareId,
    };
  }

  // 사용자 삭제
  void triggerDeleteUser(String userId) {
    final projectId = documentState.rxProjectId.value;
    deleteUserTrigger.value = {
      'projectId': projectId,
      'userId': userId,
    };
  }

  void triggerEditPermission(String pageId, String userId) {
    editPermissionTrigger.value = {
      'pageId': pageId,
      'userId': userId,
    };
  }

  void triggerAddWidget(String widgetPath, String type) {
    final value = {
      'widgetPath': widgetPath,
      'type': type,
    };
    rxAddWidgetTrigger.value = value;
  }

  /// Office 문서 변환을 위한 내용이 포함된 새 페이지 생성 트리거
  bool triggerCreatePageWidthContent(
    int result,
    String fileName,
    int page,
    int total,
    String content,
  ) {
    logger.d(
        '[OfficeIframe][triggerCreatePageWidthContent] result: $result, fileName: $fileName, page: $page');

    final projectId = documentState.rxProjectId.value;
    if (projectId.isEmpty) {
      logger.d('[OfficeIframe] 프로젝트 ID가 없습니다.');
      return false;
    }

    if (result != 2) {
      createPageWithContentTrigger.value = {
        'projectId': projectId,
        'result': '$result'
      };
      return true;
    }

    String getTextWithLimitLength(
      String text,
      String postfix, {
      int limitLength = 255,
    }) {
      final maxLength = limitLength - postfix.length;
      final prefix =
          text.length > maxLength ? text.substring(0, maxLength) : text;
      return '$prefix$postfix';
    }

    final baseName = p.basenameWithoutExtension(fileName);
    var extension = p.extension(fileName);
    if (extension.startsWith('.')) {
      extension = extension.substring(1);
    }
    // Title
    final postfixTitle = '-$page';
    final title = getTextWithLimitLength(baseName, postfixTitle);
    // File Name
    final postfixFileName =
        '_${extension}_${page}_${DateTime.now().millisecondsSinceEpoch}.xhtml';
    final saveFileName = getTextWithLimitLength(baseName, postfixFileName);

    createPageWithContentTrigger.value = {
      'projectId': projectId,
      'result': '$result',
      'title': title,
      'page': '$page',
      'content': content,
      'fileName': saveFileName,
    };

    return true;
  }

  // GetxController를 상속한 클래스에서 구현할 update 메서드
  void update([List<Object>? ids, bool condition = true]);

  /// 커버 페이지 설정 트리거
  void triggerSetCoverPage(String pageId) {
    final projectId = documentState.rxProjectId.value;

    if (projectId.isEmpty || pageId.isEmpty) {
      logger.d('커버 페이지 설정: 필수 데이터가 누락되었습니다.');
      return;
    }

    setCoverPageTrigger.value = {
      'projectId': projectId,
      'pageId': pageId,
    };
  }

  // 프로젝트 저장 트리거
  void triggerSaveProject() {
    final projectId = documentState.rxProjectId.value;
    final projectName = documentState.rxProjectName.value;
    if (projectId.isEmpty || projectName.isEmpty) {
      logger.d('프로젝트 저장: 프로젝트 정보가 없습니다.');
      Get.snackbar('저장 실패', '프로젝트 정보가 없습니다.');
      return;
    }

    final model = ProjectModel(
      id: projectId,
      userId: documentState.rxUserId.value,
      name: projectName,
      displayName: projectName,
      templateId: '',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      pages: null,
      projectAuth: documentState.rxProjectSharePermission.value.value,
      sharedUsers: null,
      isOwner: true,
      startPageId: documentState.rxStartPageId.value.isEmpty
          ? documentState.rxPageCurrent.value?.id
          : documentState.rxStartPageId.value,
      hasCover: documentState.rxHasCover.value,
      hasToc: documentState.rxHasToc.value,
    );

    projectSaveTrigger.value = model;
    logger.d('프로젝트 저장 트리거 호출: $projectId / $projectName');
    Get.snackbar('저장 요청', '프로젝트가 임시로 저장되었습니다.');
  }

  /// 커버 페이지 해제 트리거
  void triggerUnsetCoverPage(String pageId) {
    final projectId = documentState.rxProjectId.value;

    if (projectId.isEmpty || pageId.isEmpty) {
      logger.d('커버 페이지 해제: 필수 데이터가 누락되었습니다.');
      return;
    }

    unsetCoverPageTrigger.value = {
      'projectId': projectId,
      'pageId': pageId,
    };
  }

  void triggerUpdateListNumbering(String listStyleOption) {
    removeTempSaveDataTrigger.value = true;
    updateListNumberingTrigger.value = {
      'projectId': documentState.rxProjectId.value,
      'pageId': documentState.rxPageCurrent.value!.id,
      'listStyleOption': listStyleOption,
    };
  }

  void triggerDownloadEpub(bool value) {
    rxIsDownloadTrigger.value = value;
    update();
  }

  void triggerExportEpub(VulcanEpubData epubData) {
    epubData = epubData.copyWith(projectId: documentState.rxProjectId.value);
    exportEpubTrigger.value = epubData;
  }

  // PDF 내보내기
  void triggerExportPdf() {
    // exportPdfTrigger.value = documentState.rxProjectId.value;

    final projectId = documentState.rxProjectId.value;
    final pages = documentState.rxPages
        .map((e) => documentState.getBuildTypeUrl(projectId, e.href).toJS)
        .toList()
        .toJS;
    editor?.printPages(pages);
  }

  void triggerExportXhtml() {
    try {
      // 프로젝트 정보 가져오기
      final projectId = documentState.rxProjectId.value;
      final projectName = documentState.rxProjectName.value;

      if (projectId.isEmpty || projectName.isEmpty) {
        logger.d('XHTML 내보내기 오류: 프로젝트 정보가 없습니다.');
        return;
      }

      // XHTML 데이터 생성
      final xhtmlData = VulcanXhtmlData(
        title: projectName,
        projectId: projectId,
        fileName: '${projectName}_${DateTime.now().millisecondsSinceEpoch}',
        publishType: PublishType.official.javaEnum,
        publishDate: DateTime.now().toIso8601String(),
        author: '',
        showPageList: true,
      );

      exportXhtmlTrigger.value = xhtmlData;
      logger.d('XHTML 내보내기 트리거 호출: ${xhtmlData.fileName}');
    } catch (e) {
      logger.e('XHTML 내보내기 오류', e);
    }
  }

  /// TXT 직접 생성 및 다운로드 트리거
  void triggerExportTxt() {
    try {
      // 프로젝트 정보 가져오기
      final projectId = documentState.rxProjectId.value;
      final projectName = documentState.rxProjectName.value;

      if (projectId.isEmpty || projectName.isEmpty) {
        logger.d('TXT 내보내기 오류: 프로젝트 정보가 없습니다.');
        return;
      }

      // TXT 데이터 생성
      final txtData = VulcanTxtData(
          title: projectName,
          projectId: projectId,
          fileName:
              '${projectName}_${DateTime.now().millisecondsSinceEpoch}.txt',
          encoding: 'UTF-8',
          lineSeparator: '\n',
          publishType: PublishType.official.javaEnum,
          publishDate: DateTime.now().toIso8601String(),
          author: '');

      final updatedTxtData = txtData.copyWith(
        projectId: documentState.rxProjectId.value,
      );
      exportTxtTrigger.value = updatedTxtData;

      logger.d('TXT 내보내기 트리거 호출: ${txtData.fileName}');
    } catch (e) {
      logger.e('TXT 내보내기 오류', e);
    }
  }

  // 드라이브 업로드: epub, xhtml, txt

  void triggerCloudConnection() {
    cloudConnectionTrigger.value = true;
  }

  void triggerDriveEpub(VulcanEpubData epubData) {
    epubData = epubData.copyWith(projectId: documentState.rxProjectId.value);
    logger.d('EPUB 업로드 호출');
    uploadEpubTrigger.value = epubData;
  }

  void triggerDriveXhtml() {
    try {
      // 프로젝트 정보 가져오기
      final projectId = documentState.rxProjectId.value;
      final projectName = documentState.rxProjectName.value;

      if (projectId.isEmpty || projectName.isEmpty) {
        logger.d('XHTML 업로드 오류: 프로젝트 정보가 없습니다.');
        return;
      }

      // XHTML 데이터 생성
      final xhtmlData = VulcanXhtmlData(
        title: projectName,
        projectId: projectId,
        fileName: '${projectName}_${DateTime.now().millisecondsSinceEpoch}',
        publishType: PublishType.official.javaEnum,
        publishDate: DateTime.now().toIso8601String(),
        author: '',
        showPageList: true,
      );

      logger.d('XHTML 업로드 호출: ${xhtmlData.fileName}');
      uploadXhtmlTrigger.value = xhtmlData;
    } catch (e) {
      logger.e('XHTML 업로드 오류', e);
    }
  }

  void triggerDriveTxt() {
    try {
      // 프로젝트 정보 가져오기
      final projectId = documentState.rxProjectId.value;
      final projectName = documentState.rxProjectName.value;

      if (projectId.isEmpty || projectName.isEmpty) {
        logger.d('TXT 업로드 오류: 프로젝트 정보가 없습니다.');
        return;
      }

      // TXT 데이터 생성
      final txtData = VulcanTxtData(
          title: projectName,
          projectId: projectId,
          fileName:
              '${projectName}_${DateTime.now().millisecondsSinceEpoch}.txt',
          encoding: 'UTF-8',
          lineSeparator: '\n',
          publishType: PublishType.official.javaEnum,
          publishDate: DateTime.now().toIso8601String(),
          author: '');

      final updatedTxtData = txtData.copyWith(
        projectId: documentState.rxProjectId.value,
      );

      logger.d('TXT 업로드 호출: ${txtData.fileName}');
      uploadTxtTrigger.value = updatedTxtData;
    } catch (e) {
      logger.e('TXT 업로드 오류', e);
    }
  }
}
