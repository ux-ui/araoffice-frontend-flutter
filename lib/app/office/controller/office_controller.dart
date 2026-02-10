import 'dart:async';

import 'package:api/api.dart';
import 'package:app/app/login/view/login_controller.dart';
import 'package:app_ui/widgets/vulcanx/vulcan_x_close_dialog_widget.dart';
import 'package:author_editor/data/vulcan_project_setting_data.dart';
import 'package:author_editor/dialog/editor_project_setting_dialog.dart';
import 'package:author_editor/mixins/dragdocs_mixin.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../common/common_view_type.dart';
import '../../editor/editor_page.dart';
import '../../home/view/home_page.dart';
import '../../project/controller/cloud_controller.dart';

class OfficeController extends GetxController {
  final LoginController loginController = Get.find<LoginController>();
  final viewType = ViewType.office.obs;
  final String fileId;
  final String fileName;
  final CloudFileModel? cloudFile;

  String get fileUrl => _fileUrl;
  var _fileUrl = '';

  // For createProject
  // OfficeViewState의 callExports 함수를 호출하기 위한 키
  final GlobalKey officeViewKey = GlobalKey();
  String? _currentProjectId;
  final _convertedPages = <Map<String, dynamic>>[];

  OfficeController({
    required this.fileId,
    required this.fileName,
    this.cloudFile,
    String? fileUrl,
  }) : _fileUrl = fileUrl ?? '';

  String get fileExtension => fileName.split('.').last.toLowerCase();
  bool get isEpubFile =>
      DragDocsMixin.allowedEpubExtensions.contains(fileExtension);
  bool get isOfficeFile =>
      DragDocsMixin.allowedOfficeExtensions.contains(fileExtension);
  bool get isViewerFile =>
      DragDocsMixin.allowedViewerExtensions.contains(fileExtension);

  // 저장소 타입 가져오기
  CloudStorageType get storageType =>
      cloudFile?.storageType ?? CloudStorageType.naverWorks;

  Future<String> loadFileUrl() async {
    var downloadUrl = cloudFile?.downloadUrl ?? '';

    // fileUrl for testing: fileUrl이 있으면 그대로 사용
    if (fileUrl.isNotEmpty) {
      downloadUrl = fileUrl;
    }
    // downloadUrl이 비어있으면 API 호출
    else if (downloadUrl.isEmpty) {
      if (storageType == CloudStorageType.naverWorks) {
        // NaverWorks: fileId로 조회
        downloadUrl = await _getNaverWorksDownloadUrl(fileId);
      } else if (storageType == CloudStorageType.iop) {
        // IOP: fileId로 조회 또는 downloadUrl 변환
        if (fileId.isNotEmpty) {
          downloadUrl = await _getIopDownloadUrl(fileId: fileId);
        } else if (cloudFile?.downloadUrl != null) {
          downloadUrl = await _getIopDownloadUrl(
            downloadUrl: cloudFile!.downloadUrl,
            accessKey: cloudFile!.secretKey, // secretKey 필드에 accessKey 저장됨
          );
        }
      }
    } else if (storageType == CloudStorageType.iop) {
      // IOP: 실제 URL을 Backend 프록시 URL로 변환
      downloadUrl = await _getIopDownloadUrl(
            downloadUrl: downloadUrl,
            accessKey: cloudFile?.secretKey, // secretKey 필드에 accessKey 저장됨
          ) ??
          downloadUrl;
    }

    // filename 파라미터 추가
    // NaverWorks와 IOP 모두 filename이 필요함 (EPUB 뷰어가 파일로 인식하도록)
    if (downloadUrl.isNotEmpty) {
      downloadUrl = '$downloadUrl&filename=$fileName';

      // 상대 경로를 절대 URL로 변환 (HWP/PDF 뷰어는 절대 URL 필요)
      if (downloadUrl.startsWith('/')) {
        // window.location.origin 사용하여 절대 URL 생성
        final origin = Uri.base.origin;
        downloadUrl = '$origin$downloadUrl';
      }
    }
    _fileUrl = downloadUrl;
    return downloadUrl;
  }

  Future<String> _getNaverWorksDownloadUrl(String fileId) async {
    final controller = Get.find<CloudController>();
    final downloadUrl = await controller.getNaverWorksDownloadUrl(fileId) ?? '';
    return downloadUrl;
  }

  Future<String> _getIopDownloadUrl({
    String? fileId,
    String? downloadUrl,
    String? accessKey,
  }) async {
    final controller = Get.find<CloudController>();
    final result = await controller.getIopDownloadUrl(
      fileId: fileId,
      downloadUrl: downloadUrl,
      accessKey: accessKey,
    );
    return result ?? '';
  }

  // 1. 변환 결과를 받아서 _convertedPages에 추가
  // 2. 모든 변환이 완료되면 createProject 호출
  // 3. 변환 도중 에러가 발생하면 종료(페이지 생성 안함)
  void onConvert(
    BuildContext context,
    int result,
    String fileName,
    int page,
    String content,
  ) {
    logger.d(
        '[OfficeController] onConvert: result($result), fileName($fileName), page($page), content length(${content.length})');

    if (!EasyLoading.isShow) {
      EasyLoading.show(status: 'document_importing'.tr);
    }

    // 변환 중 오류 발생
    if (result == -3) {
      logger.d('[OfficeController] 미지원');
      _stopCompletion(context,
          errorCode: result, errorMessage: 'document_unsupported'.tr);
      return;
    } else if (result <= 0) {
      logger.d('[OfficeController] 변환 에러');
      _stopCompletion(context, errorCode: result);
      return;
    }

    // 변환 완료, 문서 생성
    if (result == 1) {
      _createProject(context);
      return;
    }

    // result == 2 [page] 변환 성공, 변환 중
    _convertedPages.add({
      'result': result,
      'fileName': fileName,
      'page': page,
      'content': content,
    });
  }

  Future<void> _createProject(BuildContext context) async {
    if (isEpubFile) {
      await createProjectFromEpub(context, fileUrl, id: fileId, name: fileName);
    } else {
      await createProjectFromOffice(context);
    }
  }

  ///
  /// Office 파일로 새로운 프로젝트 생성
  ///
  /// - 직접 프로젝트 생성하고 페이지 생성하는 방식
  ///
  Future<void> createProjectFromOffice(BuildContext context) async {
    final safeFileName = fileName.safeFileName.trim();
    _currentProjectId = null;

    logger.d('[OfficeController] Start createProject: $safeFileName');

    if (_convertedPages.isEmpty) {
      logger.d('[OfficeController] No converted pages');
      if (context.mounted) {
        _stopCompletion(context, errorCode: -10000);
      }
      return;
    }

    // 1. 프로젝트 명 검증
    // 프로젝트 명 20자 제한
    var folderId = 'root';
    var projectName = safeFileName;
    if (safeFileName.length > 20) {
      projectName = safeFileName.substring(0, 20);
      logger.d('[OfficeController] substring: $projectName');
    }
    // 프로젝트 명 중복 불가: 400에러 발생
    final data = VulcanProjectSettingData(
      targetFolderId: folderId,
      projectName: projectName,
    );
    final projectData = await _changeProjectName(context, data);
    if (projectData == null) {
      logger.d('[OfficeController] Stop createProject');
      EasyLoading.dismiss();
      _convertedPages.clear();
      return;
    }
    if (projectData.targetFolderId != data.targetFolderId) {
      // 폴더가 변경된 경우
      folderId = projectData.targetFolderId!;
    }
    projectName = projectData.projectName;
    logger.d(
        '[OfficeController] CreateProject: folderId($folderId), projectName($projectName)');

    // 2. 프로젝트 생성
    final apiService = Get.find<ProjectApiService>();
    final projectResult = await apiService.createProject(
      folderId: folderId,
      projectName: projectName,
      templateId: null,
      useCover: false,
      useToc: false,
      language: Get.locale?.languageCode ?? 'ko',
    );

    if (projectResult?.statusCode != 200) {
      logger.d(
          '[OfficeController] CreateProject failed: ${projectResult?.message ?? 'Error: ${projectResult?.statusCode}'}');
      if (context.mounted) {
        _stopCompletion(
          context,
          errorCode: projectResult?.statusCode ?? -10001,
          errorMessage: projectResult?.message,
        );
      }
      return;
    }

    final projectId = projectResult?.project?.id;
    if (projectId == null) {
      logger.d('[OfficeController] CreateProject failed: projectId is null');
      if (context.mounted) {
        _stopCompletion(context, errorCode: -10002);
      }
      return;
    }

    logger.d('[OfficeController] CreateProject success: projectId($projectId)');
    _currentProjectId = projectId;

    // 3. 변환된 데이터로 페이지 생성
    final convertedPageCount = _convertedPages.length;
    for (int i = 0; i < convertedPageCount; i++) {
      final convertedPage = _convertedPages[i];

      final pageResult = await _createPageWithContent(
        projectId: _currentProjectId!,
        convertedPage: convertedPage,
      );

      if (!pageResult) {
        // 페이지 생성 실패 시
        // - 다음 페이지 생성 시도?
        // - 여기서 멈추고 프로젝트는 유지?
        // - 프로젝트 삭제?
      }
    }

    // 4. 해당 프로젝트로 이동
    logger.d('[OfficeController] End createProject');
    if (context.mounted) {
      _stopCompletion(context, errorCode: 1);
    }
  }

  Future<VulcanProjectSettingData?> _changeProjectName(
    BuildContext context,
    VulcanProjectSettingData data,
  ) async {
    VulcanProjectSettingData? projectData;
    EasyLoading.dismiss();
    final result = await VulcanCloseDialogWidget(
      width: 320,
      height: 320,
      title: AutoConfig.instance.domainType.isAraDomain
          ? 'create_project_title'.tr
          : 'non_ara_create_project_title'.tr,
      content: EditorProjectSettingDialog(
        initialProjectName: data.projectName,
        onTap: (projectSettingData) {
          projectData = projectSettingData;
          context.pop();
        },
      ),
    ).show(context);
    if (result == VulcanCloseDialogType.close) {
      return null;
    }
    return projectData;
/* old
    final projectController = Get.find<ProjectController>();
    final rootFolder = await projectController.getRootFolder();
    final folderContents = rootFolder?.contents ?? [];
    bool isDuplicatedName(name) {
      final duplicated = folderContents
          .any((element) => element.name.toLowerCase() == name.toLowerCase());
      if (duplicated) {
        logger.d('[OfficeController] isDuplicate: $name');
      }
      return duplicated;
    }

    var newProjectName = projectName;
    while (isDuplicatedName(newProjectName)) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      final result = await VulcanCloseDialogWidget(
        width: 320,
        height: 320,
        title: loginController.userLoginType.value != TenantType.dferi
            ? 'create_project_title'.tr
            : 'non_ara_create_project_title'.tr,
        content: EditorProjectSettingDialog(
          initialProjectName: projectName,
          contentMessage: 'duplicate_project_name'.tr,
          onTap: (projectSettingData) {
            newProjectName = projectSettingData.projectName;
            context.pop();
          },
        ),
      ).show(context);
      if (!isDuplicatedName(newProjectName)) {
        logger.d('[OfficeController] OK: $newProjectName');
        return newProjectName;
      } else if (result == VulcanCloseDialogType.close) {
        return null;
      }
    }
    return newProjectName;
*/
  }

  Future<bool> _createPageWithContent({
    required String projectId,
    required Map<String, dynamic> convertedPage,
  }) async {
    var created = false;

    try {
      final apiService = Get.find<ProjectApiService>();

      // final result = convertedPage['result'];
      final fileName = convertedPage['fileName'];
      final page = convertedPage['page'];
      final content = convertedPage['content'];

      final baseName = fileName.split('.').first;
      var extension = fileName.split('.').last;
      if (extension.startsWith('.')) {
        extension = extension.substring(1);
      }
      // Title
      final postfixTitle = '-$page';
      final title = _getTextWithLimitLength(baseName, postfixTitle);
      // File Name
      final postfixFileName =
          '_${extension}_${page}_${DateTime.now().millisecondsSinceEpoch}.xhtml';
      final saveFileName = _getTextWithLimitLength(baseName, postfixFileName);
      // 파일명에 포함될 수 없는 문자를 _로 변환
      final safeFileName = saveFileName.safeFileName;

      final requestData = {
        'projectId': projectId,
        'title': title,
        'content': content,
        'fileName': safeFileName,
      };
      logger.d(
          'createPageWithContent: projectId($projectId), title($title), fileName($safeFileName)');

      final pageResult = await apiService.createPageWithContent(requestData);

      if (pageResult != null && pageResult.statusCode == 200) {
        logger.d('[OfficeController] success to create page: $page');
        created = true;
      } else {
        logger.d(
            '[OfficeController] failed to create page: $page, error: ${pageResult?.message}');
        created = false;
      }
    } catch (e) {
      created = false;
    }

    return created;
  }

  // 페이지 변환 및 페이지 생성 종료
  Future<void> _stopCompletion(
    BuildContext context, {
    required int errorCode,
    String? errorMessage,
  }) async {
    _convertedPages.clear();

    if (_currentProjectId == null || errorCode != 1) {
      await EasyLoading.showError(
        errorMessage ?? '${'document_import_failed'.tr}: $errorCode',
        duration: const Duration(milliseconds: 2000),
      );
      if (context.mounted) {
        context.go(HomePage.route);
      }
      return;
    }

    // 해당 프로젝트로 이동
    await EasyLoading.showSuccess(
      'document_import_success'.tr,
      duration: const Duration(milliseconds: 2000),
    );
    if (context.mounted) {
      context.go('${EditorPage.route}?p=$_currentProjectId');
    }
  }

  String _getTextWithLimitLength(
    String text,
    String postfix, {
    int limitLength = 255,
  }) {
    final maxLength = limitLength - postfix.length;
    final prefix =
        text.length > maxLength ? text.substring(0, maxLength) : text;
    return '$prefix$postfix';
  }

  ///
  /// EPUB 파일로 새로운 프로젝트 생성 (네이버웍스 연동)
  ///
  /// - 서버로 fileId와 fileName을 전달하면 서버에서 프로젝트 생성 및 리소스 복원하는 방식
  ///
  Future<void> createProjectFromEpub(
    BuildContext context,
    String url, {
    String? id,
    String? name,
  }) async {
    logger.d(
        '[OfficeController] createProjectFromEpub: url($url), id(${id ?? ''}), name(${name ?? ''})');

    var requestFileId = '';
    var requestFileName = '';
    var worksToken = '';

    final uri = Uri.tryParse(url);
    if (uri != null) {
      requestFileId = uri.queryParameters['fileId'] ?? id ?? '';
      requestFileName = uri.queryParameters['fileName'] ??
          uri.queryParameters['filename'] ??
          name ??
          '';
      // final naverWorksApiClient = Get.find<NaverWorksApiClient>();
      // final authorization = await naverWorksApiClient.getNaverWorksToken();
      // worksToken = _extractWorksToken(authorization?.data['message'] ?? '');
      final cloudApiService = Get.find<CloudApiService>();
      worksToken = await cloudApiService.getNaverWorksToken() ?? '';
    } else {
      requestFileId = id ?? '';
      requestFileName = name ?? '';
    }

    if (requestFileId.isEmpty ||
        requestFileName.isEmpty ||
        worksToken.isEmpty) {
      logger.d('Must be set required values!!!');
      logger.d('fileId: $requestFileId');
      logger.d('fileName: $requestFileName');
      logger.d('worksToken: $worksToken');
      // 필수 값이 없으면 홈페이지로 이동
      await EasyLoading.showError(
        'document_import_failed_error'.tr,
        duration: const Duration(milliseconds: 2000),
      );
      if (context.mounted) {
        context.go(HomePage.route);
      }
      return;
    }

    // TODO: 선택한 페이지만 복원
    final pages = _convertedPages.map((e) => '${e['page'] ?? ''}').toList();
    logger.d('Selected pages: $pages');

    logger.d('importProject: $requestFileId, $requestFileName');
    final apiService = Get.find<AraApiService>();
    final result = await apiService.importProjectFromNaverWorks(
      fileId: requestFileId,
      fileName: requestFileName,
      authorization: worksToken,
    );

    // 에디터 페이지로 리다이렉트될 때까지 기다린다. -> 불가
    // 응답 코드(200? 302?)를 받으면 에디터 페이지로 이동

    var projectId = '';
    var errorMessage = '';
    if (result?.statusCode == 200 || result?.statusCode == 302) {
      projectId = result?.projectId ?? '';
      if (projectId.isEmpty) {
        logger.d('Failed to importProject: projectId is null');
        errorMessage =
            '${'document_import_failed_error'.tr}: ${'error_server_error'.tr}';
      }
    } else {
      logger.d('Failed to importProject: ${result?.toJson()}');
      errorMessage =
          '${'document_import_failed_error'.tr}: ${result?.statusCode}';
    }

    // 오류 발생 시 홈페이지로 이동
    if (errorMessage.isNotEmpty) {
      await EasyLoading.showError(
        errorMessage,
        duration: const Duration(milliseconds: 2000),
      );
      if (context.mounted) {
        context.go(HomePage.route);
      }
      return;
    }

    logger.d('Success to importProject from : projectId($projectId)');

    // 성공 시 에디터 페이지로 이동
    await EasyLoading.showSuccess(
      'document_import_success'.tr,
      duration: const Duration(milliseconds: 2000),
    );
    if (context.mounted) {
      context.go('${EditorPage.route}?p=$projectId');
    }
  }

  ///
  /// EPUB 파일로 새로운 프로젝트 생성 (fileUrl 전달)
  ///
  /// - 서버로 fileUrl을 전달하면 서버에서 프로젝트 생성 및 리소스 복원하는 방식
  /// - 예 : http://localhost:12342/web#/editor?fileUrl=https://www.gutenberg.org/cache/epub/77221/pg77221.epub
  ///
  Future<void> createProjectFromEpubUrl(
    BuildContext context,
    String url,
  ) async {
    logger.d('[OfficeController] createProjectFromEpubUrl: url($url)');

    var requestFileUrl = '';
    var requestFileName = '';
    var fileExtension = '';
    final uri = Uri.tryParse(url);
    if (uri != null) {
      requestFileUrl = uri.queryParameters['fileUrl'] ?? '';
      if (requestFileUrl.isNotEmpty) {
        requestFileName = requestFileUrl.split('/').last;
        fileExtension = requestFileName.split('.').last.toLowerCase();
        if (fileExtension.startsWith('.')) {
          fileExtension = fileExtension.substring(1);
        }
      }
    }

    if (requestFileUrl.isEmpty || fileName.isEmpty || fileExtension != 'epub') {
      logger.d(
          'fileUrl or fileExtension is not valid!!!: $requestFileUrl, $requestFileName, $fileExtension');
      // 필수 값이 없으면 홈페이지로 이동
      await EasyLoading.showError(
        'document_import_failed_error'.tr,
        duration: const Duration(milliseconds: 2000),
      );
      if (context.mounted) {
        context.go(HomePage.route);
      }
      return;
    }

    logger.d('importProject: $requestFileUrl, $requestFileName');
    final apiService = Get.find<AraApiService>();
    final result = await apiService.importProjectFromEpub(
      fileId: requestFileUrl,
      fileName: requestFileName,
    );

    // 에디터 페이지로 리다이렉트될 때까지 기다린다. -> 불가
    // 응답 코드(200? 302?)를 받으면 에디터 페이지로 이동

    var projectId = '';
    var errorMessage = '';
    if (result?.statusCode == 200 || result?.statusCode == 302) {
      projectId = result?.projectId ?? '';
      if (projectId.isEmpty) {
        logger.d('Failed to importProject: projectId is null');
        errorMessage =
            '${'document_import_failed_error'.tr}: ${'error_server_error'.tr}';
      }
    } else {
      logger.d('Failed to importProject: ${result?.toJson()}');
      errorMessage =
          '${'document_import_failed_error'.tr}: ${result?.statusCode}';
    }

    // 오류 발생 시 홈페이지로 이동
    if (errorMessage.isNotEmpty) {
      await EasyLoading.showError(
        errorMessage,
        duration: const Duration(milliseconds: 2000),
      );
      if (context.mounted) {
        context.go(HomePage.route);
      }
      return;
    }

    logger.d('Success to importProject from : projectId($projectId)');

    // 성공 시 에디터 페이지로 이동
    await EasyLoading.showSuccess(
      'document_import_success'.tr,
      duration: const Duration(milliseconds: 2000),
    );
    if (context.mounted) {
      context.go('${EditorPage.route}?p=$projectId');
    }
  }

  // from page_control_mixin.dart
  String _extractWorksToken(String input) {
    final regex = RegExp(r'토큰:\s*([^\s]+)');
    final match = regex.firstMatch(input);
    return match?.group(1) ?? '';
  }
}
