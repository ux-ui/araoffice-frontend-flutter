// import 'package:app/app/editor/editor_page.dart';
import 'package:api/api.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../home/view/home_page.dart';
import '../editor_page.dart';

class SplashController extends GetxController {
  final String fileId;
  final String fileName;
  final String fileUrl;
  final String? title;

  SplashController({
    this.fileId = '',
    this.fileName = '',
    this.fileUrl = '',
    this.title,
  });

  factory SplashController.binding(
    String fileId,
    String fileName,
    String? title,
  ) {
    if (Get.isRegistered<SplashController>()) {
      Get.delete<SplashController>();
    }
    Get.put(SplashController(fileId: fileId, fileName: fileName, title: title));
    final controller = Get.find<SplashController>();
    return controller;
  }

  factory SplashController.bindingFromUrl(
    String fileUrl,
    String? title,
  ) {
    if (Get.isRegistered<SplashController>()) {
      Get.delete<SplashController>();
    }
    Get.put(SplashController(fileUrl: fileUrl, title: title));
    final controller = Get.find<SplashController>();
    return controller;
  }

  /// 네이버웍스 드라이브에 저장된 ARA 파일을 다운로드하여 새 프로젝트를 생성합니다.
  ///
  /// required @param fileId, fileName, authorization
  ///
  /// 1. 네이버웍스에서 ARA 파일 다운로드
  /// 2. ARA 파일 압축 해제
  /// 3. 새 프로젝트 생성 (DB에 저장)
  /// 4. 프로젝트 리소스를 사용자 스토리지에 복원
  /// 5. 에디터 페이지로 리다이렉트 (HTTP 302)
  ///
  Future<void> loadProject(BuildContext context) async {
    logger.d('loadProject: $fileId, $fileName, $fileUrl');
    // final fileExtension = fileName.split('.').last.toLowerCase();
    // final isProjectFile = fileExtension == 'ara';
    // final isEpubFile = DragDocsMixin.allowedEpubExtensions.contains(fileExtension);
    var requestFileId = '';
    var requestFileName = '';
    var worksToken = '';

    if (fileId.isNotEmpty && fileName.isNotEmpty) {
      requestFileId = fileId;
      requestFileName = fileName;
      // final naverWorksApiClient = Get.find<NaverWorksApiClient>();
      // final authorization = await naverWorksApiClient.getNaverWorksToken();
      // worksToken = _extractWorksToken(authorization?.data['message'] ?? '');
      final cloudApiService = Get.find<CloudApiService>();
      worksToken = await cloudApiService.getNaverWorksToken() ?? '';
    } else if (fileUrl.isNotEmpty) {
      requestFileId = fileUrl;
      requestFileName = fileUrl.split('/').last;
    } else {
      logger.d('Invalid fileId or fileName or fileUrl!!!');
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

    logger.d('importProjectFromNaverWorks: $requestFileId, $requestFileName');
    final apiService = Get.find<AraApiService>();
    AraSaveResult? result;
    if (fileUrl.isNotEmpty) {
      result = await apiService.importProjectFromEpub(
        fileId: requestFileId,
        fileName: requestFileName,
      );
    } else {
      result = await apiService.importProjectFromNaverWorks(
        fileId: requestFileId,
        fileName: requestFileName,
        authorization: worksToken,
      );
    }
    if (result?.statusCode != 200 && result?.statusCode != 302) {
      logger.d('Failed to importProjectFromNaverWorks: ${result?.toJson()}');

      // 오류 발생 시 홈페이지로 이동
      await EasyLoading.showError(
        '${'document_import_failed_error'.tr}: ${result?.statusCode}',
        duration: const Duration(milliseconds: 2000),
      );
      if (context.mounted) {
        context.go(HomePage.route);
      }
      return;
    }

    // 에디터 페이지로 리다이렉트될 때까지 기다린다. -> 불가
    // 응답 코드(200? 302?)를 받으면 에디터 페이지로 이동
    final projectId = result?.projectId;
    if (projectId == null) {
      logger.d('Failed to importProjectFromNaverWorks: projectId is null');

      await EasyLoading.showError(
        '${'document_import_failed_error'.tr}: ${'error_server_error'.tr}',
        duration: const Duration(milliseconds: 2000),
      );
      if (context.mounted) {
        context.go(HomePage.route);
      }
      return;
    }

    logger.d('Success to import project from Naver Works');

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
