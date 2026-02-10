import 'package:api/src/model/utill/json_parser_extension.dart';
import 'package:api/src/result/base_result.dart';
import 'package:flutter/foundation.dart';

class CloudConnectionResult extends BaseResult {
  final bool connected;
  final Map<String, dynamic>? connectionInfo;

  CloudConnectionResult({
    required super.statusCode,
    super.message,
    required this.connected,
    this.connectionInfo,
  });

  factory CloudConnectionResult.fromJson(Map<String, dynamic> json) {
    try {
      final data = json.requireObject('data', (json) => json);

      return CloudConnectionResult(
        message: json.requireString('message'),
        statusCode: json.optionalInt('statusCode'),
        connected: data.requireBool('connected'),
        connectionInfo: data.optionalMap('connectionInfo'),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing CloudConnectionResult:');
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
      'statusCode': statusCode,
      'data': {
        'connected': connected,
        'connectionInfo': connectionInfo,
      },
    };
  }
}
