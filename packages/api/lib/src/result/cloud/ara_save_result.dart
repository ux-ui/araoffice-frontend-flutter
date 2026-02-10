import 'package:api/src/result/base_result.dart';
import 'package:flutter/foundation.dart';

class AraSaveResult extends BaseResult {
  final String? projectId;
  final String? projectName;
  final String? araFileName;
  final int? fileSize;
  final String? savedAt;
  final String? fileId;

  AraSaveResult({
    required super.statusCode,
    super.message,
    this.projectId,
    this.projectName,
    this.araFileName,
    this.fileSize,
    this.savedAt,
    this.fileId,
  });

  factory AraSaveResult.fromJson(Map<String, dynamic> json) {
    try {
      // statusCode를 안전하게 처리
      int? statusCode;
      final statusCodeValue = json['statusCode'];
      if (statusCodeValue is int) {
        statusCode = statusCodeValue;
      } else if (statusCodeValue is String) {
        statusCode = int.tryParse(statusCodeValue);
      }

      // message 처리
      String message = json['message']?.toString() ?? '';

      // data가 null인 경우 처리
      final dataValue = json['data'];

      if (dataValue is Map<String, dynamic>) {
        final data = dataValue;
        return AraSaveResult(
          message: message,
          statusCode: statusCode,
          projectId: data['projectId']?.toString(),
          projectName: data['projectName']?.toString(),
          araFileName: data['araFileName']?.toString(),
          fileSize: data['fileSize'] is int
              ? data['fileSize'] as int
              : data['fileSize'] is String
                  ? int.tryParse(data['fileSize'] as String)
                  : null,
          savedAt: data['savedAt']?.toString(),
          fileId: data['fileId']?.toString(),
        );
      } else {
        // data가 Map이 아닌 경우
        return AraSaveResult(
          statusCode: statusCode,
          message: message,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error parsing AraSaveResult:');
      debugPrint('JSON: $json');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');

      // 파싱 오류 시에도 기본값으로 객체 생성
      int? statusCode;
      final statusCodeValue = json['statusCode'];
      if (statusCodeValue is int) {
        statusCode = statusCodeValue;
      } else if (statusCodeValue is String) {
        statusCode = int.tryParse(statusCodeValue);
      }

      return AraSaveResult(
        statusCode: statusCode,
        message: json['message']?.toString() ?? 'Parsing error occurred',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'projectId': projectId,
      'projectName': projectName,
      'araFileName': araFileName,
      'fileSize': fileSize,
      'savedAt': savedAt,
      'fileId': fileId,
    };
  }
}
