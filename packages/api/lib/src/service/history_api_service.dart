import 'package:api/api.dart';
import 'package:api/src/result/exprot_history_result.dart';
import 'package:api/src/result/history_list_result.dart';
import 'package:flutter/foundation.dart';

class HistoryApiService {
  final HistoryApiClient _apiClient;

  HistoryApiService(this._apiClient);

  Future<HistoryListResult?> fetchHistory(
    String projectId,
    bool orderByDesc,
  ) async {
    try {
      final result = await _apiClient.fetchHistory(
        projectId: projectId,
        orderByDesc: orderByDesc,
      );

      if (result != null) {
        return HistoryListResult.fromJson(result.toJson());
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching history: $e');
      return null;
    }
  }

  Future<ExportHistoryResult?> fetchExportHistory(String projectId) async {
    try {
      final result = await _apiClient.fetchHistoryPublish(
          projectId: projectId, orderByDesc: true);
      return ExportHistoryResult.fromJson(result?.toJson() ?? {});
    } catch (e) {
      debugPrint('Error fetching export history: $e');
      return ExportHistoryResult(
          statusCode: 500, message: 'Error fetching export history: $e');
    }
  }

  Future<HistoryListResult?> fetchHistoryPublish(
      String projectId, bool orderByDesc) async {
    try {
      final result = await _apiClient.fetchHistoryPublish(
          projectId: projectId, orderByDesc: orderByDesc);
      if (result != null) {
        return HistoryListResult.fromJson(result.toJson());
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching history publish: $e');
      return null;
    }
  }

  Future<HistoryListResult?> fetchAllHistory(
      String page, String size, bool orderByDesc) async {
    try {
      final result = await _apiClient.fetchAllHistory(
          page: page, size: size, orderByDesc: orderByDesc);
      if (result != null) {
        return HistoryListResult.fromJson(result.toJson());
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching all history: $e');
      return null;
    }
  }
}
