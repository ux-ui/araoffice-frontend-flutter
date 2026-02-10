import 'package:api/src/result/base_result.dart';

import '../model/resource_model.dart';

class ResourceResult extends BaseResult {
  final ResourceModel? resource;
  final List<ResourceModel>? resources;

  ResourceResult({
    required super.statusCode,
    super.message,
    this.resource,
    this.resources,
  });

  factory ResourceResult.fromJson(Map<String, dynamic> json) {
    try {
      // data 필드가 존재하는지 확인
      final data = json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      return ResourceResult(
        message: json['message'] as String? ?? '',
        statusCode: json['statusCode'] as int?,
        resource: data['resource'] != null
            ? ResourceModel.fromJson(data['resource'] as Map<String, dynamic>)
            : null,
        resources: (data['resources'] as List<dynamic>?)
            ?.map((resourceJson) =>
                ResourceModel.fromJson(resourceJson as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw FormatException('Failed to parse ResourceResult: ${e.toString()}');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': {
        'resource': resource?.toJson(),
        'resources': resources?.map((resource) => resource.toJson()).toList(),
      },
    };
  }
}
