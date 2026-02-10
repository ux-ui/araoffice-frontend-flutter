import 'package:api/api.dart';
import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:api/src/result/base_result.dart';
import 'package:flutter/foundation.dart';

class TemplatesResult extends BaseResult {
  final List<TemplateModel>? templateList;

  TemplatesResult({
    required super.statusCode,
    super.message,
    this.templateList,
  });

  factory TemplatesResult.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;

      return TemplatesResult(
        message: json.requireString('message'),
        statusCode: json.optionalInt('statusCode'), // statusCode로 변경
        templateList: (data['templates'] as List<dynamic>?)
            ?.map((template) =>
                TemplateModel.fromJson(template as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing TemplateResult:');
      debugPrint('JSON: $json');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode, // statusCode로 변경
      'data': {
        'templateList':
            templateList?.map((template) => template.toJson()).toList(),
      },
    };
  }
}
