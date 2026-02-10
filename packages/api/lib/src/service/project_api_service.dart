import 'package:api/api.dart';
import 'package:api/src/result/folder_list_result.dart';
import 'package:api/src/result/page_result.dart';
import 'package:api/src/result/short_url_result.dart';
import 'package:author_editor/data/datas.dart';
import 'package:author_editor/enum/enums.dart';
import 'package:common_util/common_util.dart';
import 'package:dio/dio.dart';

import '../result/epub_result.dart';
import '../result/folder_result.dart';
import '../result/project_folder_result.dart';
import '../result/project_list_result.dart';
import '../result/project_result.dart';
import '../result/resource_result.dart';
import '../result/widget_result.dart';

class ProjectApiService {
  final ProjectApiClient _apiClient;

  ProjectApiService(this._apiClient);

  Future<ProjectResult?> fetchProject(String projectId) async {
    if (projectId.isEmpty) {
      logger.d('fetchProject: projectId is empty');
      return null;
    }
    try {
      final response = await _apiClient.fetchProject(projectId);

      if (response != null) {
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        String? msg;
        if (e.response?.data is Map) {
          final m = (e.response!.data as Map)['message'];
          msg = m is String ? m : null;
        }
        return ProjectResult(
          statusCode: 403,
          message: msg ?? '접근 권한이 없습니다.',
        );
      }
      logger.e('Error fetching project', e);
      return null;
    } catch (e) {
      logger.e('Error fetching project', e);
      return null;
    }
  }

  Future<ProjectListResult?> fetchProjectList() async {
    try {
      final response = await _apiClient.fetchProjectList();
      if (response != null) {
        return ProjectListResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error fetching project list', e);
      return null;
    }
  }

  /// mocktest 정보를 업데이트합니다.
  Future<ProjectFolderResult?> updateProject({
    required String name,
    required String projectId,
  }) async {
    try {
      final response =
          await _apiClient.updateProject(name: name, projectId: projectId);

      if (response != null) {
        return ProjectFolderResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error fetching project', e);
      return null;
    }
  }

  Future<ProjectListResult?> fetchProjectRecent() async {
    try {
      final response = await _apiClient.fetchProjectRecent();

      if (response != null) {
        return ProjectListResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error fetch Project Recent', e);
      return null;
    }
  }

  Future<EpubResult?> downloadEpub(VulcanEpubData epubData) async {
    try {
      final response = await _apiClient.downloadEpub(epubData);

      if (response != null) {
        return EpubResult.fromApiResponseJson(response);
      }
      return null;
    } catch (e) {
      logger.e('Error downloadEpub', e);
      return null;
    }
  }

  Future<XhtmlResult?> downloadXhtml(VulcanXhtmlData xhtmlData) async {
    try {
      final response = await _apiClient.downloadXhtml(xhtmlData);

      if (response != null) {
        return XhtmlResult.fromApiResponseJson(response);
      }
      return null;
    } catch (e) {
      logger.e('Error downloadXhtml', e);
      return null;
    }
  }

  Future<TxtResult?> downloadTxt(VulcanTxtData txtData) async {
    try {
      final response = await _apiClient.downloadTxt(txtData);

      if (response != null) {
        return TxtResult.fromApiResponseJson(response);
      }
      return null;
    } catch (e) {
      logger.e('Error downloadTxt', e);
      return null;
    }
  }

  /// EPUB 파일을 업로드
  /// [folderId]가 지정되면 해당 폴더에, 없으면 루트 폴더에 업로드합니다.
  Future<ApiResponse?> uploadEpub(
    VulcanEpubData epubData, {
    String? folderId,
  }) async {
    try {
      final response =
          await _apiClient.uploadEpub(epubData, folderId: folderId);

      if (response != null && response.isSuccessful) {
        // {"statusCode":200,"message":"파일이 성공적으로 업로드되었습니다","success":true}
        return response;
      }
      // {"statusCode":500,"message":"예기치 않은 오류가 발생했습니다","data":"EPUB 업로드 실패"}
      return response;
    } catch (e) {
      logger.e('Error uploadEpub', e);
      return null;
    }
  }

  /// XHTML 파일을 업로드
  /// [folderId]가 지정되면 해당 폴더에, 없으면 루트 폴더에 업로드
  Future<ApiResponse?> uploadXhtml(
    VulcanXhtmlData xhtmlData, {
    String? folderId,
  }) async {
    try {
      final response =
          await _apiClient.uploadXhtml(xhtmlData, folderId: folderId);

      if (response != null && response.isSuccessful) {
        // {"statusCode":200,"message":"파일이 성공적으로 업로드되었습니다","success":true}
        return response;
      }
      // {"statusCode":500,"message":"예기치 않은 오류가 발생했습니다","data":"XHTML 업로드 실패"}
      return response;
    } catch (e) {
      logger.e('Error uploadXhtml', e);
      return null;
    }
  }

  /// TXT 파일을 네이버웍스에 업로드합니다.
  /// [folderId]가 지정되면 해당 폴더에, 없으면 루트 폴더에 업로드
  Future<ApiResponse?> uploadTxt(
    VulcanTxtData txtData, {
    String? folderId,
  }) async {
    try {
      final response = await _apiClient.uploadTxt(txtData, folderId: folderId);

      if (response != null && response.isSuccessful) {
        // {"statusCode":200,"message":"파일이 성공적으로 업로드되었습니다","success":true}
        return response;
      }
      // {"statusCode":500,"message":"예기치 않은 오류가 발생했습니다","data":"TXT 업로드 실패"}
      return response;
    } catch (e) {
      logger.e('Error uploadTxt', e);
      return null;
    }
  }

  Future<ProjectResult?> activePage(
      String projectId, String type, bool isActive) async {
    try {
      final response = await _apiClient.activePage(projectId, type, isActive);
      if (response != null) {
        return ProjectResult.fromJson(response.toJson());
      }
    } catch (e) {
      logger.e('Error activePage', e);
      return null;
    }
    return null;
  }

  Future<bool> downloadFile(String title, String fileType) async {
    try {
      final fileName = '$title.$fileType';
      final response = await _apiClient.downloadFile(fileName, fileType);

      if (response != null) {
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error downloadFile', e);
      return false;
    }
  }

  Future<bool> downloadXhtmlFile(String fileName) async {
    try {
      final zipFileName =
          fileName.endsWith('.zip') ? fileName : '$fileName.zip';
      final response = await _apiClient.downloadXhtmlFile(zipFileName);

      if (response != null) {
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error downloadXhtmlFile', e);
      return false;
    }
  }

  Future<ProjectFolderResult?> createProject({
    required String projectName,
    String? folderId,
    String? templateId,
    String? description,
    bool? useCover,
    bool? useToc,
    String? language,
  }) async {
    try {
      final response = await _apiClient.createProject(
        projectName: projectName,
        description: description,
        folderId: folderId,
        templateId: templateId,
        useCover: useCover,
        useToc: useToc,
        language: language,
      );

      if (response != null) {
        return ProjectFolderResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error create Project', e);
      return null;
    }
  }

  Future<FolderResult?> deleteProject({required String projectId}) async {
    try {
      final response = await _apiClient.deleteProject(projectId: projectId);

      if (response != null) {
        return FolderResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error delete Project', e);
      return null;
    }
  }

  Future<FolderResult?> moveProject({
    required String projectId,
    required String currentFolderId,
    required String targetFolderId,
  }) async {
    try {
      final response = await _apiClient.moveProject(
          projectId: projectId,
          currentFolderId: currentFolderId,
          targetFolderId: targetFolderId);
      if (response != null) {
        return FolderResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error moveProject', e);
      return null;
    }
  }

  Future<FolderResult?> updateFolder({
    required String folderId,
    required String name,
  }) async {
    try {
      final response =
          await _apiClient.updateFolder(folderId: folderId, name: name);
      if (response != null) {
        return FolderResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error updateFolder', e);
      return null;
    }
  }

  Future<FolderResult?> createFolder({
    required String targetFolderId,
    required String name,
  }) async {
    try {
      final response = await _apiClient.createFolder(
          targetFolderId: targetFolderId, name: name);
      if (response != null) {
        return FolderResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error createFolder', e);
      return null;
    }
  }

  Future<FolderResult?> fetchFolder({
    required String folderId,
  }) async {
    try {
      final response = await _apiClient.fetchFolder(folderId);
      if (response != null) {
        return FolderResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error fetchFolder', e);
      return null;
    }
  }

  Future<FolderResult?> deleteFolder({
    required String folderId,
  }) async {
    try {
      final response = await _apiClient.deleteFolder(folderId: folderId);
      if (response != null) {
        return FolderResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error deleteFolder', e);
      return null;
    }
  }

  Future<FolderResult?> moveFolder({
    required String currentFolderId,
    required String targetFolderId,
    required String folderId,
  }) async {
    try {
      final response = await _apiClient.moveFolder(
          targetFolderId: targetFolderId,
          currentFolderId: currentFolderId,
          folderId: folderId);
      if (response != null) {
        return FolderResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error moveFolder', e);
      return null;
    }
  }

  Future<FolderListResult?> getAllFolders() async {
    try {
      final response = await _apiClient.getAllFolders();
      if (response != null) {
        return FolderListResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error getAllFolders', e);
      return null;
    }
  }

  Future<ProjectResult?> createPage(String projectId, String? parentId) async {
    try {
      final response = await _apiClient.createPage(projectId, parentId);

      if (response != null) {
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error createPage', e);
      return null;
    }
  }

  /// 내용과 함께 새로운 페이지를 생성하는 API 메서드
  /// Office 문서 변환 시 사용됩니다.
  Future<ProjectResult?> createPageWithContent(
    Map<String, dynamic> requestData,
  ) async {
    try {
      logger.d('createPageWithContent API 호출 시작');
      // logger.d('Request Data: $requestData');

      final projectId = requestData['projectId'];
      final parentId = requestData['parentId'];
      final title = requestData['title'] ?? 'New Page';
      final fileName = requestData['fileName'] ?? 'page.xhtml';
      final content = requestData['content'];

      // 요청 데이터 검증
      if (projectId == null || projectId.isEmpty) {
        logger.e('프로젝트 ID가 필요합니다.');
        throw Exception('프로젝트 ID가 필요합니다.');
      }

      if (content == null || content.isEmpty) {
        logger.e('페이지 내용이 필요합니다.');
        throw Exception('페이지 내용이 필요합니다.');
      }

      // API 클라이언트를 통해 호출
      final response = await _apiClient.createPageWithContent(
        projectId: projectId,
        title: title,
        content: content,
        fileName: fileName,
        parentId: parentId,
      );

      if (response != null) {
        logger.d('createPageWithContent 성공');
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error createPageWithContent', e);
      return null;
    }
  }

  Future<ProjectResult?> deletePage(
      {required String projectId, required String pageId}) async {
    try {
      final response = await _apiClient.deletePage(
        projectId: projectId,
        pageId: pageId,
      );

      if (response != null) {
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error deletePage', e);
      return null;
    }
  }

  Future<ProjectResult?> copyPage(
      {required String projectId,
      required String pageId,
      required String href,
      required String title}) async {
    try {
      final response = await _apiClient.copyPage(
          projectId: projectId, pageId: pageId, href: href, title: title);

      if (response != null) {
        return ProjectResult.fromJson(response.toJson());
      }

      return null;
    } catch (e) {
      logger.e('Error copyPage', e);
      return null;
    }
  }

  Future<ProjectResult?> movePage(
      {required String projectId,
      required String movedPageId,
      required String targetPageId,
      required String position}) async {
    try {
      final response = await _apiClient.movePage(
          projectId: projectId,
          movedPageId: movedPageId,
          targetPageId: targetPageId,
          position: position);

      if (response != null) {
        return ProjectResult.fromJson(response.toJson());
      }

      return null;
    } catch (e) {
      logger.e('Error copyPage', e);
      return null;
    }
  }

  Future<PageResult?> fetchSpecificPage(
      {required String projectId, required String pageId}) async {
    try {
      final response = await _apiClient.fetchSpecificPage(projectId, pageId);
      if (response != null) {
        return PageResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error fetchSpecificPage', e);
      return null;
    }
  }

  /// 서버에 저장되어있는 전체 페이지를 검색해서 TOC를 자동으로 생성합니다.
  /// [projectId] 프로젝트 ID
  /// [pageId] TOC를 삽입할 페이지 ID
  /// [type] 추출 타입 ("htag" 또는 "vlistDepth", 기본값: "htag")
  /// 성공 시 업데이트된 프로젝트 데이터를 반환합니다.
  Future<ProjectResult?> updateToc(String projectId, String pageId,
      {String? type}) async {
    try {
      final response =
          await _apiClient.updateToc(projectId, pageId, type: type);

      if (response != null) {
        logger.d('TOC 생성 성공');
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error generating TOC', e);
      return null;
    }
  }

  /// TOC 페이지를 일반 페이지로 변경하고 해당 TOC의 toc_sub 페이지들을 삭제합니다.
  /// [projectId] 프로젝트 ID
  /// [pageId] 변경할 TOC 페이지 ID
  /// 성공 시 업데이트된 프로젝트 데이터를 반환합니다.
  Future<ProjectResult?> convertTocToNormal(
      String projectId, String pageId) async {
    try {
      final response = await _apiClient.convertTocToNormal(projectId, pageId);

      if (response != null) {
        logger.d('TOC → Normal 변환 성공');
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error converting TOC to normal', e);
      return null;
    }
  }

  Future<ShortUrlResult?> shortUrl(String url) async {
    try {
      final response = await _apiClient.shortUrl(url);

      if (response != null) {
        return ShortUrlResult.fromJson(response.toJson());
      }

      return null;
    } catch (e) {
      logger.e('Error shortUrl', e);
      return null;
    }
  }

  Future<ProjectResult?> updateProjectAuth(
      String projectId, String projectAuth) async {
    try {
      final response = await _apiClient.updateProjectAuth(
        projectId: projectId,
        projectAuth: projectAuth,
      );

      if (response != null) {
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error updateProjectAuth', e);
      return null;
    }
  }

  Future<UserListResult?> getUserList(String projectId) async {
    try {
      final response = await _apiClient.getUserList(projectId);

      if (response != null) {
        return UserListResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error getUserList', e);
      return null;
    }
  }

  Future<UserInfoResult?> findUser(String userId) async {
    try {
      final response = await _apiClient.findUser(userId);

      if (response != null) {
        return UserInfoResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error getUser', e);
      return null;
    }
  }

  // Future<ProjectResult?> addUser(String projectId, String userId) async {
  //   try {
  //     final response = await _apiClient.addShareUser(
  //       projectId: projectId,
  //       userId: userId,
  //     );

  //     if (response != null) {
  //       return ProjectResult.fromJson(response.toJson());
  //     }
  //     return null;
  //   } catch (e) {
  //     logger.e('Error addUser', e);
  //     return null;
  //   }
  // }

  Future<ApiResponse?> addUser(String projectId, String userId,
      {required ShareType shareType, String? shareId}) async {
    try {
      final response = await _apiClient.addShareUser(
        projectId: projectId,
        userId: userId,
        shareType: shareType,
        shareId: shareId,
      );

      if (response != null) {
        return ApiResponse.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error addUser', e);
      return null;
    }
  }

  Future<ProjectResult?> deleteUser(String projectId, String userId) async {
    try {
      final response = await _apiClient.deleteUser(
        projectId: projectId,
        userId: userId,
      );

      if (response != null) {
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error deleteUser', e);
      return null;
    }
  }

  Future<ProjectResult?> renamePage(
      {required String projectId,
      required String pageId,
      required String href,
      required String idref,
      required bool linear,
      required String title}) async {
    try {
      final response = await _apiClient.renamePage(
          projectId: projectId,
          pageId: pageId,
          href: href,
          idref: idref,
          title: title,
          linear: linear);
      if (response != null) {
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error renamePage', e);
      return null;
    }
  }

  Future<bool?> setEditorUserPermission({
    required String pageId,
    required bool isEditorEdit,
  }) async {
    try {
      final response = await _apiClient.setEditorUserPermission(
          pageId: pageId, isEditorEdit: isEditorEdit);
      if (response != null) {
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error setEditorUserPermission', e);
      return false;
    }
  }

  Future<ProjectResult?> placementPropertyPage(
      {required String projectId,
      required String pageId,
      required Map<String, String> properties}) async {
    try {
      final response = await _apiClient.placementPropertyPage(
          projectId: projectId, pageId: pageId, properties: properties);

      if (response != null) {
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error placementPropertyPage', e);
      return null;
    }
  }

  Future<ApiResponse?> thumbnail({
    required String projectId,
    required String pageId,
    required String thumbnailImage,
  }) async {
    try {
      final response = await _apiClient.thumbnail(
        projectId: projectId,
        pageId: pageId,
        thumbnailImage: thumbnailImage,
      );

      return response;
    } catch (e) {
      logger.e('Error updatePageContent', e);
      return null;
    }
  }

  Future<ApiResponse?> updatePageContent(
      {required String projectId,
      required String pageId,
      required String fileName,
      required String content}) async {
    try {
      final response = await _apiClient.updatePageContent(
          projectId: projectId,
          pageId: pageId,
          fileName: fileName,
          content: content);

      return response;
    } catch (e) {
      logger.e('Error updatePageContent', e);
      return null;
    }
  }

  Future<ResourceResult?> uploadFile(FormData formData) async {
    try {
      final response = await _apiClient.uploadFile(formData);

      if (response != null) {
        // ✅ 저장 용량 제한 에러 처리 (413 Payload Too Large)
        if (response.statusCode == 413) {
          return ResourceResult.fromJson({
            'statusCode': 413,
            'message':
                response.message ?? 'subscription_storage_limit_exceeded',
            'success': false,
          });
        }

        return ResourceResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error uploadFile', e);
      return null;
    }
  }

  Future<ResourceResult?> fetchReousrces(
      String projectId, String fileType) async {
    try {
      final response = await _apiClient.fetchReousrces(projectId, fileType);

      if (response != null) {
        return ResourceResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error fetchReousrces', e);
      return null;
    }
  }

  Future<bool> deleteProjectResources({
    required String projectId,
    required String resourceId,
  }) async {
    try {
      final response = await _apiClient.deleteProjectResources(
          projectId: projectId, resourceId: resourceId);
      return response;
    } catch (e) {
      logger.e('Error deleteProjectResourc', e);
      return false;
    }
  }

  Future<ResourceResult?> fetchClipArt(
      {required String projectId, required String path, String? type}) async {
    try {
      final response = await _apiClient.fetchClipArt(
          projectId: projectId, path: path, type: type);

      if (response != null) {
        return ResourceResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error fetchClipArt', e);
      return null;
    }
  }

  Future<WidgetResult?> addWidget(
      String projectId, String widgetPath, String type) async {
    try {
      final response = await _apiClient.addWidget(projectId, widgetPath, type);
      if (response != null) {
        return WidgetResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error addWidget', e);
      return null;
    }
  }

  Future<ProjectResult?> editPagePermission(
      List<String> pageIds, String userId) async {
    try {
      final response = await _apiClient.editPagePermission(pageIds, userId);
      if (response != null) {
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error editPagePermission', e);
      return null;
    }
  }

  Future<UserInfoResult?> checkEditStatus({required String pageId}) async {
    try {
      final response = await _apiClient.checkEditStatus(pageId: pageId);

      if (response != null) {
        return UserInfoResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error checkEditStatus', e);
      return null;
    }
  }

  Future<UserInfoResult?> checkUserPermission(
      {required String projectId}) async {
    try {
      final response =
          await _apiClient.checkUserPermission(projectId: projectId);

      if (response != null) {
        return UserInfoResult.fromJson(response.toJson());
      }
    } catch (e) {
      logger.e('Error fetchReousrces', e);
      return null;
    }
    return null;
  }

  /// 프로젝트의 시작 페이지를 설정합니다.
  /// [projectId] 프로젝트 ID
  /// [pageId] 시작 페이지로 설정할 페이지 ID
  /// 성공 시 업데이트된 프로젝트 정보를 반환합니다.
  Future<ProjectResult?> setStartPage({
    required String projectId,
    required String pageId,
  }) async {
    try {
      final response = await _apiClient.setStartPage(
        projectId: projectId,
        pageId: pageId,
      );

      if (response != null) {
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error setting start page', e);
      return null;
    }
  }

  /// 커버 페이지를 설정합니다.
  /// [projectId] 프로젝트 ID
  /// [pageId] 커버로 설정할 페이지 ID
  /// 성공 시 업데이트된 프로젝트 정보를 반환합니다.
  Future<ProjectResult?> setCoverPage({
    required String projectId,
    required String pageId,
  }) async {
    try {
      final response = await _apiClient.setCoverPage(
        projectId: projectId,
        pageId: pageId,
      );

      if (response != null && !response.isError) {
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error setting cover page', e);
      return null;
    }
  }

  /// 커버 페이지를 해제합니다.
  /// [projectId] 프로젝트 ID
  /// [pageId] 커버를 해제할 페이지 ID
  /// 성공 시 업데이트된 프로젝트 정보를 반환합니다.
  Future<ProjectResult?> unsetCoverPage({
    required String projectId,
    required String pageId,
  }) async {
    try {
      final response = await _apiClient.unsetCoverPage(
        projectId: projectId,
        pageId: pageId,
      );

      if (response != null && !response.isError) {
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error unsetting cover page', e);
      return null;
    }
  }

  /// 가상 목록 번호를 업데이트합니다.
  /// [projectId] 프로젝트 ID
  /// [listStyleOption] 적용할 목록 스타일 옵션 (예: 've-vlist1')
  /// 성공 시 Project 객체가 포함된 UpdateListNumberingResult를 반환합니다.
  Future<ProjectResult?> updateListNumbering(
      {required String projectId, required String listStyleOption}) async {
    try {
      final response = await _apiClient.updateListNumbering(
        projectId: projectId,
        listStyleOption: listStyleOption,
      );

      if (response != null && !response.isError) {
        return ProjectResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      logger.e('Error updating list numbering', e);
      return null;
    }
  }
}
