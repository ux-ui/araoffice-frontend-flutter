import 'package:api/api.dart';
import 'package:flutter/foundation.dart';

class AraApiService {
  final AraApiClient _apiClient;

  AraApiService(this._apiClient);

  /// ARA 프로젝트 저장
  Future<AraSaveResult> saveAraProject(
      String projectId, String authorization) async {
    try {
      debugPrint('Starting saveAraProject with projectId: $projectId');
      debugPrint('Authorization token: ${authorization.substring(0, 10)}...');

      final response = await _apiClient.saveProjectToNaverWorks(
        projectId: projectId,
        authorization: authorization,
      );

      // debugPrint('Response received: $response');
      // debugPrint('Response is null: ${response == null}');
      // debugPrint('Response data: ${response?.data}');
      // debugPrint('Response data is null: ${response?.data == null}');

      if (response?.data != null) {
        final statusCode = response!.data["statusCode"];
        debugPrint('Status code: $statusCode');

        if (statusCode == 200 || statusCode == "OK") {
          // debugPrint('Success status, parsing response data');
          // debugPrint('Body data: ${response.data["body"]}');
          return AraSaveResult.fromJson(response.data["body"]);
        }

        int? parsedStatusCode;
        if (statusCode is int) {
          parsedStatusCode = statusCode;
        } else if (statusCode is String) {
          parsedStatusCode = int.tryParse(statusCode);
        }

        return AraSaveResult(
            statusCode: parsedStatusCode,
            message: response.data["message"]?.toString());
      }

      return AraSaveResult(
          statusCode: 500, message: 'No response data received');
    } catch (e) {
      debugPrint('Error saving ARA project: $e');
      return AraSaveResult(
          statusCode: 500, message: 'Error saving ARA project: $e');
    }
  }

  /// 프로젝트를 ARA 파일로 네이버웍스에 저장
  /// POST /api/v1/ara/projects/{projectId}/save
  Future<bool> saveProjectToNaverWorks({
    required String projectId,
    required String authorization,
  }) async {
    try {
      if (projectId.isEmpty) {
        debugPrint('Project ID is empty');
        return false;
      }

      if (authorization.isEmpty) {
        debugPrint('Authorization token is empty');
        return false;
      }

      final response = await _apiClient.saveProjectToNaverWorks(
        projectId: projectId,
        authorization: authorization,
      );

      if (response?.data != null) {
        final statusCode = response!.data["statusCode"];
        if (statusCode == 200 || statusCode == "OK") {
          debugPrint('Project saved to Naver Works successfully');
          return true;
        } else {
          debugPrint('Failed to save project: ${response.data["message"]}');
          return false;
        }
      } else {
        debugPrint('No response data received');
        return false;
      }
    } catch (e) {
      debugPrint('Error saving project to Naver Works: $e');
      return false;
    }
  }

  // /api/v1/ara/projects/import
  // 네이버웍스 드라이브에 저장된 ARA 파일을 다운로드하여 새 프로젝트를 생성합니다.
  // Future<AraSaveResult?> importProjectFromNaverWorks({
  //   required String fileId,
  //   required String fileName,
  //   required String authorization,
  // }) async {
  //   try {
  //     final response = await _apiClient.importProjectFromNaverWorks(
  //       fileId: fileId,
  //       fileName: fileName,
  //       authorization: authorization,
  //     );

  //     if (response?.data != null) {
  //       final data = response!.data["data"] ?? response.data["body"];
  //       if (data is Map<String, dynamic>) {
  //         return AraSaveResult.fromJson(data);
  //       }
  //     }
  //     return null;
  //   } catch (e) {
  //     debugPrint('Error importProjectFromNaverWorks: $e');
  //     return null;
  //   }
  // }

  Future<AraSaveResult?> importProjectFromNaverWorks({
    required String fileId,
    required String fileName,
    required String authorization,
  }) async {
    try {
      final response = await _apiClient.importProjectFromNaverWorks(
        fileId: fileId,
        fileName: fileName,
        authorization: authorization,
      );

      if (response?.data != null) {
        final data = response!.data["data"] ?? response.data["body"];
        if (data is Map<String, dynamic>) {
          return AraSaveResult.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error importProjectFromNaverWorks: $e');
      return null;
    }
  }

  Future<AraSaveResult?> importProjectFromEpub({
    required String fileId,
    required String fileName,
  }) async {
    try {
      final response = await _apiClient.importProjectFromEpub(
        fileId: fileId,
        fileName: fileName,
      );

      if (response?.data != null) {
        final data = response!.data["data"] ?? response.data["body"];
        if (data is Map<String, dynamic>) {
          return AraSaveResult.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error importProjectFromEpub: $e');
      return null;
    }
  }
}
