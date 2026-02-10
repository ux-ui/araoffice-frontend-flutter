import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:api/src/result/base_result.dart';

class WidgetResult extends BaseResult {
  final String? widgetType;
  final String? widgetPath;
  final String? markup;
  final List<String>? jsFiles;
  final List<String>? cssFiles;

  WidgetResult({
    required super.statusCode,
    super.message,
    this.widgetType,
    this.widgetPath,
    this.markup,
    this.jsFiles,
    this.cssFiles,
  });

  factory WidgetResult.fromJson(Map<String, dynamic> json) {
    try {
      final data = json.requireObject('data', (json) => json);

      return WidgetResult(
        message: json.requireString('message'),
        statusCode: json.optionalInt('statusCode'),
        widgetType: data.optionalString('widgetType'),
        widgetPath: data.optionalString('widgetPath'),
        markup: data.optionalString('markup'),
        jsFiles: data.optionalList('jsFiles', (json) => json.toString()),
        cssFiles: data.optionalList('cssFiles', (json) => json.toString()),
      );
    } catch (e) {
      throw FormatException('Failed to parse WidgetResult: ${e.toString()}');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': {
        'widgetType': widgetType,
        'widgetPath': widgetPath,
        'markup': markup,
        'jsFiles': jsFiles,
        'cssFiles': cssFiles,
      },
    };
  }
}
