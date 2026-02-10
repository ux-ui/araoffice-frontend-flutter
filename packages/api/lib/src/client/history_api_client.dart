import '../../api.dart';

class HistoryApiClient {
  final ApiDio _dio;

  HistoryApiClient(this._dio);

  Future<ApiResponse?> fetchHistory({
    required String projectId,
    required bool orderByDesc,
  }) async =>
      await _dio.get(
        '/history/$projectId/$orderByDesc',
        useAuthDio: true,
        // queryParameters: {
        //   'orderByDesc': orderByDesc,
        // }
      );

  Future<ApiResponse?> fetchExportHistory({
    required String projectId,
  }) async =>
      await _dio.get(
        '/history/export/$projectId',
        useAuthDio: true,
        // queryParameters: {
        //   'orderByDesc': orderByDesc,
        // }
      );

  Future<ApiResponse?> fetchHistoryPublish({
    required String projectId,
    required bool orderByDesc,
  }) async =>
      await _dio.get(
        '/history/publish/$projectId/$orderByDesc',
        useAuthDio: true,
      );

  Future<ApiResponse?> fetchAllHistory({
    required String page,
    required String size,
    required bool orderByDesc,
  }) async =>
      await _dio.get(
        '/history/all/$page/$size/$orderByDesc',
        useAuthDio: true,
      );
}
