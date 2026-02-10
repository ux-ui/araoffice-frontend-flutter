import 'package:api/src/client/template_api_client.dart';
import 'package:api/src/result/template_result.dart';
import 'package:api/src/result/templates_result.dart';
import 'package:flutter/material.dart';

class TemplateApiService {
  final TemplateApiClient _apiClient;

  TemplateApiService(this._apiClient);

  Future<TemplatesResult?> fetchTemplate() async {
    try {
      final response = await _apiClient.fetchTemplate();

      if (response != null) {
        return TemplatesResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching template: $e');
      return null;
    }
  }

  Future<TemplateResult?> createTemplate({
    // 추가 수정 필요
    required String templateName,
    required String templateId,
  }) async {
    try {
      final response = await _apiClient.createTemplate(
        templateName: templateName,
        templateId: templateId,
      );

      if (response != null) {
        return TemplateResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      debugPrint('Error creating template: $e');
      return null;
    }
  }

  Future<TemplateResult?> fetchTemplateInfo({
    required String templateId,
  }) async {
    try {
      final response =
          await _apiClient.fetchTemplateInfo(templateId: templateId);

      if (response != null) {
        return TemplateResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching template info: $e');
      return null;
    }
  }

  Future<bool> deleteTemplate({
    required String templateId,
  }) async {
    try {
      final response = await _apiClient.deleteTemplate(templateId: templateId);
      return response;
    } catch (e) {
      debugPrint('Error deleting template: $e');
      return false;
    }
  }

  Future<TemplatesResult?> fetchMyTemplate() async {
    try {
      final response = await _apiClient.fetchMyTemplate();

      if (response != null) {
        return TemplatesResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching my template: $e');
      return null;
    }
  }

  Future<bool> addFavoritesTemplate({
    required String templateId,
  }) async {
    try {
      final response =
          await _apiClient.addFavoritesTemplate(templateId: templateId);

      if (response != null) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding favorites template: $e');
      return false;
    }
  }

  Future<bool> deleteFavoritesTemplate({
    required String templateId,
  }) async {
    try {
      final response =
          await _apiClient.deleteFavoritesTemplate(templateId: templateId);

      if (response != null) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting favorites template: $e');
      return false;
    }
  }

  Future<TemplatesResult?> fetchSharedTemplates() async {
    try {
      final response = await _apiClient.fetchSharedTemplates();

      if (response != null) {
        return TemplatesResult.fromJson(response.toJson());
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching shared templates: $e');
      return null;
    }
  }
}
