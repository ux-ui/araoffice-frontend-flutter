import '../../api.dart';

class NaverWorksApiClient {
  final ApiDio _dio;
  NaverWorksApiClient(this._dio);

  Future<ApiResponse?> getNaverWorksToken() async =>
      await _dio.get('/test/naverworks/get-token');
}
