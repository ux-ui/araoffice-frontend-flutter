import 'package:api/api.dart';
import 'package:app/app/template/controller/template_controller.dart';
import 'package:app_ui/app_ui.dart';
import 'package:author_editor/data/datas.dart';
import 'package:author_editor/data/vulcan_widget_data.dart';
import 'package:author_editor/enum/enums.dart';
import 'package:author_editor/mixins/cloud_connection_mixin.dart';
import 'package:author_editor/vulcan_editor_controller.dart';
import 'package:common_util/common_util.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/view/home_page.dart';
import '../../login/view/login_controller.dart';

class EditorController extends GetxController with CloudConnectionMixin {
  final apiService = Get.find<ProjectApiService>();
  final TemplateController templateController = Get.find<TemplateController>();
  final LoginController loginController = Get.find<LoginController>();
  // final EditorService editorService = Get.find<EditorService>();
  final EditorServiceImpl editorService = EditorServiceImpl();

  final rxProjectId = ''.obs;
  final rxPageId = ''.obs;
  final rxDisplayType = VulcanEditorDisplayType.unauthorized.obs;
  final rxPages = <PageModel>[].obs;

  final rxVulcanEditorData = VulcanEditorData().obs;
  final rxIsDownload = false.obs;

  final rxTemplateId = ''.obs;

  bool isLoading = true;

  // 사용자 목록 로딩 상태
  final RxBool rxIsUserListLoading = false.obs;

  // 링크 복사 상태
  final RxBool rxIsLinkCopied = false.obs;

  // 사용자 추가/삭제 상태
  final RxBool rxIsUserActionSuccess = false.obs;
  final RxString rxUserActionMessage = ''.obs;

  Future<void> init(
      {String? projectId,
      String? pageId,
      String? displayType,
      required BuildContext context}) async {
    // displayType 결정 로직:
    // 1. displayType이 명시적으로 전달되면 그 값 사용
    // 2. displayType이 없고 projectId가 있으면 -> unauthorized (기존 프로젝트 열기)
    // 3. displayType도 없고 projectId도 없으면 -> create (새 문서 생성)
    if (displayType != null && displayType.isNotEmpty) {
      rxDisplayType.value = VulcanEditorDisplayType.fromString(displayType);
    } else if (projectId != null && projectId.isNotEmpty) {
      rxDisplayType.value = VulcanEditorDisplayType.unauthorized;
    } else {
      rxDisplayType.value = VulcanEditorDisplayType.create;
    }
    debugPrint(
        '####@@@editor controller init displayType: $displayType, projectId: $projectId, result: ${rxDisplayType.value}');

    /// 템플릿 리스트를 가져와서 vulcanTemplateData로 변경해준다.
    final templates = await templateController.fetchTemplateList();
    final vulcanTemplateData = _toVulcanTemplateDataList(templates ?? []);

    final loginUser = await loginController.getUser();
    final userId = loginUser?.userId ?? '';
    final userDisplayName = loginUser?.displayName ?? '';

    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
        templates: vulcanTemplateData,
        displayType: rxDisplayType.value,
        userId: userId,
        userDisplayName: userDisplayName);

    if (projectId == null) {
      isLoading = false;
      update();
      return;
    }

    // final isUserSignStatus = await loginController.checkUserSignStatus(context);
    // if (!isUserSignStatus) {
    //   isLoading = false;
    //   update();
    //   return;
    // }

    final isUserShareIdStatus =
        await loginController.checkUserShareIdStatus(context);
    if (!isUserShareIdStatus) {
      isLoading = false;
      update();
      return;
    }

    rxProjectId.value = projectId;
    rxPageId.value = pageId ?? '';

    final isLogin = await checkLoginStatus();
    if (isLogin) {
      if (!context.mounted) return;
      final tempSaveResult =
          await checkTempSaveData(projectId, pageId ?? '', context);
      if (!tempSaveResult) {
        isLoading = false;
        update();
        return;
      }
      isLoading = true;
      final projectResult = await fetchProject(rxProjectId.value);
      isLoading = false;
      update();
      if (projectResult != null && projectResult.statusCode == 403) {
        _showProjectAccessDeniedAndGoHome(context);
        return;
      }
    } else {
      isLoading = true;
      final projectResult = await fetchProject(rxProjectId.value);
      isLoading = false;
      update();
      if (projectResult != null && projectResult.statusCode == 403) {
        _showProjectAccessDeniedAndGoHome(context);
        return;
      }
    }
  }

  /// 프로젝트 접근 거부 시 기존과 동일한 EasyLoading 팝업 후 홈으로 이동
  void _showProjectAccessDeniedAndGoHome(BuildContext context) {
    EasyLoading.showInfo('권한이 없는 프로젝트입니다.').then((_) {
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (context.mounted) {
          context.go('/home');
        }
      });
    });
  }

  Future<bool> checkLoginStatus() async {
    final loginName = await loginController.getUser();

    if (loginName != null) {
      return true;
    }
    return false;
  }

  Future<bool> checkTempSaveData(
      String projectId, String pageId, BuildContext context) async {
    return true;
  }

  /// 프로젝트 조회. 접근 거부(403) 시 [ProjectResult.statusCode]가 403으로 반환되며,
  /// 호출부에서 EasyLoading + 홈 이동 처리하면 됨.
  Future<ProjectResult?> fetchProject(String projectId) async {
    final result = await apiService.fetchProject(projectId);
    if (result != null && result.statusCode == 403) {
      return result;
    }
    final project = result?.project;
    final projectPages = project?.pages ?? [];

    if (projectPages.isEmpty) return result;

    final pagesJson = project?.toPageJson();
    final treeListModel = TreeListModel.listFromJson(pagesJson!);

    final changePage = treeListModel.first;

    final loginUser = await loginController.getUser();
    String userDisplayName = '';
    String userId = '';
    bool editStatus = false;

    if (loginUser?.userId != null) {
      userDisplayName = loginUser?.displayName ?? '';
      userId = loginUser?.userId ?? '';

      final userInfo =
          await apiService.checkUserPermission(projectId: project?.id ?? '');
      final user = userInfo?.user;
      if (user != null) {
        editStatus = true;
      }
    }

    if (project?.projectAuth == ProjectAuthType.onlyMe.value &&
        editStatus == false) {
      debugPrint('####@@@unauthorized: onlyme ${rxDisplayType.value}');
      rxVulcanEditorData.value = VulcanEditorData(
          displayType: rxDisplayType.value =
              VulcanEditorDisplayType.unauthorized,
          userId: userId,
          projectOwner: result?.project?.userId,
          userDisplayName: userDisplayName,
          hasCover: project?.hasCover,
          hasToc: project?.hasToc);
      return result;
    }

    if (project?.projectAuth == ProjectAuthType.userLink.value &&
        loginUser == null &&
        editStatus == false) {
      debugPrint(
          '####@@@unauthorized: userlink, login user : ${loginUser?.userId} ${rxDisplayType.value}');
      rxVulcanEditorData.value = VulcanEditorData(
          displayType: rxDisplayType.value =
              VulcanEditorDisplayType.unauthorized,
          userId: userId,
          projectOwner: result?.project?.userId,
          userDisplayName: userDisplayName,
          hasCover: project?.hasCover,
          hasToc: project?.hasToc);
      return result;
    }

    if (project?.projectAuth == ProjectAuthType.publicLink.value &&
        loginUser == null &&
        editStatus == false) {
      debugPrint(
          '####@@@editor: publiclink, login user : ${loginUser?.userId} ${rxDisplayType.value}');
      rxVulcanEditorData.value = VulcanEditorData(
          displayType: rxDisplayType.value = VulcanEditorDisplayType.editor,
          loginName: userDisplayName,
          userDisplayName: userDisplayName,
          projectName: project?.name,
          userId: userId,
          projectId: project?.id,
          pages: treeListModel,
          isEdit: editStatus,
          projectAuth: project?.projectAuth,
          startPageId: project?.startPageId,
          projectOwner: project?.userId,
          hasCover: project?.hasCover,
          hasToc: project?.hasToc,
          sharedUserList: project?.sharedUsers
              ?.map((user) => VulcanUserData.fromJson(user.toJson()))
              .toList());
    } else {
      debugPrint(
          '####@@@editor: editor, login user : ${loginUser?.userId} ${rxDisplayType.value}');
      rxVulcanEditorData.value = VulcanEditorData(
          displayType: rxDisplayType.value = VulcanEditorDisplayType.editor,
          loginName: userDisplayName,
          userDisplayName: userDisplayName,
          projectName: project?.name,
          userId: userId,
          projectId: project?.id,
          pages: treeListModel,
          isEdit: editStatus,
          projectAuth: project?.projectAuth,
          startPageId: project?.startPageId,
          projectOwner: project?.userId,
          hasCover: project?.hasCover,
          hasToc: project?.hasToc,
          sharedUserList: project?.sharedUsers
              ?.map((user) => VulcanUserData.fromJson(user.toJson()))
              .toList());
    }

    rxVulcanEditorData.value = await fetchResources(
        projectId: projectId,
        fileType: 'image',
        data: rxVulcanEditorData.value);

    rxVulcanEditorData.value = await fetchResources(
        projectId: projectId,
        fileType: 'video',
        data: rxVulcanEditorData.value);

    rxVulcanEditorData.value = await fetchResources(
        projectId: projectId,
        fileType: 'audio',
        data: rxVulcanEditorData.value);

    rxVulcanEditorData.value = await fetchResources(
        projectId: projectId,
        fileType: 'office',
        data: rxVulcanEditorData.value);

    rxVulcanEditorData.value =
        rxVulcanEditorData.value.copyWith(changedPage: changePage);
    return result;
  }

  Future<void> createProject(
    BuildContext context,
    VulcanProjectSettingData data,
  ) async {
    final projectName = data.projectName;
    final targetFolderId = data.targetFolderId;
    final String? templateId = data.templateId;

    final languageCode = Get.locale?.languageCode ?? 'ko';

    final result = await apiService.createProject(
        folderId: targetFolderId,
        projectName: projectName,
        templateId: templateId,
        useCover: data.useCover,
        useToc: data.useToc,
        language: languageCode);

    // ✅ 구독 제한 에러 처리 (409 Conflict)
    if (result != null && result.statusCode == 409) {
      debugPrint('📦 409 에러 감지: ${result.message}');

      // 다국어 메시지 우선 사용 (백엔드 메시지 무시)
      final errorMessage = 'subscription_project_limit_exceeded'.tr;
      debugPrint('📦 최종 메시지: $errorMessage');

      EasyLoading.showError(
        errorMessage,
        duration: const Duration(seconds: 5),
      );

      // 홈으로 돌아가기
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted) {
          context.go(HomePage.route);
        }
      });
      return;
    }

    if (result?.statusCode != 200) {
      debugPrint('createProject failed: ${result?.message}');
      VulcanCloseDialogWidget(
        title: 'create_project_failed'.tr,
        content: Text(result?.message ?? ''),
      ).show(context);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted) {
          context.go(HomePage.route);
        }
      });
      return;
    }

    final project = result?.project;
    final projectPages = project?.pages ?? [];

    if (projectPages.isEmpty) return;

    rxProjectId.value = project?.id ?? '';

    final pagesJson = project?.toPageJson();
    final treeListModel = TreeListModel.listFromJson(pagesJson!);

    debugPrint(
        '####@@@editor: createProject, displayType : ${rxDisplayType.value}');
    rxVulcanEditorData.value = VulcanEditorData(
      displayType: rxDisplayType.value = VulcanEditorDisplayType.editor,
      projectName: project?.name,
      userId: loginController.userId.value,
      projectId: project?.id,
      changedPage: treeListModel.first,
      pages: treeListModel,
      isEdit: true,
      startPageId: project?.startPageId,
    );

    final userId = await loginController.getUser();
    if (userId != null) {
      rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
        changedPage: treeListModel.first,
        userDisplayName: userId.displayName,
        userId: userId.userId,
      );
    }
  }

  Future<void> createPage(Map<String, String?> value) async {
    final projectId = value['projectId'] ?? '';
    final parentId = value['parentId'];

    final result = await apiService.createPage(projectId, parentId);

    // ✅ 구독 제한 에러 처리 (409 Conflict)
    if (result != null && result.statusCode == 409) {
      debugPrint('📦 페이지 생성 409 에러 감지: ${result.message}');

      // 다국어 메시지 우선 사용 (백엔드 메시지 무시)
      final errorMessage = 'subscription_page_limit_exceeded'.tr;
      debugPrint('📦 최종 메시지: $errorMessage');

      EasyLoading.showError(
        errorMessage,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    final project = result?.project;
    final projectPages = project?.pages ?? [];

    if (projectPages.isEmpty) return;

    final pagesJson = project?.toPageJson();
    final treeListModel = TreeListModel.listFromJson(pagesJson!);

    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
      pages: treeListModel,
      clipArtPath: '',
      changedPage: treeListModel.last,
      widgetData: null,
      isEdit: true,
    );
    update();
  }

  Future<void> deletePage(Map<String, String> page) async {
    String projectId = page['projectId'] ?? '';
    String pageId = page['pageId'] ?? '';

    final result =
        await apiService.deletePage(projectId: projectId, pageId: pageId);

    final project = result?.project;
    final projectPages = project?.pages ?? [];

    if (projectPages.isEmpty) return;

    final pagesJson = project?.toPageJson();
    final treeListModel = TreeListModel.listFromJson(pagesJson!);

    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
      pages: treeListModel,
      clipArtPath: '',
      changedPage: treeListModel.first,
      widgetData: null,
    );
    update();
  }

  Future<void> copyPage(Map<String, String> page) async {
    String projectId = page['projectId'] ?? '';
    String pageId = page['pageId'] ?? '';
    String href = page['href'] ?? '';
    String title = page['title'] ?? '';
    final result = await apiService.copyPage(
        projectId: projectId, pageId: pageId, href: href, title: title);

    final project = result?.project;
    final projectPages = project?.pages ?? [];

    if (projectPages.isEmpty) return;

    final pagesJson = project?.toPageJson();
    final treeListModel = TreeListModel.listFromJson(pagesJson!);

    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
      pages: treeListModel,
      clipArtPath: '',
      changedPage: treeListModel.last,
      widgetData: null,
      isEdit: true,
    );
  }

  Future<void> movePage(Map<String, String> page) async {
    String projectId = page['projectId'] ?? '';
    String movedPageId = page['movedPageId'] ?? '';
    String targetPageId = page['targetPageId'] ?? '';
    String position = page['position'] ?? '';
    final result = await apiService.movePage(
        projectId: projectId,
        movedPageId: movedPageId,
        targetPageId: targetPageId,
        position: position);

    final project = result?.project;
    final projectPages = project?.pages ?? [];

    if (projectPages.isEmpty) return;

    final pagesJson = project?.toPageJson();
    final treeListModel = TreeListModel.listFromJson(pagesJson!);

    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
      pages: treeListModel,
      clipArtPath: '',
      changedPage: null,
      widgetData: null,
    );
  }

  Future<void> renamePage(Map<String, String> page) async {
    String projectId = page['projectId'] ?? '';
    String pageId = page['pageId'] ?? '';
    String title = page['title'] ?? '';
    String href = page['href'] ?? '';
    String idref = page['idref'] ?? '';
    bool linear = page['linear'] == 'true';
    final result = await apiService.renamePage(
        projectId: projectId,
        pageId: pageId,
        title: title,
        idref: idref,
        href: href,
        linear: linear);

    final project = result?.project;
    final projectPages = project?.pages ?? [];

    if (projectPages.isEmpty) return;

    final pagesJson = project?.toPageJson();
    final treeListModel = TreeListModel.listFromJson(pagesJson!);

    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
      pages: treeListModel,
      clipArtPath: '',
      changedPage: null,
      widgetData: null,
      isEdit: true,
    );
  }

  Future<void> placementPropertyPage(
      TreeListModel? currentPage, Map<String, String> page) async {
    String projectId = page['projectId'] ?? '';
    String pageId = page['pageId'] ?? '';
    String property = page['property'] ?? '';
    Map<String, String> properties = {'rendition': property};

    final result = await apiService.placementPropertyPage(
        projectId: projectId, pageId: pageId, properties: properties);

    final project = result?.project;
    final projectPages = project?.pages ?? [];

    if (projectPages.isEmpty) return;
    final pagesJson = project?.toPageJson();
    final treeListModel = TreeListModel.listFromJson(pagesJson!);

    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
      pages: treeListModel,
      clipArtPath: '',
      changedPage: currentPage,
      widgetData: null,
      isEdit: true,
    );
  }

  Future<void> removeTempSaveData(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(projectId);
  }

  Future<Map<String, String>?> loadTempSaveData(
      String projectId, String selectedPageId) async {
    final prefs = await SharedPreferences.getInstance();
    final tempSaveData = prefs.getStringList(projectId);
    if (tempSaveData == null) return null;
    final userId = tempSaveData[0];
    final projectNum = tempSaveData[1];
    final pageId = tempSaveData[2];
    final content = tempSaveData[3];
    final fileName = tempSaveData[4];
    final capturePage = tempSaveData[5];
    final saveTime = tempSaveData[6];

    if (pageId != selectedPageId) {
      return null;
    }

    return {
      'userId': userId,
      'projectId': projectNum,
      'pageId': pageId,
      'content': content,
      'fileName': fileName,
      'capturePage': capturePage,
      'saveTime': saveTime,
    };
  }

  Future<void> setStartPage(
      TreeListModel? currentPage, Map<String, String> page) async {
    String projectId = page['projectId'] ?? '';
    String pageId = page['pageId'] ?? '';

    try {
      EasyLoading.show(status: '시작 페이지 설정 중...');
      final result = await apiService.setStartPage(
        projectId: projectId,
        pageId: pageId,
      );

      if (result != null) {
        rxVulcanEditorData.value = rxVulcanEditorData.value
            .copyWith(startPageId: result.project?.startPageId);

        update();
        EasyLoading.dismiss();
      }
      EasyLoading.dismiss();
    } catch (e) {
      logger.e('Error setting start page', e);
      EasyLoading.dismiss();
    }
  }

  Future<void> tempSave(Map<String, String> page) async {
    final userId = page['userId'] ?? '';
    String projectId = page['projectId'] ?? '';
    String pageId = page['pageId'] ?? '';
    String fileName = page['fileName'] ?? '';
    String content = page['content'] ?? '';
    String capturePage = page['capturePage'] ?? '';
    String saveTime = page['saveTime'] ?? '';
    final prefs = await SharedPreferences.getInstance();

    final tempSaveData = await loadTempSaveData(projectId, pageId);

    if (tempSaveData != null) {
      await removeTempSaveData(projectId);
      if (projectId.isEmpty) {
        await prefs.setStringList(rxProjectId.value, [
          userId,
          projectId,
          pageId,
          content,
          fileName,
          capturePage,
          saveTime
        ]);
      } else {
        await prefs.setStringList(projectId, [
          userId,
          projectId,
          pageId,
          content,
          fileName,
          capturePage,
          saveTime
        ]);
      }
    } else {
      await removeTempSaveData(projectId);
      if (projectId.isEmpty) {
        await prefs.setStringList(rxProjectId.value, [
          userId,
          projectId,
          pageId,
          content,
          fileName,
          capturePage,
          saveTime
        ]);
      } else {
        await prefs.setStringList(projectId, [
          userId,
          projectId,
          pageId,
          content,
          fileName,
          capturePage,
          saveTime
        ]);
      }
    }
  }

  Future<void> updateToc(Map<String, String> value) async {
    final projectId = value['projectId'] ?? '';
    final pageId = value['pageId'] ?? '';
    final type = value['type'] ?? '';

    final result = await apiService.updateToc(projectId, pageId, type: type);

    final project = result?.project;
    final projectPages = project?.pages ?? [];

    if (projectPages.isEmpty) return;

    final pagesJson = project?.toPageJson();
    final treeListModel = TreeListModel.listFromJson(pagesJson!);

    final tocPage = treeListModel.firstWhere((page) => page.type == "toc");

    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
      pages: treeListModel,
      clipArtPath: '',
      changedPage: tocPage,
      widgetData: null,
      isEdit: true,
    );
  }

  Future<void> convertTocToNormal(String projectId, String pageId) async {
    try {
      final result = await apiService.convertTocToNormal(projectId, pageId);

      if (result != null) {
        final project = result.project;
        final projectPages = project?.pages ?? [];

        if (projectPages.isNotEmpty) {
          final pagesJson = project?.toPageJson();
          final treeListModel = TreeListModel.listFromJson(pagesJson!);

          final convertedPage =
              treeListModel.firstWhere((page) => page.id == pageId);

          rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
            pages: treeListModel,
            changedPage: convertedPage,
            clipArtPath: '',
            widgetData: null,
          );

          update();
        }
      }
    } catch (e) {
      logger.e('Error converting TOC to normal', e);
      EasyLoading.showError('TOC → Normal 변환 중 오류가 발생했습니다.');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> updateListNumbering(Map<String, String> value) async {
    final projectId = value['projectId'] ?? '';
    final listStyleOption = value['listStyleOption'] ?? 've-vlist1';
    final pageId = value['pageId'] ?? '';

    if (projectId.isEmpty) {
      EasyLoading.showError('프로젝트 ID가 필요합니다.');
      return;
    }

    try {
      EasyLoading.show(status: 'list_numbering_update'.tr);

      final result = await apiService.updateListNumbering(
        projectId: projectId,
        listStyleOption: listStyleOption,
      );

      if (result != null && result.project != null) {
        final project = result.project;
        final projectPages = project?.pages ?? [];

        if (projectPages.isNotEmpty) {
          final pagesJson = project?.toPageJson();
          final treeListModel = TreeListModel.listFromJson(pagesJson!);

          final convertedPage =
              treeListModel.firstWhere((page) => page.id == pageId);

          rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
            pages: treeListModel,
            clipArtPath: '',
            changedPage: convertedPage,
            widgetData: null,
            isEdit: true,
          );

          update();
        }

        EasyLoading.showSuccess(
            result.message ?? 'list_numbering_updated_successfully'.tr);
        logger.d('목록 번호 업데이트 성공');
      } else {
        final errorMessage =
            result?.message ?? 'list_numbering_update_failed'.tr;
        EasyLoading.showError(errorMessage);
        logger.d('목록 번호 업데이트 실패: $errorMessage');
      }
    } catch (e) {
      EasyLoading.showError('list_numbering_update_error'.tr);
      logger.e('목록 번호 업데이트 중 오류 발생', e);
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> shortUrl(BuildContext context, String url) async {
    final result = await apiService.shortUrl(url);

    final shortUrl = result?.shortUrl;

    if (shortUrl == null) return;

    final path = shortUrl.shortUrl;
    await Clipboard.setData(ClipboardData(text: path));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('클립보드에 복사되었습니다')),
      );
    }
  }

  Future<void> updateProjectAuth(Map<String, String> value) async {
    final projectId = value['projectId'] ?? '';
    final projectAuth = value['projectAuth'] ?? '';

    final result = await apiService.updateProjectAuth(projectId, projectAuth);

    if (result != null) {
      logger.d('프로젝트 공유 설정이 변경되었습니다: $projectAuth');
      rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
        projectAuth: projectAuth,
      );
      update();
    }
  }

  Future<void> getUserList(String projectId) async {
    rxIsUserListLoading.value = true;
    try {
      final result = await apiService.getUserList(projectId);

      rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
        sharedUserList: result?.users
            ?.map((user) => VulcanUserData.fromJson(user.toJson()))
            .toList(),
      );
    } catch (e) {
      logger.e('사용자 목록 조회 중 오류 발생', e);
    } finally {
      rxIsUserListLoading.value = false;
    }
  }

  Future<void> findUserByTrigger(Map<String, String> params) async {
    final userId = params['userId'] ?? '';
    if (userId.isNotEmpty) {
      await findUser(userId);
    }
  }

  Future<UserInfoResult?> findUser(String userId) async {
    final result = await apiService.findUser(userId);
    return result;
  }

  Future<void> addUser(TreeListModel currentPage, Map<String, String> params,
      BuildContext context) async {
    final projectId = params['projectId'] ?? '';
    final userId = params['userId'] ?? '';
    final shareId = params['shareId'];
    bool isEmail = params['isEmail'] == 'true';

    try {
      // shareId가 있으면 ShareType.shareId 사용, 없으면 기존 로직
      final shareType = shareId != null && shareId.isNotEmpty
          ? ShareType.shareId
          : (isEmail ? ShareType.email : ShareType.userId);

      final result = await apiService.addUser(projectId, userId,
          shareType: shareType, shareId: shareId);
      final resultStatusCode = result?.data?['statusCode'] ?? 0;
      final resultMessage = result?.data?['message'] ?? '';

      if (result != null) {
        // ✅ 구독 제한 에러 처리 (409 Conflict)
        if (resultStatusCode == 409) {
          debugPrint('📦 공유 사용자 추가 409 에러 감지: $resultMessage');

          final errorMessage = 'subscription_collaborator_limit_exceeded'.tr;

          if (context.mounted) {
            VulcanCloseDialogWidget(
                    width: 300,
                    height: 150,
                    title: 'shared_project_input_error'.tr,
                    content: Text(errorMessage))
                .show(context);
          }
          return;
        }

        if (resultStatusCode == 200) {
          rxIsUserActionSuccess.value = true;
          rxUserActionMessage.value =
              'shared_project_user_add_success'.trArgs([userId]);
          if (context.mounted) {
            VulcanCloseDialogWidget(
                    width: 300,
                    height: 150,
                    title: 'shared_project_input_success'.tr,
                    content: Text(isEmail
                        ? AutoConfig.instance.domainType.isClosedNetworkDomain
                            ? 'shared_project_user_add_success_with_email'
                                .trArgs([userId])
                            : 'shared_project_user_add_success_with_email_send_message'
                                .trArgs([userId])
                        : 'shared_project_user_add_success_without_email'
                            .trArgs([userId])))
                .show(context)
                .then((value) {
              getUserList(projectId);
            });
          }
          getUserList(projectId);
        } else if (resultStatusCode == 400) {
          rxUserActionMessage.value = result.message;
          if (context.mounted) {
            VulcanCloseDialogWidget(
                    width: 300,
                    height: 150,
                    title: 'shared_project_input_error'.tr,
                    content: Text(resultMessage))
                .show(context)
                .then((value) {
              getUserList(projectId);
            });
          }
        } else if (resultStatusCode == 500) {
          rxUserActionMessage.value = result.message;
          if (context.mounted) {
            VulcanCloseDialogWidget(
                    width: 300,
                    height: 150,
                    title: 'shared_project_link_create_error'.tr,
                    content: Text(resultMessage))
                .show(context)
                .then((value) {
              getUserList(projectId);
            });
          }
        } else {
          rxUserActionMessage.value = 'shared_project_input_error'.tr;
        }
      } else {
        rxUserActionMessage.value = 'shared_project_input_error'.tr;
      }
    } catch (e) {
      rxUserActionMessage.value = 'shared_project_input_error'.tr;
    }
  }

  Future<void> deleteUser(Map<String, String> params) async {
    final projectId = params['projectId'] ?? '';
    final userId = params['userId'] ?? '';

    rxIsUserActionSuccess.value = false;

    try {
      final result = await apiService.deleteUser(projectId, userId);

      if (result != null) {
        rxIsUserActionSuccess.value = true;
        rxUserActionMessage.value = 'shared_project_delete_success'.tr;
        getUserList(projectId);
      } else {
        rxUserActionMessage.value = 'shared_project_delete_error_message'.tr;
      }
    } catch (e) {
      rxUserActionMessage.value =
          'shared_project_delete_user_error'.trArgs([e.toString()]);
    }
  }

  Future<void> uploadFile(
      TreeListModel? currentPage, dio.FormData formData) async {
    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
      changedPage: null,
      clipArtPath: '',
      widgetData: null,
    );

    final result = await apiService.uploadFile(formData);

    debugPrint('uploadFile result: ${result?.statusCode}, ${result?.message}');
    // ✅ 저장 용량 제한 에러 처리 (413 Payload Too Large)
    if (result != null && result.statusCode == 413) {
      // 디버그 로그
      debugPrint('📦 413 에러 감지: ${result.message}');

      // 다국어 메시지 우선 사용 (백엔드 메시지 무시)
      final errorMessage = 'subscription_storage_limit_exceeded'.tr;
      debugPrint('📦 최종 메시지: $errorMessage');

      EasyLoading.showError(
        errorMessage,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    final resource = result?.resource;
    final resources = result?.resources ?? [];

    final fileType = resource?.fileType ?? '';

    if (fileType.contains('image')) {
      rxVulcanEditorData.value = rxVulcanEditorData.value
          .copyWith(imageResources: _toVulcanResourceDataList(resources));
    } else if (fileType.contains('audio')) {
      rxVulcanEditorData.value = rxVulcanEditorData.value
          .copyWith(audioResources: _toVulcanResourceDataList(resources));
    } else if (fileType.contains('video')) {
      rxVulcanEditorData.value = rxVulcanEditorData.value
          .copyWith(videoResources: _toVulcanResourceDataList(resources));
    } else if (fileType.contains('office')) {
      rxVulcanEditorData.value = rxVulcanEditorData.value
          .copyWith(officeResources: _toVulcanResourceDataList(resources));
    }
    update();
  }

  Future<VulcanEditorData> fetchResources(
      {required String projectId,
      required String fileType,
      required VulcanEditorData data}) async {
    final result = await apiService.fetchReousrces(projectId, fileType);
    final resources = result?.resources ?? [];

    final vulcanResourceData = _toVulcanResourceDataList(resources);

    if (fileType.contains('image')) {
      return data.copyWith(
          imageResources: vulcanResourceData,
          clipArtPath: '',
          widgetData: null);
    } else if (fileType.contains('audio')) {
      return data.copyWith(
          audioResources: vulcanResourceData,
          clipArtPath: '',
          widgetData: null);
    } else if (fileType.contains('video')) {
      return data.copyWith(
          videoResources: vulcanResourceData,
          clipArtPath: '',
          widgetData: null);
    } else if (fileType.contains('office')) {
      return data.copyWith(
          officeResources: vulcanResourceData,
          clipArtPath: '',
          widgetData: null);
    }

    return data;
  }

  Future<void> clipArt(String projectId, TreeListModel currentPage, String path,
      String type, String clipartType) async {
    final result = await apiService.fetchClipArt(
        projectId: projectId, path: path, type: clipartType);
    result;
    final clipArtPath = result?.resource?.fileName ?? '';

    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
        clipArtPath: clipArtPath,
        resourceType: type,
        isEdit: true,
        changedPage: null,
        widgetData: null);
    update();
  }

  Future<void> updatePageContent(Map<String, String> pageContent) async {
    String projectId = pageContent['projectId'] ?? '';
    String pageId = pageContent['pageId'] ?? '';
    String fileName = pageContent['fileName'] ?? '';
    String content = pageContent['content'] ?? '';
    String capturePage = pageContent['capturePage'] ?? '';

    final result = await apiService.updatePageContent(
        projectId: projectId,
        pageId: pageId,
        fileName: fileName,
        content: content);

    if (result == null || result.isError) {
      logger.d('페이지 저장 에러 - [${result?.statusCode}] ${result?.message}');
    }

    if (result != null) {
      if (result.statusCode == 403) {
        EasyLoading.showError('no_permission'.tr);
      } else {
        removeTempSaveData(projectId);
      }
    }
  }

  Future<void> activePage(Map<String, String> value) async {
    String projectId = value['projectId'] ?? '';
    String type = value['type'] ?? '';
    bool isActive = value['isActive'] == 'true';

    final result = await apiService.activePage(projectId, type, isActive);

    final project = result?.project;
    final projectPages = project?.pages ?? [];

    if (projectPages.isEmpty) return;

    final pagesJson = project?.toPageJson();
    final treeListModel = TreeListModel.listFromJson(pagesJson!);

    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
      pages: treeListModel,
      clipArtPath: '',
      changedPage: null,
      widgetData: null,
    );
    update();
  }

  Future<void> downloadFile(String title, String fileType) async {
    final result = await apiService.downloadFile(title, fileType);
    rxIsDownload.value = result;
    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
      clipArtPath: '',
      widgetData: null,
    );
    update();
  }

  Future<void> downloadXhtmlFile(String fileName) async {
    final result = await apiService.downloadXhtmlFile(fileName);
    rxIsDownload.value = result;
    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
      clipArtPath: '',
      widgetData: null,
    );
    update();
  }

  Future<void> exportEpub(VulcanEpubData epubData) async {
    try {
      EasyLoading.show(status: 'EPUB 파일 생성 및 다운로드 중...');

      final result = await apiService.downloadEpub(epubData);

      if (result == null) {
        logger.d('EPUB 생성 및 다운로드 에러 - [알수없는 오류]');
        EasyLoading.showError('EPUB 다운로드 중 오류가 발생했습니다.');
      } else {
        await downloadFile('${result.epubInfo!.title}', 'epub');
        EasyLoading.dismiss();
      }
    } catch (e) {
      logger.e('EPUB 생성 및 다운로드 에러', e);
      EasyLoading.showError('EPUB 다운로드 중 오류가 발생했습니다.');
    }
  }

  Future<void> exportXhtml(VulcanXhtmlData xhtmlData) async {
    try {
      EasyLoading.show(status: 'XHTML 파일 생성 및 다운로드 중...');

      final result = await apiService.downloadXhtml(xhtmlData);

      if (result == null) {
        logger.d('XHTML 생성 및 다운로드 에러 - [알수없는 오류]');
        EasyLoading.showError('XHTML 다운로드 중 오류가 발생했습니다.');
      } else {
        await downloadFile(result.xhtmlInfo!.fileName, 'zip');
        EasyLoading.dismiss();
      }
    } catch (e) {
      logger.e('XHTML 생성 및 다운로드 에러', e);
      EasyLoading.showError('XHTML 다운로드 중 오류가 발생했습니다.');
    }
  }

  Future<void> exportTxt(VulcanTxtData txtData) async {
    try {
      EasyLoading.show(status: 'TXT 파일 생성 및 다운로드 중...');

      final result = await apiService.downloadTxt(txtData);

      if (result == null) {
        logger.d('TXT 생성 및 다운로드 에러 - [알수없는 오류]');
        EasyLoading.showError('TXT 다운로드 중 오류가 발생했습니다.');
      } else {
        await downloadFile(result.txtInfo!.title, 'txt');
        EasyLoading.dismiss();
      }
    } catch (e) {
      logger.e('TXT 생성 및 다운로드 에러', e);
      EasyLoading.showError('TXT 다운로드 중 오류가 발생했습니다.');
    }
  }

  Future<void> onCloudConnection(BuildContext context) async {
    await handleCloudConnection(
      context,
      onConnect: () {
        debugPrint(
            '[CloudConnection] onConnect: ${GoRouter.of(context).state.uri}');
        final loginController = Get.find<LoginController>();
        loginController.naverWorksLogin();
      },
    );
  }

  Future<void> uploadEpubToDrive(VulcanEpubData epubData,
      {String? folderId}) async {
    try {
      EasyLoading.show(status: 'EPUB 파일 생성 및 업로드 중...');

      final result = await apiService.uploadEpub(epubData);

      if (result != null && result.isSuccessful) {
        logger.d('EPUB 업로드 완료');
        EasyLoading.showSuccess('EPUB 파일이 업로드되었습니다.');
      } else {
        final message = result?.data['message'] ?? '업로드 중 오류가 발생했습니다.';
        logger.e('EPUB 생성 및 업로드 에러 - $message');
        EasyLoading.showError(message);
      }
    } catch (e) {
      logger.e('EPUB 생성 및 업로드 에러', e);
      EasyLoading.showError('EPUB 업로드 중 오류가 발생했습니다.');
    }
  }

  Future<void> uploadXhtmlToDrive(VulcanXhtmlData xhtmlData,
      {String? folderId}) async {
    try {
      EasyLoading.show(status: 'XHTML 파일 생성 및 업로드 중...');

      final result = await apiService.uploadXhtml(xhtmlData);

      if (result != null && result.isSuccessful) {
        logger.d('XHTML 업로드 완료');
        EasyLoading.showSuccess('XHTML 파일이 업로드되었습니다.');
      } else {
        final message = result?.data['message'] ?? '업로드 중 오류가 발생했습니다.';
        logger.e('XHTML 생성 및 업로드 에러 - $message');
        EasyLoading.showError(message);
      }
    } catch (e) {
      logger.e('XHTML 생성 및 업로드 에러', e);
      EasyLoading.showError('XHTML 업로드 중 오류가 발생했습니다.');
    }
  }

  Future<void> uploadTxtToDrive(VulcanTxtData txtData,
      {String? folderId}) async {
    try {
      EasyLoading.show(status: 'TXT 파일 생성 및 업로드 중...');

      final result = await apiService.uploadTxt(txtData);

      if (result != null && result.isSuccessful) {
        logger.d('TXT 업로드 완료');
        EasyLoading.showSuccess('TXT 파일이 업로드되었습니다.');
      } else {
        final message = result?.data['message'] ?? '업로드 중 오류가 발생했습니다.';
        logger.e('TXT 생성 및 업로드 에러 - $message');
        EasyLoading.showError(message);
      }
    } catch (e) {
      logger.e('TXT 생성 및 업로드 에러', e);
      EasyLoading.showError('TXT 업로드 중 오류가 발생했습니다.');
    }
  }

  Future<void> addWidget(
      TreeListModel currentPage, Map<String, String> value) async {
    final result = await apiService.addWidget(
        rxProjectId.value, value['widgetPath'] ?? '', value['type'] ?? '');
    if (result == null) {
      logger.d('위젯 추가 에러 - [${result?.statusCode}] ${result?.message}');
    }

    final widgetType = result?.widgetType;
    final resultWidgetPath = result?.widgetPath;
    final resultMarkup = result?.markup;
    final resultJsFiles = result?.jsFiles;
    final resultCssFiles = result?.cssFiles;
    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
        clipArtPath: '',
        changedPage: null,
        widgetData: VulcanWidgetData(
            widgetType: widgetType ?? '',
            widgetPath: resultWidgetPath ?? '',
            markup: resultMarkup ?? '',
            jsFiles: resultJsFiles ?? [],
            cssFiles: resultCssFiles ?? []));
    update();
  }

  Future<void> editPermission(
      TreeListModel currentPage, Map<String, String> value) async {
    final pageId = value['pageId'] ?? '';
    final userId = value['userId'] ?? '';

    final result = await apiService.editPagePermission([pageId], userId);
    final project = result?.project;
    final projectPages = project?.pages ?? [];

    if (projectPages.isEmpty) return;

    final pagesJson = project?.toPageJson();
    final treeListModel = TreeListModel.listFromJson(pagesJson!);

    TreeListModel? updatedPage = treeListModel.firstWhere(
      (page) => page.id == currentPage.id,
      orElse: () => currentPage,
    );

    rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
      pages: treeListModel,
      clipArtPath: '',
      widgetData: null,
      changedPage: updatedPage,
    );
    update();
  }

  List<VulcanResourceData> _toVulcanResourceDataList(
      List<ResourceModel> resources) {
    return resources
        .map((resourceModel) => VulcanResourceData(
              id: resourceModel.id,
              fileName: resourceModel.fileName,
              thumbnailFileName: resourceModel.thumbnailFileName ?? '',
              fileType: resourceModel.fileType,
              size: resourceModel.size,
              description: resourceModel.description,
            ))
        .toList();
  }

  List<VulcanTemplateData> _toVulcanTemplateDataList(
      List<TemplateModel> templates) {
    return templates.map((template) {
      return VulcanTemplateData(
        id: template.id,
        name: template.name,
        authorNo: template.authorNo,
        thumbnail: template.thumbnail,
        thumbnailUrl: templateController.getImageUrl(template),
        templageUrl: templateController.templateUrl,
        favoriteCount: template.favoriteCount,
        free: template.free,
        fixed: template.fixed,
        category: template.category,
        createdAt: template.createdAt,
        modifiedAt: template.modifiedAt,
        pages: template.pages
            .map((page) => VulcanTemplatePage(
                  idref: page.idref,
                  linear: page.linear,
                  href: page.href,
                  thumbnail: page.thumbnail,
                  thumbnailUrl:
                      templateController.getPageImageUrl(template, page),
                  properties: page.properties,
                  createdAt: page.createdAt,
                  modifiedAt: page.modifiedAt,
                ))
            .toList(),
      );
    }).toList();
  }

  void resetUserActionState() {
    rxIsUserActionSuccess.value = false;
    rxUserActionMessage.value = '';
  }

  Future<bool?> createPageWithContent(Map<String, String> value) async {
    final projectId = value['projectId'] ?? '';
    final title = value['title'] ?? '';
    final page = value['page'] ?? '';
    final content = value['content'] ?? '';
    final fileName = value['fileName'] ?? '';

    try {
      logger.d('[OfficeIframe] Office 문서 $page페이지 변환: 시작');

      final safeFileName = fileName.safeFileName;

      final requestData = {
        'projectId': projectId,
        'title': title,
        'content': content,
        'fileName': safeFileName,
      };

      final result = await apiService.createPageWithContent(requestData);

      // ✅ 구독 제한 에러 처리 (409 Conflict)
      if (result != null && result.statusCode == 409) {
        logger.d('[OfficeIframe] Office 문서 $page페이지 변환: 페이지 생성 제한 초과');

        final errorMessage = 'subscription_page_limit_exceeded'.tr;
        EasyLoading.showError(
          errorMessage,
          duration: const Duration(seconds: 5),
        );
        return false;
      }

      if (result != null && result.statusCode == 200) {
        logger.d('[OfficeIframe] Office 문서 $page페이지 변환: 새 페이지 생성 성공');

        final project = result.project;
        final projectPages = project?.pages ?? [];

        if (projectPages.isNotEmpty) {
          final pagesJson = project?.toPageJson();
          final treeListModel = TreeListModel.listFromJson(pagesJson!);

          rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
            pages: treeListModel,
            changedPage: treeListModel.last,
            clipArtPath: '',
            widgetData: null,
          );

          update();

          return true;
        }
      } else {
        logger.d(
            '[OfficeIframe] Office 문서 $page페이지 변환: 새 페이지 생성 실패 - ${result?.message}');
        EasyLoading.showError(
            '페이지 생성에 실패했습니다: ${result?.message ?? '알 수 없는 오류'}');
      }
    } catch (e) {
      logger.e('[OfficeIframe] Office 문서 $page페이지 변환 중 오류 발생', e);
      EasyLoading.showError('Office 문서 변환 중 오류가 발생했습니다: ${e.toString()}');
    }
    return false;
  }

  Future<void> setCoverPage(
      TreeListModel? currentPage, Map<String, String> value) async {
    final projectId = value['projectId'] ?? '';
    final pageId = value['pageId'] ?? '';

    if (projectId.isEmpty || pageId.isEmpty) {
      EasyLoading.showError('필수 데이터가 누락되었습니다.');
      return;
    }

    try {
      EasyLoading.show(status: '커버 페이지 설정 중...');

      final result = await apiService.setCoverPage(
        projectId: projectId,
        pageId: pageId,
      );

      if (result != null) {
        final project = result.project;
        final projectPages = project?.pages ?? [];

        if (projectPages.isNotEmpty) {
          final pagesJson = project?.toPageJson();
          final treeListModel = TreeListModel.listFromJson(pagesJson!);

          rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
            pages: treeListModel,
            hasCover: project?.hasCover,
            changedPage: treeListModel.firstWhere(
              (page) => page.type == 'cover',
              orElse: () => currentPage!,
            ),
          );

          update();
        }

        EasyLoading.showSuccess('커버 페이지가 설정되었습니다.');
      } else {
        EasyLoading.showError('커버 페이지 설정에 실패했습니다.');
      }
    } catch (e) {
      EasyLoading.showError('커버 페이지 설정 중 오류가 발생했습니다.');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> unsetCoverPage(
      TreeListModel? currentPage, Map<String, String> value) async {
    final projectId = value['projectId'] ?? '';
    final pageId = value['pageId'] ?? '';

    if (projectId.isEmpty || pageId.isEmpty) {
      EasyLoading.showError('필수 데이터가 누락되었습니다.');
      return;
    }

    try {
      EasyLoading.show(status: '커버 페이지 해제 중...');

      final result = await apiService.unsetCoverPage(
        projectId: projectId,
        pageId: pageId,
      );

      if (result != null) {
        final project = result.project;
        final projectPages = project?.pages ?? [];

        if (projectPages.isNotEmpty) {
          final pagesJson = project?.toPageJson();
          final treeListModel = TreeListModel.listFromJson(pagesJson!);

          rxVulcanEditorData.value = rxVulcanEditorData.value.copyWith(
            pages: treeListModel,
            hasCover: project?.hasCover,
            changedPage: currentPage,
          );

          update();
        }

        EasyLoading.showSuccess('커버 페이지가 해제되었습니다.');
      } else {
        EasyLoading.showError('커버 페이지 해제에 실패했습니다.');
      }
    } catch (e) {
      logger.e('커버 페이지 해제 중 오류 발생', e);
      EasyLoading.showError('커버 페이지 해제 중 오류가 발생했습니다.');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> createThumbnail(
      TreeListModel? currentPage, Map<String, String> value) async {
    final projectId = value['projectId'] ?? '';
    final pageId = value['pageId'] ?? '';
    final thumbnailImage = value['thumbnailImage'] ?? '';

    if (projectId.isEmpty || pageId.isEmpty || thumbnailImage.isEmpty) {
      EasyLoading.showError('필수 데이터가 누락되었습니다.');
      return;
    }

    try {
      EasyLoading.show(status: '썸네일 생성 중...');

      final result = await apiService.thumbnail(
        projectId: projectId,
        pageId: pageId,
        thumbnailImage: thumbnailImage,
      );

      if (result != null && !result.isError) {
        EasyLoading.showSuccess('썸네일이 생성되었습니다.');
      } else {
        EasyLoading.showError('썸네일 생성에 실패했습니다.');
      }
    } catch (e) {
      logger.e('썸네일 생성 중 오류 발생', e);
      EasyLoading.showError('썸네일 생성 중 오류가 발생했습니다.');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    if (condition) {
      super.update(ids);
    }
  }
}
