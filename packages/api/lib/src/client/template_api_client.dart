import '../../api.dart';

class TemplateApiClient {
  final ApiDio _dio;

  TemplateApiClient(this._dio);

  Future<ApiResponse?> fetchTemplate() async => await _dio.get('/templates');

  Future<ApiResponse?> createTemplate({
    required String templateName,
    required String templateId,
  }) async =>
      await _dio.post('/templates/$templateId', data: {
        'templateName': templateName,
      });

  Future<ApiResponse?> fetchTemplateInfo({
    required String templateId,
  }) async =>
      await _dio.get('/templates/$templateId');

  Future<bool> deleteTemplate({
    required String templateId,
  }) {
    return _dio.delete('/templates/$templateId').then((result) {
      if (result.isError) {
        return false;
      }
      return true;
    });
  }

  Future<ApiResponse?> fetchMyTemplate() async =>
      await _dio.get('/templates/my');

  Future<ApiResponse?> addFavoritesTemplate({
    required String templateId,
  }) async =>
      await _dio
          .post('/templates/my/$templateId', data: {'templateId': templateId});

  Future<ApiResponse?> deleteFavoritesTemplate({
    required String templateId,
  }) async =>
      await _dio.delete('/templates/my/$templateId');

  Future<ApiResponse?> fetchSharedTemplates() async =>
      await _dio.get('/templates/shared');
}
