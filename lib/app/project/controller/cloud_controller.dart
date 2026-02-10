import 'package:api/api.dart';
import 'package:author_editor/enum/enums.dart';
import 'package:author_editor/mixins/dragdocs_mixin.dart';
import 'package:common_assets/common_assets.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../login/view/login_controller.dart';

class CloudController extends GetxController {
  final CloudApiService apiService = Get.find<CloudApiService>();
  final LoginController loginController = Get.find<LoginController>();
  final title = 'Cloud View'.obs;
  final tokenStatus = false.obs;

  List<CloudType> get supportedCloudTypes {
    final loginController = Get.find<LoginController>();
    switch (loginController.tenantType.value) {
      // case TenantType.mois:

      // case TenantType.ara:
      // return [CloudType.ara];
      // return [CloudType.works];
      case TenantType.ara:
        return [CloudType.works];
      // case TenantType.msit:
      //   return [CloudType.works];
      case TenantType.mfds:
        return [CloudType.works];
      case TenantType.mois:
        return [CloudType.works];
      case TenantType.naverWorks:
        return [CloudType.works];
      default:
        return [];
    }
  }

  // 현재 클라우드 타입
  final Rx<CloudType> rxCurrentCloudType = CloudType.works.obs;

  // 클라우드 파일 리스트
  final RxList<CloudFileModel> rxCloudFiles = <CloudFileModel>[].obs;

  // 현재 폴더 정보
  final Rx<CloudFileModel?> rxCurrentFolder = Rxn<CloudFileModel>();

  // 로딩 상태
  final RxBool rxIsLoading = false.obs;

  // 에러 메시지
  final RxString rxErrorMessage = ''.obs;

  // 페이징 관련
  final RxString rxNextCursor = ''.obs;
  final RxBool rxHasMoreData = false.obs;

  // 현재 경로
  final RxString rxCurrentPath = '/'.obs;
  final rxCurrentPathParts = <CloudFileModel>[].obs;

  // 검색어
  final RxString rxSearchQuery = ''.obs;

  // 정렬 기준
  final RxString rxSortBy = 'name'.obs; // name, size, modifiedTime, createdTime
  final RxBool rxSortAscending = true.obs;

  // 선택된 파일들
  final RxList<String> rxSelectedFileIds = <String>[].obs;

  // 연결 상태
  final RxBool rxIsNaverWorksConnected = false.obs;
  final RxBool rxIsBrityWorksConnected = false.obs;

  // Text Controllers
  final nameEditingController = TextEditingController();
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initSettings();
  }

  @override
  void onClose() {
    nameEditingController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void initSettings() {
    // 네이버 웍스 연결 상태 확인만 수행 (데이터 로드는 CloudFileTreePage에서 수행)
    checkCloudConnection();
    // 컨트롤러 초기화
    nameEditingController.clear();
    searchController.clear();
    checkTokenStatus();
  }

  void checkTokenStatus() async {
    final token = await apiService.getNaverWorksTokenNoRedirect();
    if (token != null && token.isNotEmpty) {
      tokenStatus.value = true;
    } else {
      tokenStatus.value = false;
    }
  }

  /// 클라우드 연결 상태 확인
  Future<bool> checkCloudConnection() async {
    try {
      rxIsLoading.value = true;
      rxErrorMessage.value = '';

      final loginController = Get.find<LoginController>();
      final tokenResponse =
          await loginController.apiClient.getUserAccessToken();
      if (tokenResponse != null && !tokenResponse.isError) {
        final tokenData = tokenResponse.data;
        if (tokenData != null) {
          // TODO: 클라우드 타입에 따른 연결 상태 확인
          rxIsNaverWorksConnected.value =
              // (loginController.userLoginType.value ==
              // UserLoginType.naverWorks ||

              // (loginController.tenantType.value == TenantType.mois ||
              //         loginController.tenantType.value == TenantType.ara)
              (loginController.tenantType.value == TenantType.msit ||
                      loginController.tenantType.value ==
                          TenantType.naverWorks ||
                      loginController.tenantType.value == TenantType.mois ||
                      loginController.tenantType.value == TenantType.mfds ||
                      loginController.savedUserLoginType.value ==
                          UserLoginType.naverWorks ||
                      loginController.tenantType.value == TenantType.ara)
                  ? true
                  : false;
        }
      } else {
        rxIsNaverWorksConnected.value = false;
        return false;
      }
      return rxIsNaverWorksConnected.value;

      // final token = await apiService.getNaverWorksToken();
      // if (token != null && token.isNotEmpty) {
      //   // TODO: 클라우드 타입에 따른 연결 상태 확인
      //   rxIsNaverWorksConnected.value = true;
      //   return true;
      // } else {
      //   rxIsNaverWorksConnected.value = false;
      //   return false;
      // }
    } catch (e) {
      rxIsNaverWorksConnected.value = false;
      rxErrorMessage.value = 'Error checking connection: $e';
      logger.e('Error checking cloud connection', e);
      return false;
    } finally {
      rxIsLoading.value = false;
    }
  }

  Future<void> loadFilesOnInit() async {
    // 연결 상태가 확인되지 않았으면 먼저 확인
    if (rxIsNaverWorksConnected.value) {
      final isConnected = await checkCloudConnection();
      if (isConnected) {
        debugPrint(
            '###@@@ Call Cloud Controller: loadFilesOnInit: loadCloudFiles $isConnected');
        loadCloudFiles(refresh: true);
      }
    } else {
      // 이미 연결 상태가 확인되었으면 바로 로드
      loadCloudFiles(refresh: true);
    }
  }

  /// 클라우드 파일 목록 로드
  Future<void> loadCloudFiles({bool refresh = false}) async {
    // 연결 상태 확인: 연결되지 않았으면 로드하지 않음

    try {
      rxIsLoading.value = true;
      rxErrorMessage.value = '';

      debugPrint(
          '####@@@ loadCloudFiles: rxCurrentCloudType: ${rxCurrentCloudType.value}');
      debugPrint(
          '####@@@ loadCloudFiles: rxCurrentFolder: ${rxCurrentFolder.value}');
      debugPrint(
          '####@@@ loadCloudFiles: rxCloudFiles: ${rxCloudFiles.length}');
      debugPrint('####@@@ loadCloudFiles: rxIsLoading: ${rxIsLoading.value}');

      if (refresh) {
        debugPrint('####@@@ 4444 loadCloudFiles: refresh');
        rxCloudFiles.clear();
        rxNextCursor.value = '';
        rxHasMoreData.value = false;
      }

      // 검색 중인지 확인
      if (rxSearchQuery.value.isNotEmpty) {
        await _searchFiles(rxSearchQuery.value, refresh: refresh);
        debugPrint('####@@@ 3333 loadCloudFiles: searchFiles result}');
        return;
      }

      CloudFileListResult? result;

      // 현재 폴더가 있으면 해당 폴더의 하위 파일 조회, 없으면 루트 파일 조회
      if (rxCurrentFolder.value != null) {
        result = await apiService.fetchCloudFiles(
          cloudType: rxCurrentCloudType.value,
          folderId: rxCurrentFolder.value!.fileId,
          cursor: rxNextCursor.value.isEmpty ? null : rxNextCursor.value,
          limit: 50,
          orderBy: _buildOrderByString(),
        );
        debugPrint('####@@@ 1111 loadCloudFiles: result: ${result.toString()}');
      } else {
        result = await apiService.fetchCloudFiles(
          cloudType: rxCurrentCloudType.value,
          cursor: rxNextCursor.value.isEmpty ? null : rxNextCursor.value,
          limit: 50,
          orderBy: _buildOrderByString(),
        );
        debugPrint(
            '####@@@ 2222 loadCloudFiles: result file length: ${result?.files.length}');
      }

      debugPrint('####@@@ loadCloudFiles: result: ${result.toString()}');

      logger.d('====== request: ${rxNextCursor.value}');
      // for (int i = 0; i < (result?.files.length ?? 0); i++) {
      //   final file = result!.files[i];
      //   logger.d('${i + 1}: ${file.fileId}: ${file.fileName}');
      // }

      // result가 null이 아니면 파일 목록 출력
      if (result != null) {
        for (int i = 0; i < (result.files.length); i++) {
          final file = result.files[i];
          logger.d('${i + 1}: ${file.fileId}: ${file.fileName}');
        }

        logger.d('next cursor: ${result.metaData.nextCursor}');

        if (refresh) {
          rxCloudFiles.assignAll(result.files);
        } else {
          rxCloudFiles.addAll(result.files);
        }

        rxNextCursor.value = result.metaData.nextCursor ?? '';
        rxHasMoreData.value = rxNextCursor.value.isNotEmpty;
      } else {
        // rxErrorMessage.value = result?.message ?? '파일 목록을 불러오는 중 오류가 발생했습니다';
      }
    } catch (e) {
      rxErrorMessage.value = '파일 목록을 불러오는 중 오류가 발생했습니다: $e';
      logger.e('Error loading cloud files', e);
    } finally {
      rxIsLoading.value = false;
    }
  }

  /// 폴더로 이동
  Future<void> navigateToFolder(CloudFileModel? folder) async {
    try {
      if (folder == null) {
        if (rxCurrentFolder.value == null) {
          return;
        }
        rxCurrentFolder.value = null;
        rxCurrentPath.value = '/';
        rxCurrentPathParts.removeLast();
        await loadCloudFiles(refresh: true);
        return;
      }

      if (!folder.isFolder || folder.fileId == rxCurrentFolder.value?.fileId) {
        return;
      }

      rxCurrentFolder.value = folder;
      rxCurrentPath.value = folder.filePath;
      final index =
          rxCurrentPathParts.indexWhere((e) => e.fileId == folder.fileId);
      if (index != -1) {
        rxCurrentPathParts.removeRange(index, rxCurrentPathParts.length);
      }
      rxCurrentPathParts.add(folder);
      rxSelectedFileIds.clear();

      // 새 폴더의 내용 로드
      await loadCloudFiles(refresh: true);
    } catch (e) {
      rxErrorMessage.value = '폴더로 이동하는 중 오류가 발생했습니다: $e';
      logger.e('Error navigating to folder', e);
    }
  }

  /// 상위 폴더로 이동
  Future<void> navigateToParentFolder() async {
    if (rxCurrentPath.value == '/' || rxCurrentPath.value.isEmpty) return;

    try {
      // 현재 폴더의 부모 폴더로 이동 (실제 구현에서는 부모 폴더 정보가 필요)
      if (rxCurrentFolder.value?.parentFileId != null) {
        // 부모 폴더 정보를 가져와야 하는데, 현재는 단순히 루트로 이동
        rxCurrentFolder.value = null;
        rxCurrentPath.value = '/';
        rxCurrentPathParts.removeLast();
      } else {
        rxCurrentFolder.value = null;
        rxCurrentPath.value = '/';
        rxCurrentPathParts.removeLast();
      }

      // 상위 폴더 내용 로드
      await loadCloudFiles(refresh: true);
    } catch (e) {
      rxErrorMessage.value = '상위 폴더로 이동하는 중 오류가 발생했습니다: $e';
      logger.e('Error navigating to parent folder', e);
    }
  }

  /// 파일 검색
  Future<void> searchFiles(String query) async {
    rxSearchQuery.value = query;
    searchController.text = query;

    if (query.isEmpty) {
      // 검색어가 없으면 전체 목록 표시
      await loadCloudFiles(refresh: true);
    } else {
      // 검색 수행
      await _searchFiles(query, refresh: true);
    }
  }

  // 내부 검색 메서드
  Future<void> _searchFiles(String query, {bool refresh = false}) async {
    try {
      rxIsLoading.value = true;

      if (refresh) {
        rxCloudFiles.clear();
        rxNextCursor.value = '';
      }

      final result = await apiService.searchCloudFiles(
        cloudType: rxCurrentCloudType.value,
        query: query,
        cursor: rxNextCursor.value.isEmpty ? null : rxNextCursor.value,
        limit: 50,
      );

      if (result != null) {
        if (refresh) {
          rxCloudFiles.assignAll(result.files);
        } else {
          rxCloudFiles.addAll(result.files);
        }

        rxNextCursor.value = result.metaData.nextCursor ?? '';
        rxHasMoreData.value = rxNextCursor.value.isNotEmpty;
      } else {
        debugPrint('검색한 파일 결과가 null입니다 searchCloudFiles is null');
        //rxErrorMessage.value = result?.message ?? '파일 검색 중 오류가 발생했습니다';
      }
    } catch (e) {
      rxErrorMessage.value = '파일 검색 중 오류가 발생했습니다: $e';
      logger.e('Error searching files', e);
    } finally {
      rxIsLoading.value = false;
    }
  }

  /// 파일 정렬
  void sortFiles(String sortField) {
    if (rxSortBy.value == sortField) {
      rxSortAscending.toggle();
    } else {
      rxSortBy.value = sortField;
      rxSortAscending.value = true;
    }

    final sortedFiles = List<CloudFileModel>.from(rxCloudFiles);

    switch (sortField) {
      case 'name':
        sortedFiles.sort((a, b) => rxSortAscending.value
            ? a.fileName.compareTo(b.fileName)
            : b.fileName.compareTo(a.fileName));
        break;
      case 'size':
        sortedFiles.sort((a, b) => rxSortAscending.value
            ? a.fileSize.compareTo(b.fileSize)
            : b.fileSize.compareTo(a.fileSize));
        break;
      case 'modifiedTime':
        sortedFiles.sort((a, b) => rxSortAscending.value
            ? a.modifiedTime.compareTo(b.modifiedTime)
            : b.modifiedTime.compareTo(a.modifiedTime));
        break;
      case 'createdTime':
        sortedFiles.sort((a, b) => rxSortAscending.value
            ? a.createdTime.compareTo(b.createdTime)
            : b.createdTime.compareTo(a.createdTime));
        break;
      case 'type':
        sortedFiles.sort((a, b) => rxSortAscending.value
            ? a.fileType.compareTo(b.fileType)
            : b.fileType.compareTo(a.fileType));
        break;
    }

    rxCloudFiles.assignAll(sortedFiles);
  }

  /// 파일 선택/해제
  void toggleFileSelection(String fileId) {
    if (rxSelectedFileIds.contains(fileId)) {
      rxSelectedFileIds.remove(fileId);
    } else {
      rxSelectedFileIds.add(fileId);
    }
  }

  /// 모든 파일 선택/해제
  void toggleAllFileSelection() {
    if (rxSelectedFileIds.length == rxCloudFiles.length) {
      rxSelectedFileIds.clear();
    } else {
      rxSelectedFileIds.assignAll(rxCloudFiles.map((file) => file.fileId));
    }
  }

  /// 파일 다운로드 URL 가져오기
  Future<String?> getNaverWorksDownloadUrl(String fileId) async {
    try {
      rxIsLoading.value = true;
      rxErrorMessage.value = '';

      debugPrint('getNaverWorksDownloadUrl: $fileId');

      final result = await apiService.getNaverWorksDownloadUrl(
        fileId: fileId,
      );

      if (result != null && result.downloadUrl != null) {
        final resultDownloadUrl = result.downloadUrl ?? '';
        var downloadUrl = resultDownloadUrl;

        final uri = Uri.tryParse(resultDownloadUrl);
        if (uri != null) {
          var path = uri.path;
          if (!path.startsWith('/')) {
            path = '/$path';
          }
          // ✅ 쿼리 파라미터(fileId, auth 등)를 포함해야 함
          final pathWithQuery = uri.hasQuery ? '$path?${uri.query}' : path;
          downloadUrl =
              '${ApiDio.apiHostAppServer}naver-works-api$pathWithQuery';
        }

        debugPrint('resultDownloadUrl: $resultDownloadUrl');
        debugPrint('downloadUrl: $downloadUrl');

        return downloadUrl;
      } else {
        rxErrorMessage.value = result?.message ?? '다운로드 URL을 가져올 수 없습니다';
        return null;
      }
    } catch (e) {
      rxErrorMessage.value = '다운로드 URL을 가져오는 중 오류가 발생했습니다: $e';
      logger.e('Error getting download URL', e);
      return null;
    } finally {
      rxIsLoading.value = false;
    }
  }

  /// IOP 다운로드 URL 가져오기
  Future<String?> getIopDownloadUrl({
    String? fileId,
    String? downloadUrl,
    String? accessKey,
  }) async {
    try {
      rxIsLoading.value = true;
      rxErrorMessage.value = '';

      debugPrint(
          'getIopDownloadUrl: fileId=$fileId, downloadUrl=${downloadUrl != null ? "있음" : "없음"}, accessKey=${accessKey != null ? "있음" : "없음"}');

      final result = await apiService.getIopDownloadUrl(
        fileId: fileId,
        downloadUrl: downloadUrl,
        accessKey: accessKey,
      );

      if (result != null && result.downloadUrl != null) {
        debugPrint('IOP downloadUrl: ${result.downloadUrl}');

        // ✅ 이미 Backend 프록시 URL
        return result.downloadUrl;
      } else {
        rxErrorMessage.value = result?.message ?? '다운로드 URL을 가져올 수 없습니다';
        return null;
      }
    } catch (e) {
      rxErrorMessage.value = '다운로드 URL을 가져오는 중 오류가 발생했습니다: $e';
      logger.e('Error getting IOP download URL', e);
      return null;
    } finally {
      rxIsLoading.value = false;
    }
  }

  /// 지원하는 파일인지 확인
  bool isSupportedFile(CloudFileModel file) {
    if (file.isFolder) return false;
    return isAraFile(file) || isOfficeFile(file);
  }

  // ARA 파일인지 확인
  bool isAraFile(CloudFileModel file) {
    if (file.isFolder) return false;
    final fileExtension = file.fileName.split('.').last.toLowerCase();
    return fileExtension == 'ara';
  }

  /// Office 파일인지 확인
  bool isOfficeFile(CloudFileModel file) {
    if (file.isFolder) return false;
    final fileExtension = file.fileName.split('.').last.toLowerCase();
    return DragDocsMixin.allowedDocumentExtensions.contains(fileExtension);
  }

  /// ARA, Office 파일 다운로드 처리
  Future<void> handleFileDownload(
    CloudFileModel file, {
    VoidCallback? onNavigateToOffice,
    Function(CloudFileModel)? onCloseDialog,
  }) async {
    if (!isSupportedFile(file)) {
      debugPrint('Not supported file: ${file.fileName}');
      return;
    }

    final downloadUrl = await getNaverWorksDownloadUrl(file.fileId);
    if (downloadUrl != null) {
      //debugPrint('다운로드 URL: $downloadUrl');

      file = file.copyWith(downloadUrl: downloadUrl);
      // 실제 파일 다운로드 수행
      //await downloadNaverWorksFile(downloadUrl, file);

      // 다이얼로그 닫기 콜백 실행
      if (onCloseDialog != null) {
        onCloseDialog.call(file);
      }
    } else {
      debugPrint('다운로드 URL을 가져올 수 없습니다.');
    }
  }

  /// 클라우드 타입 변경
  Future<void> changeCloudType(CloudType cloudType) async {
    if (rxCurrentCloudType.value == cloudType) return;

    rxCurrentCloudType.value = cloudType;

    // 상태 초기화
    rxCurrentFolder.value = null;
    rxCurrentPath.value = '/';
    rxCurrentPathParts.clear();
    rxSelectedFileIds.clear();
    rxSearchQuery.value = '';
    searchController.clear();

    // 새로운 클라우드 타입의 연결 상태 확인 및 파일 목록 로드
    final isConnected = await checkCloudConnection();
    if (isConnected) {
      loadCloudFiles(refresh: true);
    }
  }

  /// OrderBy 문자열 생성
  String _buildOrderByString() {
    final direction = rxSortAscending.value ? 'asc' : 'desc';
    return '${rxSortBy.value}%20$direction';
  }

  /// 더 많은 데이터 로드 (무한 스크롤용)
  Future<void> loadMoreFiles() async {
    if (!rxHasMoreData.value || rxIsLoading.value) return;
    await loadCloudFiles(refresh: false);
  }

  /// 현재 클라우드 타입에 따른 권한 체크
  bool get canUploadFiles {
    switch (rxCurrentCloudType.value) {
      case CloudType.works:
        return rxIsNaverWorksConnected.value;
      case CloudType.brity:
        return rxIsBrityWorksConnected.value;
      case CloudType.ara:
        return true; // 아라는 항상 업로드 가능하다고 가정
    }
  }

  /// 현재 클라우드 타입에 따른 폴더 생성 권한
  bool get canCreateFolders {
    switch (rxCurrentCloudType.value) {
      case CloudType.works:
        return rxIsNaverWorksConnected.value;
      case CloudType.brity:
        return rxIsBrityWorksConnected.value;
      case CloudType.ara:
        return true; // 아라는 항상 폴더 생성 가능하다고 가정
    }
  }

  /// 에러 메시지 클리어
  void clearErrorMessage() {
    rxErrorMessage.value = '';
  }

  /// 성공 여부 확인 헬퍼 메서드 (statusCode 기반)
  // bool _isSuccessful(int? statusCode) {
  //   return statusCode != null && statusCode >= 200 && statusCode < 300;
  // }

  /// 선택된 파일들 삭제
  // Future<void> deleteSelectedFiles() async {
  //   if (rxSelectedFileIds.isEmpty) return;

  //   try {
  //     rxIsLoading.value = true;

  //     // 선택된 파일들을 하나씩 삭제
  //     final List<String> failedDeletes = [];

  //     for (final fileId in rxSelectedFileIds) {
  //       final success = await apiService.deleteFile(
  //         cloudType: rxCurrentCloudType.value,
  //         fileId: fileId,
  //       );

  //       if (!success) {
  //         failedDeletes.add(fileId);
  //       }
  //     }

  //     if (failedDeletes.isEmpty) {
  //       // 성공한 파일들을 목록에서 제거
  //       rxCloudFiles
  //           .removeWhere((file) => rxSelectedFileIds.contains(file.fileId));
  //       rxSelectedFileIds.clear();

  //       Get.snackbar(
  //         '삭제 완료',
  //         '선택된 파일들이 삭제되었습니다',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //       );
  //     } else {
  //       rxErrorMessage.value = '일부 파일 삭제에 실패했습니다';
  //     }
  //   } catch (e) {
  //     rxErrorMessage.value = '파일 삭제 중 오류가 발생했습니다: $e';
  //     logger.e('Error deleting files', e);
  //   } finally {
  //     rxIsLoading.value = false;
  //   }
  // }

  /// 파일 이름 변경
  // Future<void> renameFile(String fileId, String newName) async {
  //   try {
  //     rxIsLoading.value = true;

  //     final result = await apiService.renameFile(
  //       cloudType: rxCurrentCloudType.value,
  //       fileId: fileId,
  //       newName: newName,
  //     );

  //     if (result != null) {
  //       // 로컬에서 이름 변경
  //       final fileIndex =
  //           rxCloudFiles.indexWhere((file) => file.fileId == fileId);
  //       if (fileIndex != -1) {
  //         //rxCloudFiles[fileIndex] = result.file!;
  //       }

  //       Get.snackbar(
  //         '이름 변경 완료',
  //         '파일 이름이 변경되었습니다',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //       );
  //     } else {
  //       // rxErrorMessage.value = result?.message ?? '파일 이름 변경에 실패했습니다';
  //     }
  //   } catch (e) {
  //     rxErrorMessage.value = '파일 이름 변경 중 오류가 발생했습니다: $e';
  //     logger.e('Error renaming file', e);
  //   } finally {
  //     rxIsLoading.value = false;
  //   }
  // }

  /// 새 폴더 생성
  // Future<void> createFolder(String folderName) async {
  //   try {
  //     rxIsLoading.value = true;

  //     final result = await apiService.createFolder(
  //       cloudType: rxCurrentCloudType.value,
  //       folderName: folderName,
  //       parentFolderId: rxCurrentFolder.value?.fileId,
  //     );

  //     if (result != null) {
  //       //rxCloudFiles.add(result.file!);

  //       Get.snackbar(
  //         '폴더 생성 완료',
  //         '새 폴더가 생성되었습니다',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //       );
  //     } else {
  //       //rxErrorMessage.value = result?.message ?? '폴더 생성에 실패했습니다';
  //     }
  //   } catch (e) {
  //     rxErrorMessage.value = '폴더 생성 중 오류가 발생했습니다: $e';
  //     logger.e('Error creating folder', e);
  //   } finally {
  //     rxIsLoading.value = false;
  //   }
  // }

  /// 파일 업로드
  // Future<void> uploadFile(
  //     List<int> fileBytes, String fileName, String fileType) async {
  //   try {
  //     rxIsLoading.value = true;

  //     final result = await apiService.uploadFile(
  //       cloudType: rxCurrentCloudType.value,
  //       fileName: fileName,
  //       fileBytes: fileBytes,
  //       parentFolderId: rxCurrentFolder.value?.fileId,
  //       fileType: fileType,
  //     );

  //     if (result != null) {
  //       // rxCloudFiles.add(result.file!);

  //       Get.snackbar(
  //         '업로드 완료',
  //         '파일이 업로드되었습니다',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //       );
  //     } else {
  //       //rxErrorMessage.value = result?.message ?? '파일 업로드에 실패했습니다';
  //     }
  //   } catch (e) {
  //     rxErrorMessage.value = '파일 업로드 중 오류가 발생했습니다: $e';
  //     logger.e('Error uploading file', e);
  //   } finally {
  //     rxIsLoading.value = false;
  //   }
  // }

  /// URL로부터 파일을 다운로드하고 저장
  // Future<void> downloadNaverWorksFile(
  //     String downloadUrl, CloudFileModel file) async {
  //   // 실제 다운로드 로직은 기존 구현을 참고하여 구현 필요
  //   // 현재는 스텁(stub) 구현
  //   downloadUrl = downloadUrl.replaceAll('https://apis-storage.worksmobile.com',
  //       '${ApiDio.apiHostAppServer}naver-works-api');
  //   await apiService.downloadFile(downloadUrl, file.fileName);
  // }

  /// 네이버웍스 OAuth 인증 URL 가져오기
  // Future<String?> getNaverWorksAuthUrl() async {
  //   try {
  //     return await apiService.getNaverWorksAuthUrl();
  //   } catch (e) {
  //     logger.e('Error getting NaverWorks auth URL', e);
  //     return null;
  //   }
  // }

  /// 네이버웍스 OAuth 콜백 처리
  // Future<void> handleNaverWorksCallback({
  //   required String code,
  //   required String state,
  // }) async {
  //   try {
  //     rxIsLoading.value = true;

  //     final success = await apiService.handleNaverWorksCallback(
  //       code: code,
  //       state: state,
  //     );

  //     if (success) {
  //       rxIsNaverWorksConnected.value = true;
  //       await loadCloudFiles(refresh: true);

  //       Get.snackbar(
  //         '연결 완료',
  //         '네이버웍스에 성공적으로 연결되었습니다',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //       );
  //     } else {
  //       rxErrorMessage.value = '네이버웍스 연결에 실패했습니다';
  //     }
  //   } catch (e) {
  //     rxErrorMessage.value = '네이버웍스 연결 중 오류가 발생했습니다: $e';
  //     logger.e('Error handling NaverWorks callback', e);
  //   } finally {
  //     rxIsLoading.value = false;
  //   }
  // }

  /// 네이버웍스 연결 해제
  // Future<void> disconnectNaverWorks() async {
  //   try {
  //     rxIsLoading.value = true;

  //     final success = await apiService.disconnectNaverWorks();

  //     if (success) {
  //       rxIsNaverWorksConnected.value = false;
  //       rxCloudFiles.clear();
  //       rxCurrentFolder.value = null;
  //       rxCurrentPath.value = '/';
  //       rxCurrentPathParts.clear();

  //       Get.snackbar(
  //         '연결 해제 완료',
  //         '네이버웍스 연결이 해제되었습니다',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.orange,
  //         colorText: Colors.white,
  //       );
  //     } else {
  //       rxErrorMessage.value = '네이버웍스 연결 해제에 실패했습니다';
  //     }
  //   } catch (e) {
  //     rxErrorMessage.value = '네이버웍스 연결 해제 중 오류가 발생했습니다: $e';
  //     logger.e('Error disconnecting NaverWorks', e);
  //   } finally {
  //     rxIsLoading.value = false;
  //   }
  // }
}

// CloudType extension for UI
extension CloudTypeExtension on CloudType {
  String get title {
    switch (this) {
      case CloudType.works:
        return 'cloud_works_title'.tr;
      case CloudType.brity:
        return 'cloud_brity_title'.tr;
      case CloudType.ara:
        return 'cloud_ara_title'.tr;
    }
  }

  Widget get icon {
    switch (this) {
      case CloudType.works:
        return CommonAssets.image.naverWorksLogo.image(
          width: 24,
          height: 24,
        );
      case CloudType.brity:
        return CommonAssets.image.folder.image(
          width: 24,
          height: 24,
        );
      case CloudType.ara:
        return AutoConfig.instance.domainType.isDferiDomain
            ? CommonAssets.image.dferiLogo.svg(width: 24, height: 24)
            : CommonAssets.image.araCircleLogo.svg(
                width: 24,
                height: 24,
              );
    }
  }
}
