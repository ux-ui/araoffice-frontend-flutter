import 'package:api/api.dart';
import 'package:api/src/model/template_model.dart';
import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:api/src/result/base_result.dart';
import 'package:flutter/foundation.dart';

class TemplateResult extends BaseResult {
  final TemplateModel? template;

  TemplateResult({
    required super.statusCode,
    super.message,
    this.template,
  });

  factory TemplateResult.fromJson(Map<String, dynamic> json) {
    try {
      final data = json.requireObject('data', (json) => json);

      return TemplateResult(
        message: json.requireString('message'),
        statusCode: json.optionalInt('statusCode'), // statusCode로 변경
        template: data.requireObject(
          'template', // data 안에서 project를 찾도록 변경
          (json) => TemplateModel.fromJson(json),
        ),
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
        'template': template?.toJson(),
      },
    };
  }
}
