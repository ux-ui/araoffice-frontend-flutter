import 'package:api/api.dart';
import 'package:app_ui/app_ui.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class PathInfo {
  final String name;
  final String id;

  PathInfo({required this.name, required this.id});
}

class ProjectController extends GetxController {
  final ProjectApiService apiService = Get.find<ProjectApiService>();
  final HistoryApiService historyApiService = Get.find<HistoryApiService>();
  final title = 'Project View'.obs;

  final rxFolderInfo = Rxn<FolderModel>();
  final rxUserId = ''.obs;
  final rxRecentProjects = <ProjectModel>[].obs;
  final rxAllFolders = Rxn<List<FolderModel>>();
  final rxProjectHistory = Rxn<List<HistoryModel>>();
  // final rxProjectHistoryExport = Rxn<List<ExportHistoryModel>>();
  final rxProjectHistoryExport = Rxn<List<HistoryModel>>();
  final rxProjectInfoList = Rxn<List<ProjectModel>>();

  final nameEditingController = TextEditingController();

  final rxIsHistoryDesc = true.obs;

  var _currentPath = '';
  var pathHistory = <PathInfo>[];

  final isNameEmpty = RxBool(false);

  void initSettings() {
    nameEditingController.text = '';
    clearPathInfo();
    getAllProjects();
  }

  void updateFolderInfo(FolderModel folder) {
    rxFolderInfo.value = folder;
  }

  Future<void> validateAndSubmitProjectName(String projectId) async {
    if (nameEditingController.text.trim().isEmpty) {
      isNameEmpty.value = true;
      return;
    }

    if (nameEditingController.text.length > 20) {
      // 20자가 넘어가면 20자까지 잘라서 저장
      nameEditingController.text = nameEditingController.text.substring(0, 20);
    }

    // 사전에 중복 검사: 전체 프로젝트 목록에서 중복 검사
    final projectName = nameEditingController.text.toLowerCase();
    final apiService = Get.find<ProjectApiService>();
    final projectListResult = await apiService.fetchProjectList();
    final projects = projectListResult?.projects ?? [];
    if (projects.any((e) => e.name.toLowerCase() == projectName)) {
      EasyLoading.showError('duplicate_project_name'.tr);
      return;
    }

    //
    final result =
        await apiService.updateProject(name: projectName, projectId: projectId);
    if (result != null) {
      if (result.statusCode == 400) {
        EasyLoading.showInfo(result.message ?? '');
      } else {
        EasyLoading.showSuccess('project_update_success'.tr);
        final folderInfo = result.folder;
        if (folderInfo != null) {
          updateFolderInfo(folderInfo);
          // update();
        }
      }
    }
  }

  Future<void> validateAndSubmitFolderName(String folderId) async {
    if (nameEditingController.text.trim().isEmpty) {
      isNameEmpty.value = true;
      return;
    }

    if (nameEditingController.text.length > 20) {
      // 20자가 넘어가면 20자까지 잘라서 저장
      nameEditingController.text = nameEditingController.text.substring(0, 20);
    }

    // 사전에 중복 검사: 전체 프로젝트 목록에서 중복 검사
    final folderName = nameEditingController.text.toLowerCase();
    final apiService = Get.find<ProjectApiService>();
    final folderListResult = await apiService.getAllFolders();
    final folders = folderListResult?.folders ?? [];
    if (folders.any((e) => e.folderName.toLowerCase() == folderName)) {
      EasyLoading.showError('duplicate_folder_name'.tr);
      return;
    }

    //
    final result =
        await apiService.updateFolder(folderId: folderId, name: folderName);
    if (result != null) {
      if (result.statusCode == 400) {
        EasyLoading.showInfo(result.message ?? '');
      } else {
        EasyLoading.showSuccess('folder_update_success'.tr);
        final folderInfo = result.folder;
        if (folderInfo != null) {
          updateFolderInfo(folderInfo);
          // update();
        }
      }
    }
  }

  Future<void> getProjectHistory(String projectId) async {
    final result = await historyApiService.fetchHistory(
      projectId,
      rxIsHistoryDesc.value,
    );
    if (result != null) {
      rxProjectHistory.value = result.history ??
          [
            HistoryModel(
              message: 'project_history_empty'.tr,
              createdAt: DateTime.now().toString(),
              user: UserModel(),
            )
          ];
    }
  }

  Future<void> getProjectHistoryExport(String projectId) async {
    // final result = await historyApiService.fetchExportHistory(projectId);
    final result = await historyApiService.fetchHistoryPublish(projectId, true);
    if (result != null) {
      rxProjectHistoryExport.value = result.history;
    }
    debugPrint(
        'getProjectHistoryExport: ${rxProjectHistoryExport.value?.length}');
  }

  Future<void> createProject(String folderId) async {
    final result = await apiService.createProject(
        projectName: 'Test Project', folderId: folderId);

    if (result != null) {
      // ✅ 구독 제한 에러 처리 (409 Conflict)
      if (result.statusCode == 409) {
        // 디버그 로그
        debugPrint('📦 409 에러 감지: ${result.message}');

        // 다국어 메시지 우선 사용 (백엔드 메시지 무시)
        final errorMessage = 'subscription_project_limit_exceeded'.tr;
        debugPrint('📦 최종 메시지: $errorMessage');

        EasyLoading.showError(
          errorMessage,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      // 기존 성공 처리
      if (result.folder != null) {
        rxFolderInfo.value = result.folder;
      }
    }
    logger.d('Created Project ${rxFolderInfo.value?.contents.length}');
  }

  Future<void> deleteProject({required String projectId}) async {
    final result = await apiService.deleteProject(projectId: projectId);
    if (result != null) {
      final folderInfo = result.folder;
      if (folderInfo != null) {
        updateFolderInfo(folderInfo);
        // update();
      }
    }
    final recentResult = await apiService.fetchProjectRecent();
    if (recentResult != null) {
      rxRecentProjects.value = recentResult.projects ?? [];
    }
    debugPrint('delete Project ${rxFolderInfo.value?.contents.length}');
  }

  Future<void> updateProject({
    required String name,
    required String projectId,
  }) async {
    if (name.length > 20) {
      name = name.substring(0, 20);
    }
    final result =
        await apiService.updateProject(name: name, projectId: projectId);
    if (result != null) {
      if (result.statusCode == 400) {
        // 중복 또는 20자 초과 오류
        EasyLoading.showInfo(result.message ?? '');
      }
      if (result.statusCode == 403) {
        // 수정 권한 없음 오류
        EasyLoading.showError('no_permission'.tr);
      } else {
        final folderInfo = result.folder;
        if (folderInfo != null) {
          updateFolderInfo(folderInfo);
          // update();
        }
        debugPrint('Updated Project $result');
      }
    }
  }

  Future<FolderModel?> getRootFolder() async {
    final folderResult = await apiService.fetchFolder(folderId: 'root');
    return folderResult?.folder;
  }

  Future<void> getAllProjects() async {
    try {
      final folderResult = await apiService.fetchFolder(folderId: 'root');
      if (folderResult != null) {
        rxFolderInfo.value = folderResult.folder;
      }

      final recentResult = await apiService.fetchProjectRecent();
      if (recentResult != null) {
        rxRecentProjects.value = recentResult.projects ?? [];
      }

      final projectResult = await apiService.fetchProjectList();
      if (projectResult != null) {
        rxProjectInfoList.value = projectResult.projects;
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching projects', e, stackTrace);
    }
  }

  Future<void> createFolder({
    required String targetFolderId,
    required String name,
  }) async {
    try {
      if (name.length > 20) {
        name = name.substring(0, 20);
      }
      final result = await apiService.createFolder(
          targetFolderId: targetFolderId, name: name);
      if (result != null) {
        // rxFolderInfo.value = result.folder;
        if (result.statusCode == 400) {
          EasyLoading.showInfo(result.message ?? '');
        } else {
          rxFolderInfo.value = result.folder;
        }
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching projects', e, stackTrace);
    }
  }

  Future<void> updateFolder({
    required String folderId,
    required String name,
  }) async {
    if (name.length > 20) {
      name = name.substring(0, 20);
    }
    final result =
        await apiService.updateFolder(folderId: folderId, name: name);
    if (result != null) {
      if (result.statusCode == 400) {
        EasyLoading.showInfo(result.message ?? '');
      } else {
        final currentFolderItems = rxFolderInfo.value?.contents ?? [];
        final updatedFolderItems = currentFolderItems
            .map((e) => e.id == folderId ? e.copyWith(name: name) : e)
            .toList();
        rxFolderInfo.value =
            rxFolderInfo.value?.copyWith(contents: updatedFolderItems);
      }
    }
    debugPrint('Updated Folder $result');
  }

  Future<void> deleteFolder({required String folderId}) async {
    final result = await apiService.deleteFolder(folderId: folderId);
    if (result != null) {
      // rxFolderInfo.value = result.folder;
      final currentFolderItems = rxFolderInfo.value?.contents ?? [];
      final updatedFolderItems =
          currentFolderItems.where((e) => e.id != folderId).toList();
      rxFolderInfo.value =
          rxFolderInfo.value?.copyWith(contents: updatedFolderItems);
    }
    final recentResult = await apiService.fetchProjectRecent();
    if (recentResult != null) {
      rxRecentProjects.value = recentResult.projects ?? [];
    }
    logger.i('Delete Folder ${rxFolderInfo.value?.contents.length}');
  }

  Future<void> selectFolder(String folderId) async {
    try {
      final result = await apiService.fetchFolder(folderId: folderId);
      if (result != null) {
        rxFolderInfo.value = result.folder;
      }
    } catch (e) {
      logger.e('Error fetching folder $folderId', e);
    }
  }

  Future<void> moveProject({
    required String projectId,
    required String currentFolderId,
    required String targetFolderId,
    required bool isRefresh,
  }) async {
    final result = await apiService.moveProject(
        projectId: projectId,
        currentFolderId: currentFolderId,
        targetFolderId: targetFolderId);
    if (result != null && isRefresh) {
      rxFolderInfo.value = result.folder;
    }
    if (rxFolderInfo.value != null) {
      final updateContents = rxFolderInfo.value!.contents
          .where((element) => element.id != projectId)
          .toList();
      rxFolderInfo.value =
          rxFolderInfo.value!.copyWith(contents: updateContents);
    }
    logger.i('move Project ${rxFolderInfo.value?.contents.length}');
  }

  Future<void> moveFolder({
    required String folderId,
    required String targetFolderId,
    required String currentFolderId,
    required bool isRefresh,
    required BuildContext context,
  }) async {
    final result = await apiService.moveFolder(
        targetFolderId: targetFolderId,
        currentFolderId: currentFolderId,
        folderId: folderId);

    if (result == null) {
      return;
    }

    // 400 에러인 경우 다이얼로그 표시하고 이동하지 않음
    if (result.statusCode == 400) {
      if (!context.mounted) return;
      await VulcanCloseDialogWidget(
        width: 320,
        height: 180,
        title: 'duplicate_file_name'.tr,
        content: Text(result.message ?? 'duplicate_file_name'.tr),
        isShowConfirm: true,
      ).show(context);
      return;
    }

    // 200 성공인 경우에만 폴더 이동 처리
    if (result.statusCode == 200) {
      if (isRefresh) {
        rxFolderInfo.value = result.folder;
      }
      if (rxFolderInfo.value != null) {
        final updateContents = rxFolderInfo.value!.contents
            .where((element) => element.id != folderId)
            .toList();
        rxFolderInfo.value =
            rxFolderInfo.value!.copyWith(contents: updateContents);
      }
      logger.i('move Folder ${rxFolderInfo.value?.contents.length}');
    }
  }

  void updateEditingController(String text) {
    nameEditingController.text = text;
    nameEditingController.selection =
        TextSelection(baseOffset: 0, extentOffset: text.length);
  }

  void addPathInfo(String folderName, String folderId) {
    logger.d('addPathInfo: $folderName, $folderId');
    pathHistory.add(PathInfo(name: folderName, id: folderId));
    _currentPath += _currentPath.isEmpty ? folderName : '/$folderName';
    logger.d('  PathInfo: $_currentPath');
  }

  void removePathInfo(int? start) {
    logger.d('removePathInfo: $start');
    if (start != null) {
      pathHistory.removeRange(start, pathHistory.length);
    } else {
      pathHistory.removeLast();
    }
    _currentPath = pathHistory.map((p) => p.name).join('/');
    logger.d('  PathInfo: $_currentPath');
  }

  void clearPathInfo() {
    logger.d('clearPathInfo');
    pathHistory.clear();
    _currentPath = '';
  }
}

extension DateTimeFormatting on DateTime {
  String toReadableString() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inMinutes < 60) {
      // return '${difference.inMinutes}분 전';
      return 'time_minute'.trArgs([difference.inMinutes.toString()]);
    } else if (difference.inHours < 24) {
      // return '${difference.inHours}시간 전';
      return 'time_hour'.trArgs([difference.inHours.toString()]);
    } else if (difference.inDays < 7) {
      // return '${difference.inDays}일 전';
      return 'time_day'.trArgs([difference.inDays.toString()]);
    } else if (difference.inDays < 30) {
      // return '${(difference.inDays / 7).floor()}주 전';
      return 'time_week'.trArgs([(difference.inDays / 7).floor().toString()]);
    } else if (difference.inDays < 365) {
      // return '${(difference.inDays / 30).floor()}개월 전';
      return 'time_month'.trArgs([(difference.inDays / 30).floor().toString()]);
    } else {
      // return '$year.${month.toString().padLeft(2, '0')}.${day.toString().padLeft(2, '0')}';
      return 'time_year'.trArgs([year.toString()]);
    }
  }
}
