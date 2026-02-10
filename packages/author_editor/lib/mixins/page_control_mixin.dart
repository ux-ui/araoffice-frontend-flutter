// lib/mixins/page_control_mixin.dart
import 'dart:js_interop';

import 'package:api/api.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_util/common_util.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../engine/engines.dart';
import '../states/document_state.dart';

/// 페이지 관리 관련 기능을 관리하는 Mixin
mixin PageControlMixin on GetxController {
  Editor? get editor;
  bool get isOwner;

  DocumentState get documentState; // DocumentState getter 추가
  String get ulListClassName;

  // Page triggers
  final createPageTrigger = RxMap<String, String?>();
  final deletePageTrigger = RxMap<String, String>();
  final updatePageContentTrigger = RxMap<String, String>();
  final copyPageTrigger = RxMap<String, String>();
  final movePageTrigger = RxMap<String, String>();
  final renamePageTrigger = RxMap<String, String>();
  final placementPropertyTrigger = RxMap<String, String>();
  final updateTocTrigger = RxMap<String, String>();
  final activePageTrigger = RxMap<String, String>();
  final tempSaveTrigger = RxMap<String, String>();
  final refreshPageTrigger = RxMap<String, String>();
  final setStartPageTrigger = RxMap<String, String>();
  final createThumbnailTrigger = RxMap<String, String>();

  final araService = Get.find<AraApiService>();
  final loginService = Get.find<LoginApiClient>();
  final naverWorksApiClient = Get.find<NaverWorksApiClient>();

  /// 새 페이지를 생성합니다
  void triggerCreatePage(String? parentId) {
    if (documentState.rxProjectId.value.isEmpty) return;

    createPageTrigger.value = {
      'projectId': documentState.rxProjectId.value,
      'parentId': parentId,
    };
  }

  /// 페이지를 삭제합니다
  void triggerDeletePage(TreeListModel pageData) {
    // page가 1개만 남아있으면 삭제가 안되게 한다.
    if (documentState.rxPages.length == 1) return;

    deletePageTrigger.value = {
      'projectId': documentState.rxProjectId.value,
      'pageId': pageData.id,
      'fileName': pageData.href
    };
  }

  /// 페이지를 이동합니다
  void triggerMovePage(TreeListModel movedPage, TreeListModel targetPage,
      DragTargetPosition position) {
    movePageTrigger.value = {
      'projectId': documentState.rxProjectId.value,
      'movedPageId': movedPage.id,
      'targetPageId': targetPage.id,
      'position': position.name.toUpperCase(),
    };
  }

  void triggerRefreshPage(TreeListModel pageData) {
    refreshPageTrigger.value = {
      'projectId': documentState.rxProjectId.value,
      'pageId': pageData.id,
      'pageUrl': pageData.href,
    };
  }

  /// 페이지를 복사합니다
  void triggerCopyPage(TreeListModel pageData) {
    copyPageTrigger.value = {
      'projectId': documentState.rxProjectId.value,
      'pageId': pageData.id,
      'href': pageData.href,
      'title': pageData.title
    };
  }

  /// 전체 페이지 안에 있는 스타일 단위 목차를 업데이트합니다.
  void triggerUpdateToc(String type) {
    updateTocTrigger.value = {
      'projectId': documentState.rxProjectId.value,
      'pageId': documentState.rxPageCurrent.value!.id,
      'type': type,
    };
  }

  void triggerActivePage(String type, bool isActive) {
    activePageTrigger.value = {
      'projectId': documentState.rxProjectId.value,
      'type': type,
      'isActive': isActive.toString(),
    };
  }

  /// 페이지 이름을 변경합니다
  void triggerRenamePage(TreeListModel pageData, String rename) {
    renamePageTrigger.value = {
      'projectId': documentState.rxProjectId.value,
      'pageId': pageData.id,
      'href': pageData.href,
      'idref': pageData.idref,
      'title': rename,
      'linear': pageData.linear.toString(),
    };
  }

  // 배치 프로퍼티 설정을 변경합니다.
  void triggerPlacementPropertyPage(String property) {
    placementPropertyTrigger.value = {
      'projectId': documentState.rxProjectId.value,
      'pageId': documentState.rxPageCurrent.value!.id,
      'property': property,
    };
  }

  void updatePageContent() {
    logger.d('[PageControlMixin] updatePageContent');
    final html = editor?.getHtmlString();
    try {
      editor?.capturePage().toDart.then((JSString value) {
        triggerUpdatePageContent(html!, value.toDart);
      }).catchError((error) {
        logger.e('Error capturing page: $error');
        triggerUpdatePageContent(html!, '');
      });
    } catch (e) {
      logger.e('Error: $e');
    }
  }

  /// 페이지 내용을 업데이트합니다
  Future<void> triggerUpdatePageContent(String html, String capturePage) async {
    logger.d('[PageControlMixin] triggerUpdatePageContent');
    if (documentState.rxPageCurrent.value == null) return;
    // final cleanHtml = html.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ');
    // final cleanHtml = html.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '\u00A0');
    final cleanHtml =
        html.replaceAll(RegExp(r'[\x00-\x1F\x7F]', multiLine: true), ' ');
    updatePageContentTrigger.value = {
      'projectId': documentState.rxProjectId.value,
      'pageId': documentState.rxPageCurrent.value!.id,
      'fileName': documentState.rxPageCurrent.value!.href,
      'content': cleanHtml,
      'capturePage': capturePage,
    };
  }

  Future<bool> saveAraProject() async {
    try {
      // final authorization = await naverWorksApiClient.getNaverWorksToken();
      // String worksToken = '';
      // if (authorization == null || authorization.isError) {
      //   return false;
      // }
      // worksToken = extractWorksToken(authorization.data['message']);
      final cloudApiService = Get.find<CloudApiService>();
      final worksToken = await cloudApiService.getNaverWorksToken() ?? '';
      final result = await araService.saveAraProject(
        documentState.rxProjectId.value,
        worksToken,
      );
      if (result.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error saving ARA project: $e');
      return false;
    }
  }

  String extractWorksToken(String input) {
    final regex = RegExp(r'토큰:\s*([^\s]+)');
    final match = regex.firstMatch(input);
    return match?.group(1) ?? '';
  }

  // 임시 저장
  void triggerTempSave(String html, String capturePage) {
    if (documentState.rxPageCurrent.value == null) return;

    tempSaveTrigger.value = {
      'userId': documentState.rxUserId.value,
      'projectId': documentState.rxProjectId.value,
      'pageId': documentState.rxPageCurrent.value!.id,
      'fileName': documentState.rxPageCurrent.value!.href,
      'content': html,
      'capturePage': capturePage,
      'saveTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    };
  }

  void triggerSetStartPage(TreeListModel pageData) {
    setStartPageTrigger.value = {
      'projectId': documentState.rxProjectId.value,
      'pageId': pageData.id,
    };
  }

  /// 현재 페이지의 썸네일을 생성하고 서버에 업로드합니다
  void triggerCreateThumbnail(TreeListModel pageData) {
    if (documentState.rxProjectId.value.isEmpty) return;

    try {
      editor?.capturePage().toDart.then((JSString value) {
        final thumbnailImage = value.toDart;
        if (thumbnailImage.isNotEmpty) {
          createThumbnailTrigger.value = {
            'projectId': documentState.rxProjectId.value,
            'pageId': pageData.id,
            'thumbnailImage': thumbnailImage,
          };
        }
      }).catchError((error) {
        logger.e('Error capturing page for thumbnail: $error');
      });
    } catch (e) {
      logger.e('Error creating thumbnail: $e');
    }
  }
}
