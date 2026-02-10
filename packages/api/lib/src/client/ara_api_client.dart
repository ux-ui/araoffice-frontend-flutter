import '../../api.dart';

class AraApiClient {
  final ApiDio _dio;
  AraApiClient(this._dio);

  Future<ApiResponse?> saveAraProject() async =>
      await _dio.post('/ara/user-info');

  /// 프로젝트를 ARA 파일로 네이버웍스에 저장
  /// POST /api/v1/ara/projects/{projectId}/save
  Future<ApiResponse?> saveProjectToNaverWorks({
    required String projectId,
    required String authorization,
  }) async =>
      await _dio.post(
        '/ara/projects/$projectId/save',
        headers: {
          'Authorization': 'Bearer $authorization',
        },
      );

  /// 네이버웍스에서 ARA파일 가져오기 (프로젝트 생성)
  /// POST /api/v1/ara/projects/import
  /// project id 응답
  Future<ApiResponse?> importProjectFromNaverWorks({
    required String fileId,
    required String fileName,
    required String authorization,
  }) async =>
      await _dio.post('/ara/projects/import', headers: {
        'Authorization': 'Bearer $authorization',
      }, data: {
        'fileId': fileId,
        'fileName': fileName,
      });

  /// URL로 EPUB파일 가져오기 (프로젝트 생성)
  /// POST /api/v1/ara/projects/epub
  /// project id 응답
  Future<ApiResponse?> importProjectFromEpub({
    required String fileId,
    required String fileName,
  }) async =>
      await _dio.post('/ara/projects/epub', data: {
        'fileId': fileId,
        'fileName': fileName,
      });
}
